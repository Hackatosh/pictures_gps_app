import 'package:flutter/material.dart';

class TrollScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Awesome Meme !'),
      ),
      body: Center(
        child: Image.asset("assets/images/troll.jpg", width: 300.0, height: 300.0)
        ),
      );
  }

}