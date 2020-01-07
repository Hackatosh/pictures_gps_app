import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pictures_gps_app/old/cameras.dart';

import 'package:simple_permissions/simple_permissions.dart';

import 'customTask.dart';
import 'notifications.dart';
import '../managers/pictures.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // Misc
  PermissionStatus _permissionStatus = PermissionStatus.notDetermined;
  final Permission permission = Permission.Camera;
  CustomTask _watchCameraFolderTask;
  CustomTask _takeAutomaticPictureTask;
  // Managers
  NotificationsManager _notificationsManager;
  // UI relatives
  Picture _pictureToShow;


  @override
  initState() {
    super.initState();
    initPermissionStatus();
    _notificationsManager = NotificationsManager();
    // Uncomment to reactivate automatic shots
    _watchCameraFolderTask = CustomTask(Duration(seconds: 5), (Timer timer) => refreshFromCameraFolder());
    _takeAutomaticPictureTask = CustomTask(Duration(seconds: 15), (Timer timer) => takePicture());
  }

  @override
  void dispose() {
    _watchCameraFolderTask.dispose();
    _takeAutomaticPictureTask.dispose();
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
          onPressed: refreshFromCameraFolder,
          child: new Text("Find latest picture from camera")),
      new RaisedButton(
          onPressed: _watchCameraFolderTask.start,
          child: new Text("Launch camera folder watcher")),
      new RaisedButton(
          onPressed: _watchCameraFolderTask.stop,
          child: new Text("Stop camera folder watcher")),
      new RaisedButton(
          onPressed: _takeAutomaticPictureTask.start,
          child: new Text("Start automatic pictures")),
      new RaisedButton(
          onPressed: _takeAutomaticPictureTask.stop,
          child: new Text("Stop automatic pictures")),
      new RaisedButton(
          onPressed: takePicture, child: new Text("Take picture")),
    ];
    widgets.addAll(
    _pictureToShow == null ?
    [new Text("Please take a picture")] :
    [
    new Text(_pictureToShow.exifInfos.toString()),
    _pictureToShow.image,
    ]);

    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('GPS Location Leaker'),
        ),
        body: new Center(
        child: new SingleChildScrollView(
          child: new Column(children: widgets),
        ),
        ),
      ),
    );
  }

  requestPermission() async {
    final res = await SimplePermissions.requestPermission(permission);
    print("permission request result is " + res.toString());
  }

  refreshFromCameraFolder() async {
    refreshPictureFrom(await PicturesManager.obtainMostRecentFromCamera());
  }

  takePicture() async {
    refreshPictureFrom(await CamerasManager.getPictureFromCamera());
  }

  refreshPictureFrom(Picture picture) async {
    setState(() {
      _pictureToShow = picture;
    });
    GPSLocationNotification notification = new GPSLocationNotification(
        id: 0,
        title: "GPS Location updated !",
        body: "A new photo has triggered the GPS location update",
        payload: picture.exifInfos.toString());
    _notificationsManager.sendNotification(notification);
  }

}
