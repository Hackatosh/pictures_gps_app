import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pictures_gps_app/cameras.dart';

import 'package:simple_permissions/simple_permissions.dart';

import 'notifications.dart';
import 'pictures.dart';

void main() => runApp(new MyApp());



class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus _permissionStatus = PermissionStatus.notDetermined;
  final Permission permission = Permission.Camera;
  String _gpsLocationText = "Please press button to refresh";
  NotificationsManager _notificationsManager;
  PicturesManager _picturesManager;
  CamerasManager _camerasManager;
  Image _currentImage;

  @override
  initState() {
    super.initState();
    initPermissionStatus();
    initCamerasManager();
    _notificationsManager = NotificationsManager();
    _picturesManager = PicturesManager(refreshGPSLocationFromPictureCallback, false);
  }

  @override
  void dispose() {
    _picturesManager.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPermissionStatus() async {
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

  initCamerasManager() async {
    CamerasManager camerasManager = await CamerasManager.createCamerasManager();
    if(!mounted) return;

    setState(() {
      _camerasManager = camerasManager;
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
            new Text(
                'Status of permission Camera Permission : $_permissionStatus'),
            new RaisedButton(
                onPressed: requestPermission,
                child: new Text("Request permission")),
            new RaisedButton(
                onPressed: triggerPicturesManagerUpdate,
                child: new Text("Obtain GPS Location")),
            new RaisedButton(
                onPressed: _picturesManager.startTimer,
                child: new Text("Launch camera folder watcher")),
            new RaisedButton(
                onPressed: _picturesManager.stopTimer,
                child: new Text("Stop camera folder watcher")),
            new RaisedButton(
                onPressed: takePicture,
                child: new Text("Take picture")),
            new Text(_gpsLocationText),
            _currentImage ?? new Text("Please take a picture"),
          ]),
        ),
      ),
    );
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }

  triggerPicturesManagerUpdate() async{
    _picturesManager.updateMostRecentPicture(refreshGPSLocationFromPictureCallback);
  }

  refreshGPSLocationFromPictureCallback(String gpsInfos) async {
    setState(() {
      _gpsLocationText = gpsInfos;
    });
    GPSLocationNotification notification = new GPSLocationNotification(id: 0, title: "GPS Location updated !", body: "A new photo has triggered the GPS location update", payload: gpsInfos);
    _notificationsManager.sendNotification(notification);
  }

  takePicture() async {
    String path = await _camerasManager.takePicture();
    print(path);
    PicturesManager.getExifOf(File(path));
    setState(() {
      _currentImage = Image.file(File(path));
    });
  }
}

