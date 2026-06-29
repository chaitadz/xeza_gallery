import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  void checkPlatform() {
    if (Theme.of(context).platform == TargetPlatform.android) {
      debugPrint('Running on Android');
    } else if (Theme.of(context).platform == TargetPlatform.iOS) {
      debugPrint('Running on iOS');
    } else {
      debugPrint('Running on an unknown platform');
    }

    if (!kIsWeb) {
      String osName = Platform.operatingSystem;
      debugPrint("OS Name: $osName");
    }
  }

  @override
  Widget build(BuildContext context) {
    checkPlatform();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            // const Text('You have pushed the button this many times:'),
            // Text(
            //   '$_counter',
            //   style: Theme.of(context).textTheme.headlineMedium,
            // ),
            Row(children: []),
            Text('text 1'),
            Row(
              children: [
                Text('text 2'),
                SizedBox(width: 100),
                Text('text 3'),
                Container(
                  width: 100,
                  height: 100,
                  color: Colors.red,
                  child: Center(child: Text('text 4')),
                ),
              ],
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: 'Increment',
      //   child: const Icon(Icons.add),
      // ),
    );
  }
}
