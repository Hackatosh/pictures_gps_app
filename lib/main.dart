import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:exif/exif.dart';
import 'package:simple_permissions/simple_permissions.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  PermissionStatus _permissionStatus = PermissionStatus.notDetermined;
  final Permission permission = Permission.ReadExternalStorage;
  Timer timer;
  File mostRecentPicture;
  String _gpsLocationText = "Please press button to refresh";
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  NotificationDetails platformChannelSpecifics;

  @override
  initState() {
    super.initState();
    initPlatformState();
    initNotifications();
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) => checkForNewPicture());
    //
  }

  @override
  void dispose() {
    timer?.cancel();
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

  initNotifications(){
    flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.Max, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  Future onSelectNotification(String payload) async {
    if (payload != null) {
      print('notification payload: ' + payload);
    }
  }

  checkForNewPicture() async {
    print("Checking for new picture !");
    File picture = await obtainMostRecentPicture();
    if(flutterLocalNotificationsPlugin != null){
      print("Sending notification");
      flutterLocalNotificationsPlugin.show(
          0, 'plain title', 'plain body', platformChannelSpecifics,
          payload: 'item x');
    }
    if(picture.path != mostRecentPicture?.path){
      refreshGPSLocationFromPicture(picture);
    }
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
  refreshGPSLocation() async{
    File picture = await obtainMostRecentPicture();
    await refreshGPSLocationFromPicture(picture);
  }

  refreshGPSLocationFromPicture(File picture) async {
    String text = await getExifOf(picture);
    setState(() {
      _gpsLocationText = text;
      mostRecentPicture = picture;
    });
  }
}

Future<File> obtainMostRecentPicture() async {
  List<AssetPathEntity> list = await PhotoManager.getAssetPathList();
  AssetPathEntity assetPathEntity = list
      .where((AssetPathEntity entity) => entity.name == 'Camera')
      .toList()[0];
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
    if (filteredData.isEmpty) {
      result = "No GPS information found";
    } else {
      result = "";
      for (String key in filteredData.keys) {
        result += "$key (${data[key].tagType}): ${data[key]}\n";
      }
    }
  }
  print(result);
  return result;
}
