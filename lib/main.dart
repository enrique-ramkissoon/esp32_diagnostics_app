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
        title: Text('ESP32 Diagnostics App'),
        backgroundColor: Colors.grey[800],
      ),

      backgroundColor: Colors.grey[800],

      body: Center(
        child: Column(
          children: [
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,

                children: <Widget>[
                  
                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.format_align_justify,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Text Dump", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],

                    onPressed: (){
                      Navigator.of(context).pushNamed('/textdump',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.timeline,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("ADC Graph", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    onPressed: (){
                      Navigator.of(context).pushNamed('/adc',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.history,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("State", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: (){
                      Navigator.of(context).pushNamed('/state',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.pie_chart,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Stats", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: (){
                      Navigator.of(context).pushNamed('/stats',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.computer,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Commands", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: (){
                      Navigator.of(context).pushNamed('/cmds',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.wifi,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Network", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: (){
                      Navigator.of(context).pushNamed('/net',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.location_searching,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Calibrate", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: (){
                      Navigator.of(context).pushNamed('/calibrate',arguments: Characteristics(readChar,writeChar));
                    }
                  ),

                  RaisedButton(
                    child: Column(
                      children: [
                        Icon(
                          Icons.exposure_zero,
                          color: Colors.green[600],
                          size: 150,
                        ),

                        Text("Tare", style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold)),
                      ]
                    ),

                    color: Colors.grey[800],
                    splashColor: Colors.grey[850],
                    
                    onPressed: () async {
                      List<int> tare = new List(1);
                      tare[0] = 0x08;

                      await writeChar.write(tare);
                    }
                  )
                ]
              ),
            ),

            RaisedButton(
              child: Column(
                children: <Widget>[
                  Text('$connectButtonDisplay'),
                  Text('$connectButtonDisplayDevice',style: TextStyle(fontSize: 9))
                ]
              ),

              color: Colors.lightGreen[800],
              splashColor: Colors.green[800],
              textColor: Colors.white,

              onPressed: (){
                Navigator.of(context).pushNamed('/connect',arguments: ConnectRouteArgs(setConnectionInfo,setConnectionService,setConnectionChars));
              }
            )
          ],
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
