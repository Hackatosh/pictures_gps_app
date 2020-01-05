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
  // Misc
  PermissionStatus _permissionStatus = PermissionStatus.notDetermined;
  final Permission permission = Permission.Camera;
  Timer _timer;
  // Managers
  NotificationsManager _notificationsManager;
  PicturesManager _picturesManager;
  CamerasManager _camerasManager;
  // UI relatives
  Picture _pictureToShow;


  @override
  initState() {
    super.initState();
    initPermissionStatus();
    _camerasManager = CamerasManager();
    _notificationsManager = NotificationsManager();
    _picturesManager =
        PicturesManager(refreshPictureCallback, false);
    // Uncomment to reactivate automatic shots
    //_timer = Timer.periodic(Duration(seconds: 15), (Timer t) => takePicture());
  }

  @override
  void dispose() {
    _picturesManager.dispose();
    _timer?.cancel();
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

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [
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
          onPressed: takePicture, child: new Text("Take picture")),
    ];
    widgets.addAll(
    _pictureToShow == null ?
    [new Text("Please take a picture")] :
    [
    new Text(_pictureToShow.exifInfos),
    _pictureToShow.image,
    ]);
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('GPS Location Leaker'),
        ),
        body: new Center(
          child: new Column(children: widgets),
        ),
      ),
    );
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }

  triggerPicturesManagerUpdate() async {
    _picturesManager
        .updateMostRecentPicture(refreshPictureCallback);
  }

  refreshPictureCallback(Picture picture) async {
    setState(() {
      _pictureToShow = picture;
    });
    GPSLocationNotification notification = new GPSLocationNotification(
        id: 0,
        title: "GPS Location updated !",
        body: "A new photo has triggered the GPS location update",
        payload: picture.exifInfos);
    _notificationsManager.sendNotification(notification);
  }

  takePicture() async {
    Picture picture = await _camerasManager.takePicture();
    setState(() {
      _pictureToShow = picture;
    });
  }

}
