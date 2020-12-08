import 'package:flutter/material.dart';
import 'package:stack_pay/withUI.dart';
import 'package:stack_pay/withoutUI.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    color: Colors.blue,
                    onPressed: () {
                      Navigator.push(
                          context, MaterialPageRoute(builder: (BuildContext context) => WithUI()));
                    },
                    child: Text("WithUi"),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  width: double.infinity,
                  height: 50,
                  child: RaisedButton(
                    color: Colors.red,
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (BuildContext context) => WithoutUI()));
                    },
                    child: Text("WithoutUi"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
