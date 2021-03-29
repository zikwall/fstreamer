// native
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// dependencies
import 'package:fstreamer/screens/stream/screen.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = 0;

    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
            body: Container(
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight,
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Center(
                        child: TextButton(
                          child: Container(
                            padding: EdgeInsets.all(10),
                            child: Text('Goto stream'),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => StreamScreen(),
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            primary: Colors.white,
                            backgroundColor: Colors.orange,
                          ),
                        ),
                      )
                    ),
                  ],
                ),
              ),
            ),
        )
    );
  }
}