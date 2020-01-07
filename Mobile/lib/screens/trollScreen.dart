import 'package:flutter/material.dart';

class TrollScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('OH SH** !!!'),
      ),
      body: Center(
        child: Image.asset("assets/images/troll.jpg", width: 500.0, height: 500.0)
        ),
      );
  }

}