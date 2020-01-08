import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';

class MemeGeneratorScreen extends StatelessWidget {
  MemeGeneratorScreen(
      {@required this.goToNextScreen, @required this.imagePath});

  final String imagePath;
  final Future<void> Function(BuildContext context) goToNextScreen;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Now make an Awesome Meme !'),
      ),
      body: Center(
        child: Column(children: [
        Container(
        margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
        child: Image.file(File(imagePath)),
        ),
          Container(
              margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
              padding: EdgeInsets.fromLTRB(25, 00, 25, 0),
              child: TextField(
                decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Enter your funny subtitle here :)',
                ),
              ),
              ),
          RaisedButton(
            child: Text('Share with your friends !'),
            onPressed: () => goToNextScreen(context),
          ),
        ]),
      ),
    );
  }
}
