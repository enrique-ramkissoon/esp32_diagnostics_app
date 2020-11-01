import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';
import 'package:flutter_blue/flutter_blue.dart';

class ConnectRoute extends StatefulWidget{
  final ConnectRouteArgs arg;
  ConnectRoute({Key key,@required this.arg}) :super(key: key);

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
                onPressed: () async{
                  await bleConnect();
                  bleGetService();
                  
                  //bleGetService();
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

  Future<void> bleConnect() async{

    var ret = await this.espDevice.connect();
    this.widget.arg.setConnectionFunction(espDevice);
    return ret;
  }

  void bleGetService() async{

    List<BluetoothService> services = await this.espDevice.discoverServices();
    services.forEach((service){
      if(service.uuid.toString() == 'c6f2d9e3-49e7-4125-9014-bfc6d669ff00'){
        print('Service UUID found');
        this.widget.arg.setServiceFunction(service);
      }
    });
  }
}
