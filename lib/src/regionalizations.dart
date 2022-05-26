import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

/// {@template r13n.regionalizations.Region}
/// An identifier used to select a user's region.
///
/// See also:
///
///  * [Locale], An identifier used to select a user's language and formatting
/// preferences.
/// {@endtemplate}
@immutable
class Region {
  /// {@macro r13n.regionalizations.Region}
  const Region({required this.regionalCode});

  /// An empty region.
  const Region.empty() : this(regionalCode: '');

  /// Fetches the region from the [PlatformDispatcher].
  ///
  /// Defaults to [Region.empty] when there is no specified platform region.
  factory Region.fromPlatform() {
    final localeCountryCode = PlatformDispatcher.instance.locale.countryCode;
    if (localeCountryCode == null) return const Region.empty();
    return Region(regionalCode: localeCountryCode.toLowerCase());
  }

  /// Code that identifies this current region.
  final String regionalCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other.runtimeType != runtimeType) return false;
    return other is Region &&
        other.regionalCode.toLowerCase() == regionalCode.toLowerCase();
  }

  @override
  int get hashCode => regionalCode.hashCode;

  @override
  String toString() => '${objectRuntimeType(this, 'Region')}[$regionalCode]';
}

/// {@template r13n.regionalizations.Regionalizations}
///
/// {@endtemplate}
class Regionalizations extends StatefulWidget {
  /// {@macro r13n.regionalizations.Regionalizations}
  const Regionalizations({
    Key? key,
    this.child,
    required this.region,
    this.delegates = const [],
  }) : super(key: key);

  /// The widget below this widget in the tree.
  final Widget? child;

  /// The resources returned by [Regionalizations.of] will be specific to this
  /// region.
  final Region region;

  /// This list collectively defines the regionalized resources objects that can
  /// be retrieved with [Regionalizations.of].
  final List<RegionalizationsDelegate<dynamic>> delegates;

  /// The region of the Regionalizations widget for the widget tree that
  /// corresponds to [BuildContext] `context`.
  ///
  /// If no [Regionalizations] widget is in scope then the
  /// [Regionalizations.regionOf] method will throw an exception.
  static Region regionOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_RegionalizationsScope>();
    assert(
      scope != null,
      '''
Requested the Region of a context that does not include a Regionalizations ancestor.
To request the Region, the context used to retrieve the Regionalizations widget must 
be that of a widget that is a descendant of a Regionalizations widget.
''',
    );
    return scope!.state.region;
  }

  /// Returns the regionalized resources object of the given `type` for the
  /// widget tree that corresponds to the given `context`.
  ///
  /// Returns null if no resources object of the given `type` exists within
  /// the given `context`.
  static T? of<T>(BuildContext context, Type type) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_RegionalizationsScope>();
    return scope?.state.resourcesFor<T?>(type);
  }

  @override
  State<Regionalizations> createState() => _RegionalizationsState();
}

class _RegionalizationsState extends State<Regionalizations> {
  Map<Type, dynamic> _typeToResources = <Type, dynamic>{};

  Region get region => _region;
  late Region _region;

  @override
  void initState() {
    super.initState();
    load(widget.region);
  }

  bool _anyDelegatesShouldReload(Regionalizations old) {
    if (widget.delegates.length != old.delegates.length) return true;
    final delegates = widget.delegates.toList();
    final oldDelegates = old.delegates.toList();
    for (var i = 0; i < delegates.length; i += 1) {
      final delegate = delegates[i];
      final oldDelegate = oldDelegates[i];
      if (delegate.runtimeType != oldDelegate.runtimeType ||
          delegate.shouldReload(oldDelegate)) return true;
    }
    return false;
  }

  @override
  void didUpdateWidget(Regionalizations old) {
    super.didUpdateWidget(old);
    if (widget.region != old.region || _anyDelegatesShouldReload(old)) {
      load(widget.region);
    }
  }

  void load(Region region) {
    final delegates = widget.delegates;
    if (delegates.isEmpty) {
      _region = region;
      return;
    }

    Map<Type, dynamic>? typeToResources;
    final typeToResourcesFuture = _loadAll(region, delegates).then(
      (value) => typeToResources = value,
    );

    final loadedSynchronously = typeToResources != null;
    if (loadedSynchronously) {
      _typeToResources = typeToResources!;
      _region = region;
      return;
    }

    // - Don't rebuild the dependent widgets until the resources for the new
    // locale have finished loading. Until then the old locale will continue
    // to be used.
    // - If we're running at app startup time then defer reporting the first
    // "useful" frame until after the async load has completed.
    RendererBinding.instance.deferFirstFrame();
    typeToResourcesFuture.then<void>((Map<Type, dynamic> value) {
      if (mounted) {
        setState(() {
          _typeToResources = value;
          _region = region;
        });
      }
      RendererBinding.instance.allowFirstFrame();
    });
  }

  T resourcesFor<T>(Type type) => _typeToResources[type] as T;

  @override
  Widget build(BuildContext context) {
    return _RegionalizationsScope(
      region: _region,
      state: this,
      typeToResources: _typeToResources,
      child: widget.child!,
    );
  }
}

class _RegionalizationsScope extends InheritedWidget {
  const _RegionalizationsScope({
    Key? key,
    required this.region,
    required this.state,
    required this.typeToResources,
    required Widget child,
  }) : super(key: key, child: child);

  final Region region;
  final _RegionalizationsState state;
  final Map<Type, dynamic> typeToResources;

  @override
  bool updateShouldNotify(_RegionalizationsScope old) {
    return typeToResources != old.typeToResources;
  }
}

/// A factory for a set of regionalized resources of type `T`, to be loaded by a
/// [Regionalizations] widget.
abstract class RegionalizationsDelegate<T> {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const RegionalizationsDelegate();

  /// Whether resources for the given region can be loaded by this delegate.
  ///
  /// Return true if the instance of `T` loaded by this delegate's [load]
  /// method supports the given `locale`'s language.
  bool isSupported(Region region);

  /// Start loading the resources for `region`. The returned future completes
  /// when the resources have finished loading.
  ///
  /// It's assumed that the this method will return an object that contains
  /// a collection of related resources (typically defined with one method per
  /// resource). The object will be retrieved with [Localizations.of].
  FutureOr<T> load(Region region);

  /// Returns true if the resources for this delegate should be loaded
  /// again by calling the [load] method.
  ///
  /// This method is called whenever its [Localizations] widget is
  /// rebuilt. If it returns true then dependent widgets will be rebuilt
  /// after [load] has completed.
  bool shouldReload(covariant RegionalizationsDelegate<T> old);

  /// The type of the object returned by the [load] method, T by default.
  ///
  /// This type is used to retrieve the object "loaded" by this
  /// [RegionalizationsDelegate] from the [Regionalizations] inherited widget.
  /// For example the object loaded by `RegionalizationsDelegate<Foo>` would
  /// be retrieved with:
  /// ```dart
  /// Foo foo = Regionalizations.of<Foo>(context, Foo);
  /// ```
  ///
  /// It's rarely necessary to override this getter.
  Type get type => T;

  @override
  String toString() =>
      '${objectRuntimeType(this, 'RegionalizationsDelgate')}[$type]';
}

// A utility function used by Regionalizations to generate one future
// that completes when all of the RegionalizationsDelegate.load() futures
// complete. The returned map is indexed by each delegate's type.
//
// The input future values must have distinct types.
//
// The returned Future<Map> will resolve when all of the input map's
// future values have resolved. If all of the input map's values are
// SynchronousFutures then a SynchronousFuture will be returned
// immediately.
//
// This is more complicated than just applying Future.wait to input
// because some of the input.values may be SynchronousFutures. We don't want
// to Future.wait for the synchronous futures.
Future<Map<Type, dynamic>> _loadAll(
  Region region,
  Iterable<RegionalizationsDelegate<dynamic>> allDelegates,
) {
  final resources = <Type, dynamic>{};
  Map<Type, Future>? pendingResources;

  // Only load the first delegate for each supported delegate type.
  final types = <Type>{};
  final delegates = <RegionalizationsDelegate<dynamic>>[];
  for (final delegate in allDelegates) {
    if (!types.contains(delegate.type) && delegate.isSupported(region)) {
      types.add(delegate.type);
      delegates.add(delegate);
    }
  }

  for (final delegate in delegates) {
    final resource = delegate.load(region);
    final type = delegate.type;

    if (resource is! Future) {
      resources[type] = resource;
    } else if (resource is SynchronousFuture) {
      resource.then<void>((dynamic value) => resources[type] = value);
    } else {
      pendingResources ??= {};
      pendingResources[delegate.type] = resource;
    }
  }

  // All of the delegate.load() values were synchronous futures, we're done.
  if (pendingResources == null) {
    return SynchronousFuture<Map<Type, dynamic>>(resources);
  }

  // Some of delegate.load() values were asynchronous, wait for them.
  return Future.wait<dynamic>(pendingResources.values).then<Map<Type, dynamic>>(
    (values) {
      final types = pendingResources!.keys;
      for (var i = 0; i < values.length; i++) {
        resources[types.elementAt(i)] = values[i];
      }
      return resources;
    },
  );
}
