import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsManager {
  FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  NotificationDetails _platformChannelSpecifics;

  NotificationsManager({SelectNotificationCallback onSelectNotification = _defaultOnSelectNotification}){
    _flutterLocalNotificationsPlugin = new FlutterLocalNotificationsPlugin();
// initialise the plugin. app_icon needs to be a added as a drawable resource to the Android head project
    var initializationSettingsAndroid =
    new AndroidInitializationSettings('app_icon');
    var initializationSettingsIOS = IOSInitializationSettings(
        onDidReceiveLocalNotification: null);
    var initializationSettings = InitializationSettings(
        initializationSettingsAndroid, initializationSettingsIOS);
    _flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onSelectNotification: onSelectNotification);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'your channel id', 'your channel name', 'your channel description',
        importance: Importance.Max, priority: Priority.Max, ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    _platformChannelSpecifics = NotificationDetails(
        androidPlatformChannelSpecifics, iOSPlatformChannelSpecifics);
  }

  static Future _defaultOnSelectNotification(String payload) async {
    if (payload != null) {
      print('Notification payload: ' + payload);
    }
  }

  void sendNotification(GPSLocationNotification notification){
    if(_flutterLocalNotificationsPlugin != null){
      print("Sending notification");
      _flutterLocalNotificationsPlugin.show(
          notification.id, notification.title, notification.body, _platformChannelSpecifics,
          payload: notification.payload);
    }
  }
}

class GPSLocationNotification {
  int id;
  String title;
  String body;
  String payload;

  GPSLocationNotification({@required this.id, @required this.title, @required this.body, @required this.payload});
}