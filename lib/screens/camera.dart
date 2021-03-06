import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diary/return_home_handle.dart';
import 'package:diary/screens/home.dart';
import 'package:diary/widgets/dialog_loading.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:path/path.dart' show join;

class CameraScreen extends StatefulWidget {
  final DateTime date;
  final String text;
  final String userId;

  const CameraScreen({Key key, this.date, this.text, this.userId})
      : super(key: key);

  @override
  _CameraScreenState createState() {
    return _CameraScreenState();
  }
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController controller;
  List cameras;
  int selectedCameraIdx;
  String imagePath;

  @override
  void initState() {
    super.initState();
    availableCameras().then((availableCameras) {
      cameras = availableCameras;

      if (cameras.length > 0) {
        setState(() {
          selectedCameraIdx = cameras.length == 2 ? 1 : 0;
        });

        _initCameraController(cameras[selectedCameraIdx]).then((void v) {});
      } else {
        print("No camera available");
      }
    }).catchError((err) {
      print('Error: $err.code\nError Message: $err.message');
    });
  }

  Future _initCameraController(CameraDescription cameraDescription) async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(cameraDescription, ResolutionPreset.high);

    // If the controller is updated then update the UI.
    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }

      if (controller.value.hasError) {
        print('Camera error ${controller.value.errorDescription}');
      }
    });

    try {
      await controller.initialize();
    } on CameraException catch (e) {
      _showCameraException(e);
    }

    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Seja você',
          style: TextStyle(
            shadows: <Shadow>[
              Shadow(
                blurRadius: 20.0,
                color: Colors.grey,
                offset: Offset(0, 0),
              ),
            ],
            color: Colors.white70,
            fontWeight: FontWeight.w100,
          ),
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                flex: 1,
                child: _cameraPreviewWidget(),
              ),
              SizedBox(height: 10.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  _cameraTogglesRowWidget(),
                  _captureControlRowWidget(context),
                  Spacer()
                ],
              ),
              SizedBox(height: 20.0)
            ],
          ),
        ),
      ),
    );
  }

  /// Display Camera preview.
  Widget _cameraPreviewWidget() {
    if (controller == null || !controller.value.isInitialized) {
      return Center(
        child: const Text(
          'Loading',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
            fontWeight: FontWeight.w900,
          ),
        ),
      );
    }

    return AspectRatio(
      aspectRatio: controller.value.aspectRatio,
      child: CameraPreview(controller),
    );
  }

  /// Display the control bar with buttons to take pictures
  Widget _captureControlRowWidget(context) {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          mainAxisSize: MainAxisSize.max,
          children: [
            FloatingActionButton(
                child: Icon(Icons.camera),
                backgroundColor: Colors.blueGrey,
                onPressed: () {
                  _onCapturePressed(context);
                })
          ],
        ),
      ),
    );
  }

  /// Display a row of toggle to select the camera (or a message if no camera is available).
  Widget _cameraTogglesRowWidget() {
    if (cameras == null || cameras.isEmpty) {
      return Spacer();
    }

    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    CameraLensDirection lensDirection = selectedCamera.lensDirection;

    return Expanded(
      child: Align(
        alignment: Alignment.centerLeft,
        child: FlatButton.icon(
            onPressed: _onSwitchCamera,
            icon: Icon(_getCameraLensIcon(lensDirection)),
            label: Text(
                "${lensDirection.toString().substring(lensDirection.toString().indexOf('.') + 1)}")),
      ),
    );
  }

  IconData _getCameraLensIcon(CameraLensDirection direction) {
    switch (direction) {
      case CameraLensDirection.back:
        return Icons.camera_rear;
      case CameraLensDirection.front:
        return Icons.camera_front;
      case CameraLensDirection.external:
        return Icons.camera;
      default:
        return Icons.device_unknown;
    }
  }

  void _onSwitchCamera() {
    selectedCameraIdx =
        selectedCameraIdx < cameras.length - 1 ? selectedCameraIdx + 1 : 0;
    CameraDescription selectedCamera = cameras[selectedCameraIdx];
    _initCameraController(selectedCamera);
  }

  void _onCapturePressed(context) async {
    // Take the Picture in a try / catch block. If anything goes wrong,
    // catch the error.
    try {
      DialogLoading.showLoadingDialog(context);
      final String _dirPath =
          'users/${widget.userId}/${widget.date.year.toString()}/${widget.date
          .month.toString().padLeft(2, "0")}';
      final String finalPath =
      join((await getApplicationDocumentsDirectory()).path, _dirPath);
      String dirPath =
          (await Directory(finalPath).create(recursive: true)).path;
      final String imgPath =
      join(dirPath, '${widget.date.day.toString().padLeft(2, "0")}.png');
      await controller.takePicture(imgPath);
      // print('====================== $imgPath');
      await _saveFirebase(imgPath);
    } catch (e) {
      // If an error occurs, log the error to the console.
      _showCameraException(e);
    } finally {
      Navigator.of(context).pushNamedAndRemoveUntil(
          ReturnHomeHandleScreen.routeName, (Route<dynamic> route) => false,
          arguments: HomeArguments(widget.userId));
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  HomeScreen(
                    userId: widget.userId,
                  )));
    }
  }

  Future _saveFirebase(String path) async {
    try {
      //save image
      await FirebaseStorage.instance
          .ref()
          .child(path)
          .putFile(File(path))
          .onComplete;
      Firestore.instance
          .collection('users')
          .document(widget.userId)
          .collection('years')
          .document(widget.date.year.toString())
          .collection('months')
          .document(widget.date.month.toString().padLeft(2, '0'))
          .collection('days')
          .document(widget.date.day.toString().padLeft(2, '0'))
          .setData({
        'text': widget.text,
        'imageUrl': path,
        'date': Timestamp.fromDate(widget.date)
      });
    } catch (err) {
      print(err);
    }
  }

  void _showCameraException(CameraException e) {
    String errorText = 'Error: ${e.code}\nError Message: ${e.description}';
    print(errorText);

    print('Error: ${e.code}\n${e.description}');
  }
}
