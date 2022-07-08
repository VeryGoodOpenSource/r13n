import 'package:example/r13n/r13n.dart';
import 'package:flutter/material.dart';
import 'package:r13n/r13n.dart';

void main() {
  runApp(
    const MaterialApp(home: _ExamplePage()),
  );
}

class _ExamplePage extends StatefulWidget {
  const _ExamplePage();

  @override
  State<_ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<_ExamplePage> {
  late Region region = Region.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Regionalizations(
      region: region,
      delegates: const [AppRegionalizations.delegate],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(context.r13n.region.regionalCode),
            ),
            body: Center(
              child: Column(
                children: [
                  DropdownButton<Region>(
                    value: context.r13n.region,
                    items: const [
                      DropdownMenuItem(
                        value: Region(regionalCode: 'es'),
                        child: Text('Spain'),
                      ),
                      DropdownMenuItem(
                        value: Region(regionalCode: 'gb'),
                        child: Text('Great Britain'),
                      ),
                      DropdownMenuItem(
                        value: Region(regionalCode: 'us'),
                        child: Text('Unites States'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() => region = value);
                    },
                  ),
                  Text('Support email: ${context.r13n.supportEmail}'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
