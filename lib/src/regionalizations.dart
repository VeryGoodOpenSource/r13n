// Copyright (c) 2022, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:ui';

import 'package:flutter/foundation.dart';
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

  /// Fetches the region from the [PlatformDispatcher].
  ///
  /// Defaults to [Region.empty] when there is no specified platform region.
  factory Region.fromPlatform() {
    final localeCountryCode = PlatformDispatcher.instance.locale.countryCode;
    if (localeCountryCode == null) return Region.empty;
    return Region(regionalCode: localeCountryCode.toLowerCase());
  }

  /// An empty region.
  static const empty = Region(regionalCode: '');

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
/// Defines the [Region] for its `child` and the localized resources that the
/// child depends on.
///
/// [Regionalizations] mimics the [Localizations] API
///
/// See also:
///
///  * [Localizations], defines the [Locale] for its `child` and the localized
/// resources that the child depends on.
///  * [LocalizationsDelegate], A factory for a set of localized resources of
/// type T, to be loaded by a [Localizations] widget.
/// {@endtemplate}
class Regionalizations extends StatefulWidget {
  /// {@macro r13n.regionalizations.Regionalizations}
  const Regionalizations({
    super.key,
    this.child,
    required this.region,
    this.delegates = const [],
  });

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
    _typeToResources = _loadAll(region, widget.delegates);
    _region = region;
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
    required this.region,
    required this.state,
    required this.typeToResources,
    required super.child,
  });

  final Region region;
  final _RegionalizationsState state;
  final Map<Type, dynamic> typeToResources;

  @override
  bool updateShouldNotify(_RegionalizationsScope old) =>
      typeToResources != old.typeToResources;
}

/// A factory for a set of regionalized resources of type `T`, to be loaded by a
/// [Regionalizations] widget.
///
/// Unlike [LocalizationsDelegate] asynchronous resource loading is not yet
/// supported.
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
  T load(Region region);

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
      '${objectRuntimeType(this, 'RegionalizationsDelegate')}[$type]';
}

Map<Type, dynamic> _loadAll(
  Region region,
  Iterable<RegionalizationsDelegate<dynamic>> allDelegates,
) {
  final resources = <Type, dynamic>{};

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
    final type = delegate.type;
    resources[type] = delegate.load(region);
  }

  return resources;
}
