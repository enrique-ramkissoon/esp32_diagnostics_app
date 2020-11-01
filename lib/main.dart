import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/RouteGen.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(DiagnosticsApp());
}

class DiagnosticsApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'ESP32 Diagnostics App',
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/',
        onGenerateRoute: RouteGen.generate
    );
  }
}

class HomeRoute extends StatefulWidget{

  static final FlutterBlue flutterBlue = FlutterBlue.instance;


  @override
  HomeRouteState createState(){
    return(HomeRouteState());
  }
}

class HomeRouteState extends State<HomeRoute>{

  static BluetoothDevice connectedDevice;

  String connectButtonDisplay = 'Connect';
  String connectButtonDisplayDevice = 'placeholder';

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        title: Text('ESP32 Diagnostics App')
      ),

      body: Center(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text('ADC Graph'),
              onPressed: (){
                Navigator.of(context).pushNamed('/adc',arguments: 'ADC Click');
              }
            ),

            Spacer(),

            RaisedButton(
              child: Column(
                children: <Widget>[
                  Text('$connectButtonDisplay'),
                  Text('$connectButtonDisplayDevice',style: TextStyle(fontSize: 9))
                ]
              ),

              onPressed: (){
                Navigator.of(context).pushNamed('/connect',arguments: this.setConnectionInfo);
              }
            )
          ]
        )
      )
    );
  }

  void setConnectionInfo(String x){
    print('Working! ' + x);
  }
}
