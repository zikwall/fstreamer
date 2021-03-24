// native
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// dependencies
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:camera/camera.dart';

class HomeScreen extends StatefulWidget {
  HomeScreen({Key key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  final FlutterFFmpegConfig flutterFFmpegConfig = new FlutterFFmpegConfig();

  @override
  void initState() {
    super.initState();

    availableCameras().then((availableCameras) {
      print(availableCameras);
    });
  }
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.light,
        ),
        child: Scaffold(
            body: Container(
              color: Color(0xff0d1117),
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight,
                ),
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: Text('HOME'),
                    )
                  ],
                ),
              ),
            ),
        )
    );
  }
}