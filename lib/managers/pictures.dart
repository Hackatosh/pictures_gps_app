import 'dart:async';
import 'dart:io';

import 'package:exif/exif.dart';
import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class PicturesManager {
  static Future<Picture> obtainMostRecentFromCamera() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    AssetPathEntity assetPathEntity = list
        .where((AssetPathEntity entity) => entity.name == 'Camera')
        .toList()[0];
    List<AssetEntity> list2 = await assetPathEntity.assetList;
    File file = await list2[0].file;
    Picture picture = await Picture.asyncCreateFromFile(file);
    return picture;
  }

  static Future<List<Picture>> obtainAllFromCamera() async {
    List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
    AssetPathEntity assetPathEntity = list
        .where((AssetPathEntity entity) => entity.name == 'Camera')
        .toList()[0];
    List<AssetEntity> list2 = await assetPathEntity.assetList;
    List<Picture> result = [];
    for(AssetEntity asset in list2){
      result.add(await Picture.asyncCreateFromFile(await asset.file));
    }
    return result;
  }
}

class Picture {
  String path;
  Map<String,String> exifInfos;

  Image get image => Image.file(File(path));

  Picture(this.path,this.exifInfos);

  static Future<Picture> asyncCreateFromFile(File file) async {
    Map<String,String> exifInfos = await Picture.getExifOfFile(file);
    return Picture(file.path, exifInfos);
  }

  static Future<Map<String,String>> getExifOfFile(File file) async {
    Map<String, IfdTag> data = await readExifFromBytes(
        await file.readAsBytes());
    Map<String,String> result = {};
    if (data == null || data.isEmpty) {
      result = {"Default":"No EXIF information found"};
    } else {
      final Map<String, IfdTag> filteredData = Map.from(data)
        ..removeWhere((k, v) => !k.startsWith("GPS"));
      if (filteredData.isEmpty) {
        result = {"Default":"No GPS information found"};
      } else {
        for (String key in filteredData.keys) {
          result.addEntries({key:data[key].toString()}.entries);
        }
      }
    }
    return result;
  }


}