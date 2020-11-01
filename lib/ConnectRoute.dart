import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectRoute extends StatefulWidget{
  Function setConnectedFunction;

  ConnectRoute({Key key,@required this.setConnectedFunction}) :super(key: key);

  @override
  ConnectRouteState createState(){
    return ConnectRouteState();    
  }
}

class ConnectRouteState extends State<ConnectRoute>{

  BluetoothDevice espDevice;

  @override
  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('Connect to Device')),

        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text('Scan'),
                onPressed: (){
                  //this.widget.setConnectedFunction('hELLO');

                  bleScan();
                }
              ),

              RaisedButton(
                child: Text('Connect to esp (temporary)'),
                onPressed: (){
                  bleConnect();
                }
              )
            ]
          )
        )
      )
    );
  }

  void bleScan(){

    HomeRoute.flutterBlue.startScan(timeout: Duration(seconds: 2));

    HomeRoute.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');

        if(r.device.name == 'ESP'){
          this.espDevice = r.device;
          print('Set esp device!');
        }
      }
    });

    HomeRoute.flutterBlue.stopScan();
  }

  void bleConnect() async{

    await this.espDevice.connect();
    this.widget.setConnectedFunction(espDevice);
  }
}
