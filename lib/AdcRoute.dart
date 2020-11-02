import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class AdcRoute extends StatefulWidget{

  final BluetoothCharacteristic readChar;

  AdcRoute({Key key, @required this.readChar}) : super(key: key);

  @override
  AdcRouteState createState(){
    return AdcRouteState();
  } 
}

class AdcRouteState extends State<AdcRoute>{

  String lastReading = '';

  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('ADC Graph')),

        body: Center(
          child: Column(
            children: <Widget>[
              Text(lastReading),
              FlatButton(child: Text('ReadChar'), onPressed: () async{
                
                List<int> reading = await this.widget.readChar.read();

                setState((){
                  lastReading = new String.fromCharCodes(reading);
                });
              })
            ]
          )
        )
      )
    );
  }
}
