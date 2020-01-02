import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
  final Permission permission = Permission.ReadExternalStorage;
  String _gpsLocationText = "Please press button to refresh";
  NotificationsManager notificationsManager;
  PicturesManager picturesManager;

  @override
  initState() {
    super.initState();
    initPlatformState();
    notificationsManager = NotificationsManager();
    picturesManager = PicturesManager(refreshGPSLocationFromPictureCallback, true);
  }

  @override
  void dispose() {
    picturesManager.dispose();
    super.dispose();
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
            new Text(
                'Status of permission READ_EXTERNAL_STORAGE : $_permissionStatus'),
            new RaisedButton(
                onPressed: requestPermission,
                child: new Text("Request permission")),
            new RaisedButton(
                onPressed: triggerPicturesManagerUpdate,
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

  triggerPicturesManagerUpdate() async{
    picturesManager.updateMostRecentPicture(refreshGPSLocationFromPictureCallback);
  }

  refreshGPSLocationFromPictureCallback(String gpsInfos) async {
    setState(() {
      _gpsLocationText = gpsInfos;
    });
    GPSLocationNotification notification = new GPSLocationNotification(id: 0, title: "GPS Location updated !", body: "A new photo has triggered the GPS location update", payload: gpsInfos);
    notificationsManager.sendNotification(notification);
  }

}

