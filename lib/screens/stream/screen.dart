// native
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// dependencies
import 'package:flutter_ffmpeg/flutter_ffmpeg.dart';
import 'package:camera/camera.dart';
import 'package:video_player/video_player.dart';

class StreamScreen extends StatefulWidget {
  StreamScreen({Key key}) : super(key: key);

  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> with WidgetsBindingObserver {
  FlutterFFmpeg _flutterFFmpeg = new FlutterFFmpeg();
  FlutterFFmpegConfig _flutterFFmpegConfig = new FlutterFFmpegConfig();

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  VideoPlayerController _videoController;

  bool mounted = false;
  bool ffmpgeRunned = false;
  int ffmpegProcessId = 0;
  String ffpmpegPipePath = "";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    initialize();
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    _controller?.dispose();
    _flutterFFmpeg?.cancel();
    _videoController?.dispose();

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGE LIFE CYCLE $state");

    if (state == AppLifecycleState.resumed) {
      _controller != null
          ? _initializeControllerFuture = _controller.initialize()
          : null; //on pause camera is disposed, so we need to call again "issue is only for android"
    } else if (state == AppLifecycleState.paused) {
      _controller != null
          ? _initializeControllerFuture = _controller.initialize()
          : null;
    } else if (state == AppLifecycleState.inactive) {
      _controller != null
          ? _initializeControllerFuture = _controller.initialize()
          : null;
    }
  }

  Future<void> initialize() async {
    // for android: [0, 1]
    // for ios: Back Camera, Front Camera
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      firstCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();

    setState(() {
      mounted = true;
    });
  }

  runFfmpeg() async {
    _flutterFFmpegConfig.registerNewFFmpegPipe().then((val) async {
      var arguments = [
        "-y", "-video_size", "hd720",
        "-f", "android_camera",
        "-i", "0:0",
        "-s", "720x480",
        "-c:v", "copy", "-c:a", "copy",
        "-f", "mp4",
        "-movflags", "frag_keyframe+empty_moov",
        val
      ];

      print("PAHSSSS $val");

      int pid = await _flutterFFmpeg.executeAsyncWithArguments(arguments, (rc) {
        print("FFmpeg process exited with rc $rc");

        _flutterFFmpegConfig.closeFFmpegPipe(ffpmpegPipePath);
      });

      _videoController = VideoPlayerController.network("$val")
        ..initialize().then((_) { setState(() {

        }); });
      _videoController.play();

      setState(() {
        ffmpgeRunned = true;
        ffmpegProcessId = pid;
        ffpmpegPipePath = val;
      });
    });
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
        child: WillPopScope(
          onWillPop: () async {
            await _controller?.dispose();

            return true;
          },
          child: Scaffold(
            body: Container(
              child: Padding(
                padding: EdgeInsets.only(
                  top: statusBarHeight,
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    children: <Widget>[
                      _videoController == null ? Container(
                        width: 100,
                        height: 100,
                        color: Colors.green,
                      ) :VideoPlayer(_videoController),
                    ],
                  ),
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.camera_alt),
              // Provide an onPressed callback.
              onPressed: () async {
                // Take the Picture in a try / catch block. If anything goes wrong,
                // catch the error.
                try {
                  // Ensure that the camera is initialized.
                  if (ffmpgeRunned) {
                    _flutterFFmpeg.cancelExecution(ffmpegProcessId);
                    _flutterFFmpegConfig.closeFFmpegPipe(ffpmpegPipePath);

                    setState(() {
                      ffmpegProcessId = 0;
                      ffmpgeRunned = false;
                      ffpmpegPipePath = "";
                    });
                  } else {
                    //await _initializeControllerFuture;
                    runFfmpeg();
                  }
                } catch (e) {
                  // If an error occurs, log the error to the console.
                  print(e);
                }
              },
            ),
          ),
        )
    );
  }
}

// A widget that displays the picture taken by the user.
class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;

  const DisplayPictureScreen({Key key, this.imagePath}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Display the Picture')),
      // The image is stored as a file on the device. Use the `Image.file`
      // constructor with the given path to display the image.
      body: Image.file(File(imagePath)),
    );
  }
}