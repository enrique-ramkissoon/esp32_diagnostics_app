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
  BluetoothService serv;

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
                  await bleGetService();
                  await bleGetCharacteristics();
                  Navigator.of(context).pop();
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

  Future<void> bleGetService() async{

    List<BluetoothService> services = await this.espDevice.discoverServices();
    services.forEach((service){
      if(service.uuid.toString() == 'c6f2d9e3-49e7-4125-9014-bfc6d669ff00'){
        print('Service UUID found');
        this.widget.arg.setServiceFunction(service);
        serv = service;
      }
    });

    return;
  }

  Future<void> bleGetCharacteristics() async{
    var characteristics = serv.characteristics;

    BluetoothCharacteristic r;
    BluetoothCharacteristic w;

    for(BluetoothCharacteristic c in characteristics) {
      if(c.uuid.toString() == 'c6f2d9e3-49e7-4125-9014-bfc6d669ff01'){
        r = c;
        //List<int> value = await c.read();
        //print(value);
        print('Set read char');
      }
      if(c.uuid.toString() == 'c6f2d9e3-49e7-4125-9014-bfc6d669ff02'){
        w = c;
        print('Set write char');
      }
    }

    return;
  }
}
