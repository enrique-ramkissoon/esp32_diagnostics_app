import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/RouteGen.dart';

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
  @override
  HomeRouteState createState(){
    return(HomeRouteState());
  }
}

class HomeRouteState extends State<HomeRoute>{
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
                Navigator.of(context).pushNamed('/adc',arguments: null);
              }
            ),
          ]
        )
      )
    );
  }
}
