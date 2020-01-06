import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  final Future<void>  Function(BuildContext context, String ip) goToNextScreen;

  const SetupScreen({Key key,@required this.goToNextScreen}) : super(key: key);

  @override
  _SetupScreenState createState() => new _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Spooky h@ck3rs settings'),
        ),
        body: Center(
          child: Column(
            children: [
              Text("Please enter your chinese ip"),
              TextField(
                onSubmitted:(String value) => widget.goToNextScreen(context,value),
              )
            ],
          ),
        ));
  }
}
