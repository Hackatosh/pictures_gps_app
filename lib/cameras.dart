import 'dart:async';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class CamerasManager {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  CamerasManager._(this._controller, this._initializeControllerFuture) {}

  static Future<CamerasManager> createCamerasManager() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription firstCamera = cameras.first;
    CameraController controller = CameraController(
      // Get a specific camera from the list of available cameras.
      firstCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
    Future<void> initializeControllerFuture = controller.initialize();
    return CamerasManager._(controller, initializeControllerFuture);
  }

  void dispose() {
    _controller.dispose();
  }

  // Return the path of the picture
  Future<String> takePicture() async {
    try {
      // Ensure that the camera is initialized.
      await _initializeControllerFuture;
      // Construct the path where the image should be saved using the
      // pattern package.
      final path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      // Attempt to take a picture and log where it's been saved.
      await _controller.takePicture(path);
      return path;
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
      return null;
    }
  }
}