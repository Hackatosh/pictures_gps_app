import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import '../managers/pictures.dart';

class CamerasManager {

  CamerasManager();

  static Future<CameraController> _createCameraController() async {
    List<CameraDescription> cameras = await availableCameras();
    CameraDescription firstCamera = cameras.first;
    return CameraController(
      // Get a specific camera from the list of available cameras.
      firstCamera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );
  }

  static Future<Picture> getPictureFromCamera() async {
    CameraController controller = await _createCameraController();
    Picture picture;
    try {
      // Ensure that the camera is initialized.
      await controller.initialize();
      // Construct the path where the image should be saved using the
      // pattern package.
      String path = join(
        // Store the picture in the temp directory.
        // Find the temp directory using the `path_provider` plugin.
        (await getTemporaryDirectory()).path,
        '${DateTime.now()}.png',
      );
      // Attempt to take a picture and log where it's been saved.
      await controller.takePicture(path);
      picture = await Picture.asyncCreateFromFile(File(path));
    } catch (e) {
      // If an error occurs, log the error to the console.
      print(e);
    } finally{
      controller?.dispose();
    }
    return picture;
  }

}