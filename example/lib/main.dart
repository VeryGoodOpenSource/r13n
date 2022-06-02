import 'package:example/r13n/r13n.dart';
import 'package:flutter/material.dart';
import 'package:r13n/r13n.dart';

void main() {
  runApp(
    const MaterialApp(
      home: ExamplePage(),
    ),
  );
}

class ExamplePage extends StatefulWidget {
  const ExamplePage({super.key});

  @override
  State<ExamplePage> createState() => _ExamplePageState();
}

class _ExamplePageState extends State<ExamplePage> {
  late Region region;

  @override
  void initState() {
    super.initState();
    region = Region.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    return Regionalizations(
      region: region,
      delegates: const [AppRegionalizations.delegate],
      child: Builder(
        builder: (context) {
          return Scaffold(
            appBar: AppBar(
              title: Text(Regionalizations.regionOf(context).regionalCode),
            ),
            body: Center(
              child: Column(
                children: [
                  DropdownButton<Region>(
                    value: Regionalizations.regionOf(context),
                    items: const [
                      DropdownMenuItem(
                        value: Region(regionalCode: 'es'),
                        child: Text('Spain'),
                      ),
                      DropdownMenuItem(
                        value: Region(regionalCode: 'gb'),
                        child: Text('United Kingdom'),
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
