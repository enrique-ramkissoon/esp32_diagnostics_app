import 'package:flutter/material.dart';

import 'package:esp32_diagnostics_app/main.dart';

class CommandsRoute extends StatefulWidget{
  final Characteristics characteristics;
  CommandsRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  CommandsRouteState createState(){
    return CommandsRouteState();
  }
}

class CommandsRouteState extends State<CommandsRoute>{

  String verifyConnectResult = '';
  String verifySampleRateResult = '';

  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        List<int> stop = new List(1);
        stop[0] = 0x00;

        this.widget.characteristics.write(stop);

        return true;
      },

      child: Scaffold(
        appBar: new AppBar(title: Text("Commands")),

        body: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text('Verify HX711 Connection'),

                onPressed: () async {
                  List<int> cmd = new List(1);
                  cmd[0] = 0x51;

                  this.widget.characteristics.write(cmd);

                  await new Future.delayed(const Duration(milliseconds : 1000));

                  List<int> bleRead = await this.widget.characteristics.rc.read();

                  if(bleRead[0] == 0x00){
                    setState((){
                      verifyConnectResult = 'HX711 Disconnected';
                    });
                  }else{
                    setState((){
                      verifyConnectResult = 'HX711 Connected';
                    });
                  } 
                },
              ),

              Text(verifyConnectResult),

              RaisedButton(
                child: Text('Verify HX711 Sample Rate'),

                onPressed: () async {
                  List<int> cmd = new List(1);
                  cmd[0] = 0x52;

                  this.widget.characteristics.write(cmd);

                  await new Future.delayed(const Duration(milliseconds : 3000));

                  List<int> bleRead = await this.widget.characteristics.rc.read();

                  if(bleRead[0] == 0x00){
                    setState((){
                      verifySampleRateResult = 'Unable to Calculate Sample Rate. HX711 possibly disconnected';
                    });
                  }else{

                    int samplePeriod = bleRead[0];

                    double sampleRate = 1 / ((samplePeriod.toDouble()) / 1000);

                    setState((){
                      verifySampleRateResult = 'Calculated HX711 Sample Rate is ' + sampleRate.toStringAsFixed(4);
                    });
                  }
                },
              ),

              Text(verifySampleRateResult),
            ],
          )
        )
      )
    );
  }
}
