import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/RouteGen.dart';
import 'package:flutter_blue/flutter_blue.dart';

void main() {
  runApp(DiagnosticsApp());
}

//class containing characteristics. An instance of this class should be passed to all diagnostic routes.
class Characteristics{
  BluetoothCharacteristic rc; //read char
  BluetoothCharacteristic wc; //write char

  Characteristics(this.rc,this.wc);

  Future<void> write(List<int> data) async {
    await wc.write(data);
    print('Wrote command ' + data[0].toString());
  }
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

  BluetoothDevice connectedDevice;
  BluetoothService customService;
  BluetoothCharacteristic readChar;
  BluetoothCharacteristic writeChar;

  String connectButtonDisplay = 'Connect';
  String connectButtonDisplayDevice = '';

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
              child: Text('Text Dump'),

              onPressed: (){
                Navigator.of(context).pushNamed('/textdump',arguments: Characteristics(readChar,writeChar));
              }
            ),

            RaisedButton(
              child: Text('ADC Graph'),
              onPressed: (){
                Navigator.of(context).pushNamed('/adc',arguments: Characteristics(readChar,writeChar));
              }
            ),

            RaisedButton(
              child: Text('State Info'),
              onPressed: (){
                Navigator.of(context).pushNamed('/state',arguments: Characteristics(readChar,writeChar));
              }
            ),

            RaisedButton(
              child: Text('Stats'),
              onPressed: (){
                Navigator.of(context).pushNamed('/stats',arguments: Characteristics(readChar,writeChar));
              }
            ),

            RaisedButton(
              child: Text('Commands'),
              onPressed: (){
                Navigator.of(context).pushNamed('/cmds',arguments: Characteristics(readChar,writeChar));
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
                Navigator.of(context).pushNamed('/connect',arguments: ConnectRouteArgs(setConnectionInfo,setConnectionService,setConnectionChars));
              }
            )
          ]
        )
      )
    );
  }

  void setConnectionInfo(BluetoothDevice x){
    setState((){
      connectedDevice = x;
      connectButtonDisplay = 'Connected';
      connectButtonDisplayDevice = connectedDevice.name;
    });
  }

  void setConnectionService(BluetoothService x){
    setState((){
      customService = x;
    });
  }

  void setConnectionChars(BluetoothCharacteristic r,BluetoothCharacteristic w){
    setState((){
      readChar = r;
      writeChar = w;
    });
  }
}

//callback functions to main route to be used by connect route
//An instance of this class should be passed as an argument to the connect route
class ConnectRouteArgs{
  Function setConnectionFunction;
  Function setServiceFunction;
  Function setCharacteristicsFunction;

  ConnectRouteArgs(Function connect,Function service,Function characteristic){
    setConnectionFunction = connect;
    setServiceFunction = service;
    setCharacteristicsFunction = characteristic;
  }
}
