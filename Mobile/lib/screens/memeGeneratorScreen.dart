import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class MemeGeneratorScreen extends StatelessWidget {
  MemeGeneratorScreen({@required this.goToNextScreen, @required this.imagePath});

  final String imagePath;
  final Future<void> Function(BuildContext context) goToNextScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Awesome Meme !'),
      ),
      body: Center(
        child: Column(children: [
          TextField(),
          RaisedButton(
            child: Text(
                'Share with your friends !'),
            onPressed: () => goToNextScreen(context),
          ),
          Image.file(File(imagePath)),
        ]),
      ),
    );
  }
}
