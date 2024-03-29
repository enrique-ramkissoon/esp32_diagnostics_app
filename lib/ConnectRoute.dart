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

  //BluetoothDevice espDevice;
  BluetoothService serv;

  List<Widget> foundServers = new List();

  @override
  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('Connect to Device'), backgroundColor: Colors.grey[800],),

        backgroundColor: Colors.grey[800],

        body: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                color: Colors.lightGreen[800],
                splashColor: Colors.green[800],
                textColor: Colors.white,

                child: Text('Scan'),
                onPressed: (){
                  //this.widget.setConnectedFunction('hELLO');

                  bleScan();
                }
              ),

              // RaisedButton(
              //   child: Text('Connect to esp (temporary)'),
              //   onPressed: () async{
              //     await bleConnect();
              //     await bleGetService();
              //     await bleGetCharacteristics();
              //     Navigator.of(context).pop();
              //     //bleGetService();
              //   }
              // ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: foundServers.length,
                  itemBuilder: (BuildContext context, int index){
                    return Container(
                      height: 50,
                      margin : EdgeInsets.all(2),
                      child: foundServers[index],
                    );
                  }
                )
              )
            ]
          )
        )
      )
    );
  }

  void bleScan(){

    List<String> foundNames = new List();

    HomeRoute.flutterBlue.startScan(timeout: Duration(seconds: 2));

    HomeRoute.flutterBlue.scanResults.listen((results) {
      for (ScanResult r in results) {
        print('${r.device.name} found! rssi: ${r.rssi}');

        if(foundNames.contains(r.device.name)){
          continue;
        }

        String sname = r.device.name;

        foundNames.add(sname);

        if(sname.isEmpty){
          sname = "<Unnamed>";
        }

        setState((){
          foundServers.add(FoundServer(name: sname,device: r.device, mainConnect: this,));
        });

        // if(r.device.name == 'ESP'){
        //   this.espDevice = r.device;
        //   print('Set esp device!');
        // }
      }
    });

    HomeRoute.flutterBlue.stopScan();

  }

  Future<void> bleConnect(BluetoothDevice device) async{

    try{
      var ret = await device.connect(timeout: Duration(seconds: 10) ,autoConnect: false);
    }catch(TimeoutException){
      print("Connection Timed out");
      Navigator.pop(context);
    }
    this.widget.arg.setConnectionFunction(device);
    return;
  }

  Future<void> bleGetService(BluetoothDevice device) async{

    List<BluetoothService> services = await device.discoverServices();
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

    this.widget.arg.setCharacteristicsFunction(r,w);

    return;
  }
}

class FoundServer extends StatelessWidget {
  const FoundServer({
    Key key,
    this.name ,
    this.device,
    this.mainConnect
  }) : super(key: key);

  final String name;
  final BluetoothDevice device;
  final ConnectRouteState mainConnect;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(name,style: TextStyle(color: Colors.white)),
        Spacer(),
        RaisedButton(
          child: Text("Connect"),

          color: Colors.lightGreen[800],
          splashColor: Colors.green[800],
          textColor: Colors.white,

          onPressed: () async {
            await mainConnect.bleConnect(device);
            await mainConnect.bleGetService(device);
            await mainConnect.bleGetCharacteristics();
            Navigator.of(mainConnect.context).pop();
          }
        )
      ],
    );
  }
}
