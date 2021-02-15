import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';

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

  double lastMass = -1;
  double lastCalFac = -1;
  double lastAdc = -1;
  
  String lastAdcStr = '-1';
  String lastMassStr = '-1';
  String lastCalFacStr = '-1';

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
        appBar: new AppBar(title: Text("Calibrate"),backgroundColor: Colors.grey[800],),

        backgroundColor: Colors.grey[800],

        body: Center(
          child: Column(
            children: [
              Text('Standard Mass 1: ', style: TextStyle(color: Colors.white)), 
              TextField(controller: sm1Controller, cursorColor: Colors.white, style: TextStyle(color: Colors.white)),
              Text('Standard Mass 2: ', style: TextStyle(color: Colors.white)), 
              TextField(controller: sm2Controller, cursorColor: Colors.white, style: TextStyle(color: Colors.white)),

              RaisedButton(
                child: Text('View Calibration Statistics', style: TextStyle(color: Colors.white)),
                color: Colors.green[600],
                onPressed: (){
                  startReadTask();
                }
              ),

              RaisedButton(
                child: Text('Start Calibration Process', style: TextStyle(color: Colors.white)),
                color: Colors.green[600],
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
              ),

              Spacer(),

              Text("Mass, g = " + lastMassStr,style: TextStyle(color: Colors.white)),
              Text("Sensitivity, g/ADC val = " + lastCalFacStr,style: TextStyle(color: Colors.white)),
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
          backgroundColor: Colors.green[800],
          title: Text('Step 1', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Place Standard Mass 1 on the Scale', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next', style: TextStyle(color: Colors.white)),
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

          backgroundColor: Colors.green[800],

          title: Text('Step 2', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Place Standard Mass 2 on the Scale', style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Next', style: TextStyle(color: Colors.white)),
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

          backgroundColor: Colors.green[800],

          title: Text('Step 3', style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Calculated Calibration Factor = ' + cf.toString(), style: TextStyle(color: Colors.white)),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Calibrate', style: TextStyle(color: Colors.white)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),

            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.white)),
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

  void startReadTask() async {
    while(true){
      List<int> bleRead = await this.widget.characteristics.rc.read();
      String readStr = new String.fromCharCodes(bleRead);
      String fixedStr = readStr.substring(0,readStr.indexOf(String.fromCharCode(0)));

      print("BleRead = "+fixedStr);

      List<String> members = fixedStr.split("|");

      setState((){
        lastAdcStr = members[0];
        lastCalFacStr = members[1];
        lastMassStr = members[2];
      });

      await new Future.delayed(const Duration(milliseconds : 100));
    }
  }
}
