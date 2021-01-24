import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:esp32_diagnostics_app/main.dart';

class CalibrateRoute extends StatefulWidget{
  final Characteristics characteristics;
  CalibrateRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  CalibrateState createState(){
    return CalibrateState();
  }
}

class CalibrateState extends State<CalibrateRoute>{

  TextEditingController sm1Controller = new TextEditingController();
  TextEditingController sm2Controller = new TextEditingController();

  double calibrationFactor = -1;

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x07;
    this.widget.characteristics.write(cmd);
  }

  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        List<int> stop = new List(1);
        stop[0] = 0x00;

        this.widget.characteristics.write(stop);

        return true;
      },

      child: Scaffold(
        appBar: new AppBar(title: Text("Calibrate")),

        body: Center(
          child: Column(
            children: [
              Text('Standard Mass 1: '), 
              TextField(controller: sm1Controller,),
              Text('Standard Mass 2: '), 
              TextField(controller: sm2Controller,),


              RaisedButton(
                child: Text('Start Calibration Process'),
                onPressed: () async {
                  await step1();
                  
                  List<int> bleRead1 = await this.widget.characteristics.rc.read();

                  String readStr1 = new String.fromCharCodes(bleRead1);
                  String fixedStr1 = readStr1.substring(0,readStr1.indexOf(String.fromCharCode(0)));
                  print("Str1 " + fixedStr1);

                  int adcOut1 = int.parse(fixedStr1.trim());

                  await step2();

                  List<int> bleRead2 = await this.widget.characteristics.rc.read();
                  String readStr2 = new String.fromCharCodes(bleRead2);
                  String fixedStr2 = readStr2.substring(0,readStr2.indexOf(String.fromCharCode(0)));

                  int adcOut2 = int.parse(fixedStr2.trim());

                  String sm1 = sm1Controller.text;
                  String sm2 = sm2Controller.text;

                  double sm1d = double.parse(sm1);
                  double sm2d = double.parse(sm2);

                  calibrationFactor = (sm2d - sm1d) / (adcOut2.toDouble() - adcOut1.toDouble());

                  await step3(calibrationFactor);

                  if(calibrationFactor == -1){
                    print("Cancelling calibration");
                  }else{
                    String cfStr = calibrationFactor.toString();

                    List<int> cfChars = utf8.encode(cfStr);

                    this.widget.characteristics.write(cfChars);
                  }
                },
              )
            ],
          )
        )
      )
    );
  }


  Future<void> step1() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Step 1'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Place Standard Mass 1 on the Scale'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  Future<void> step2() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Step 2'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Place Standard Mass 2 on the Scale'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> step3(double cf) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Step 3'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Calculated Calibration Factor = ' + cf.toString()),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Calibrate'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                calibrationFactor = -1;
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
