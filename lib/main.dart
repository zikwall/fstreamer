// native
import 'package:flutter/material.dart';

// application
import 'package:fstreamer/screens/home/screen.dart';

void main() {
  runApp(FStreamerApplication());
}

class FStreamerApplication extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return MaterialApp(
      title: 'F-Streamer Project',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomeScreen(),
    );
  }
}