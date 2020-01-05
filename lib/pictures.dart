import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PicturesManager {
  Picture _mostRecentPicture;
  void Function(Picture picture) _updateMostRecentPictureCallback;
  Timer _timer;

  PicturesManager(this._updateMostRecentPictureCallback, bool withPeriodicUpdate){
    if(withPeriodicUpdate){
      _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateMostRecentPicture(_updateMostRecentPictureCallback));
    } else {
      _timer = null;
    }
  }

  void dispose() {
    _timer?.cancel();
  }

  void startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) => updateMostRecentPicture(_updateMostRecentPictureCallback));
  }

  void stopTimer() {
    _timer?.cancel();
  }

  Future<void> updateMostRecentPicture(Function callback) async{
    print("Checking for new picture !");
    Picture picture = await PicturesManager.obtainMostRecentPicture();
    if(picture.path != _mostRecentPicture?.path){
      _mostRecentPicture = picture;
      _updateMostRecentPictureCallback(picture);
    }
  }

  static Future<Picture> obtainMostRecentPicture() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    AssetPathEntity assetPathEntity = list
        .where((AssetPathEntity entity) => entity.name == 'Camera')
        .toList()[0];
    List<AssetEntity> list2 = await assetPathEntity.assetList;
    File file = await list2[0].file;
    return await Picture.asyncCreateFromFile(file);
  }
}

class Picture {
  String path;
  String exifInfos;

  Image get image => Image.file(File(path));

  Picture(this.path,this.exifInfos);

  static Future<Picture> asyncCreateFromFile(File file) async {
    String exifInfos = await Picture.getExifOfFile(file);
    return Picture(file.path, exifInfos);
  }

  static Future<String> getExifOfFile(File file) async {
    Map<String, IfdTag> data = await readExifFromBytes(
        await file.readAsBytes());
    String result;
    if (data == null || data.isEmpty) {
      result = "No EXIF information found";
    } else {
      final Map<String, IfdTag> filteredData = Map.from(data)
        ..removeWhere((k, v) => !k.startsWith("GPS"));
      if (filteredData.isEmpty) {
        result = "No GPS information found";
      } else {
        result = "";
        for (String key in filteredData.keys) {
          result += "$key (${data[key].tagType}): ${data[key]}\n";
        }
      }
    }
    return result;
  }


}