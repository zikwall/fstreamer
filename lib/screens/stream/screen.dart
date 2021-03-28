// native
import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

// dependencies
import 'package:rtmp_publisher/camera.dart';

// application
import 'package:fstreamer/constants/rtmp.dev.dart';

class StreamScreen extends StatefulWidget {
  StreamScreen({Key key}) : super(key: key);

  @override
  _StreamScreenState createState() => _StreamScreenState();
}

class _StreamScreenState extends State<StreamScreen> with WidgetsBindingObserver {
  bool mounted = false;
  bool enableAudio = true;
  bool useOpenGL = true;
  String url = RTMPPush;

  Future<void> _initializeControllerFuture;
  CameraController _controller;

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

    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    print("CHANGE LIFE CYCLE $state");

    if (_controller == null || !_controller.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _controller?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      if (_controller != null) {
        onNewCameraSelected(_controller.description);
      }
    }
  }

  void onNewCameraSelected(CameraDescription cameraDescription) async {
    if (_controller != null) {
      await _controller.dispose();
    }
    _controller = CameraController(
      cameraDescription,
      ResolutionPreset.medium,
      enableAudio: enableAudio,
      androidUseOpenGL: useOpenGL,
    );

    // If the controller is updated then update the UI.
    _controller.addListener(() {
      if (mounted) setState(() {});
      if (_controller.value.hasError) {
        print('Camera error ${_controller.value.errorDescription}');
      }
    });

    try {
      await _controller.initialize();
    } on CameraException catch (e) {
      print(e);
    }

    if (mounted) {
      setState(() {});
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

  Future<String> startVideoStreaming() async {
    if (!_controller.value.isInitialized) {
      print('Error: select a camera first.');
      return null;
    }

    if (_controller.value.isStreamingVideoRtmp) {
      print('Error: already steamed.');
      return null;
    }

    String _url = url;

    try {
      await _controller.startVideoStreaming(_url);
    } on CameraException catch (e) {
      print(e);
      return null;
    }

    return _url;
  }

  Future<void> stopVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      print('Error: camera not streamed.');
      return null;
    }

    try {
      await _controller.stopVideoStreaming();
    } on CameraException catch (e) {
      print(e);
      return null;
    }
  }

  Future<void> pauseVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      print('Error: camera not streamed.');
      return null;
    }

    try {
      await _controller.pauseVideoStreaming();
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> resumeVideoStreaming() async {
    if (!_controller.value.isStreamingVideoRtmp) {
      print('Error: camera not streamed.');
      return null;
    }

    try {
      await _controller.resumeVideoStreaming();
    } on CameraException catch (e) {
      print(e);
      rethrow;
    }
  }

  void onVideoStreamingButtonPressed() {
    startVideoStreaming().then((String url) {
      if (mounted) setState(() {});

      if (url != null) {
        print('Streaming video to $url');
      }
    });
  }

  void onStopButtonPressed() {
    if (this._controller.value.isStreamingVideoRtmp) {
      stopVideoStreaming().then((_) {
        if (mounted) setState(() {});
        print('Video streaming stopped');
      });
    }
  }

  void onPauseStreamingButtonPressed() {
    pauseVideoStreaming().then((_) {
      if (mounted) setState(() {});
      print('Video streaming paused');
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
                child: Column(
                  children: <Widget>[
                    Expanded(
                      child: FutureBuilder<void>(
                        future: _initializeControllerFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            // If the Future is complete, display the preview.
                            return CameraPreview(_controller);
                          } else {
                            // Otherwise, display a loading indicator.
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
                    )
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              child: Icon(Icons.camera_alt),
              onPressed: () async {
                if (!_controller.value.isStreamingVideoRtmp) {
                  onVideoStreamingButtonPressed();
                } else {
                  onStopButtonPressed();
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