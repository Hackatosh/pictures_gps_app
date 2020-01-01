import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exif/exif.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:photo_manager/photo_manager.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus _permissionStatus = PermissionStatus.notDetermined;
  final Permission permission = Permission.ReadExternalStorage;
  String _gpsLocationText = "Please press button to refresh";

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    PermissionStatus permissionStatus;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      permissionStatus =
          await SimplePermissions.getPermissionStatus(permission);
    } on PlatformException {
      permissionStatus = PermissionStatus.notDetermined;
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _permissionStatus = permissionStatus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('GPS Location Leaker'),
        ),
        body: new Center(
          child: new Column(children: <Widget>[
            new Text('Status of permission READ_EXTERNAL_STORAGE : $_permissionStatus'),
            new RaisedButton(
                onPressed: requestPermission,
                child: new Text("Request permission")),
            new RaisedButton(
                onPressed: refreshGPSLocation,
                child: new Text("Obtain GPS Location")),
          new Text(_gpsLocationText),
          ]),
        ),
      ),
    );
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }

  refreshGPSLocation() async {
    String text = await getExifOf(await obtainMostRecentPicture());
    setState(() {
      _gpsLocationText = text;
    });
  }
}

Future<File> obtainMostRecentPicture() async {
  List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
  AssetPathEntity assetPathEntity = list.where((AssetPathEntity entity) => entity.name == 'Camera').toList()[0];
  List<AssetEntity> list2 = await assetPathEntity.assetList;
  File file = await list2[0].file;
  return file;
}

Future<String> getExifOf(File file) async {
  Map<String, IfdTag> data = await readExifFromBytes(await file.readAsBytes());
  String result;
  if (data == null || data.isEmpty) {
    result = "No EXIF information found";
  } else {
    final Map<String, IfdTag> filteredData = Map.from(data)
      ..removeWhere((k, v) => !k.startsWith("GPS"));
    if(filteredData.isEmpty){
      result = "No GPS information found";
    } else {
      result = "";
      for (String key in filteredData.keys) {
        result+="$key (${data[key].tagType}): ${data[key]}\n";
      }
    }
  }
  print(result);
  return result;
}
