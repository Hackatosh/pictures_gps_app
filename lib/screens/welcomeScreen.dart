import 'dart:async';

import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

class WelcomeScreen extends StatelessWidget {
  WelcomeScreen({@required this.goToNextScreen});
  final Future<void>  Function(BuildContext context) goToNextScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Awesome Meme !'),
      ),
      body: Center(
        child: RaisedButton(
          child: Text('Turn latest picture into awesome meme and share with friends !'),
          onPressed: () => _onPressed(context),
        ),
      ),
    );
  }

  Future<void> _onPressed(BuildContext context) async {
    PermissionStatus permissionStatus;
    if(await SimplePermissions.getPermissionStatus(Permission.ReadExternalStorage) != PermissionStatus.authorized){
      permissionStatus = await SimplePermissions.requestPermission(Permission.ReadExternalStorage);
    } else {
      permissionStatus = PermissionStatus.authorized;
    }
    if(permissionStatus == PermissionStatus.authorized){
      goToNextScreen(context);
    } else {
      _showDialog(context);
    }
  }

  void _showDialog(BuildContext context) {
    // flutter defined function
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("You must accept all permissions !"),
          content: new Text("Please accept them, we are trustworthy <3"),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Close"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}