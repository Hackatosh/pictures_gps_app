import 'package:flutter/material.dart';

class SetupScreen extends StatefulWidget {
  final Future<void> Function(BuildContext context, String url) goToNextScreen;

  const SetupScreen({Key key, @required this.goToNextScreen}) : super(key: key);

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
              Container(
                margin: EdgeInsets.fromLTRB(40, 40, 40, 30),
                padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                decoration: BoxDecoration(
                    color: Colors.black12,
                    border: Border.all(
                      color: Colors.green,
                      width: 4.0,
                    ),
                    borderRadius: new BorderRadius.all(Radius.circular(10.0))),
                child: Text(
                  "Please enter the NSA server's IP",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.green,
                    //fontFamily: 'Dokdo',
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.fromLTRB(40, 40, 40, 30),
                  padding: EdgeInsets.fromLTRB(25, 10, 25, 10),
                  child: TextField(
                    onSubmitted: (String value) =>
                        widget.goToNextScreen(context, value),
                  )),
            ],
          ),
        ));
  }
}
