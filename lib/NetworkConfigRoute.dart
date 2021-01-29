import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:esp32_diagnostics_app/main.dart';

class NetworkConfigRoute extends StatefulWidget{
  final Characteristics characteristics;
  NetworkConfigRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  NetworkConfigState createState(){
    return NetworkConfigState();
  }
}

class NetworkConfigState extends State<NetworkConfigRoute>{

  TextEditingController ssidController = new TextEditingController();
  TextEditingController pwController = new TextEditingController();

  String rssi = "";
  String ch = "";

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x06;
    this.widget.characteristics.write(cmd);
  }

  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        List<int> stop = new List(1);
        stop[0] = 0x00;

        this.widget.characteristics.write(stop);

        return true;
      },

      child: Scaffold(
        appBar: new AppBar(title: Text("Network Configuration")),

        body: Center(
          child: Column(
            children: [
              Text('SSID: '), 
              TextField(controller: ssidController,),
              Text('Password: '), 
              TextField(controller: pwController, obscureText: true,),


              RaisedButton(
                child: Text('Flash Credentials'),
                onPressed: () async {
                  String ssid = ssidController.text;
                  String pw = pwController.text;

                  ssid = ssid.trim();
                  pw = pw.trim();

                  List<int> prefixSSID = new List(1);
                  List<int> prefixPW = new List(1);

                  prefixSSID[0] = 0x41;
                  prefixPW[0] = 0x42;

                  List<int> ssidBytes = prefixSSID + utf8.encode(ssid);
                  List<int> pwBytes = prefixPW + utf8.encode(pw);

                  this.widget.characteristics.write(ssidBytes);

                  await new Future.delayed(const Duration(milliseconds : 3000));

                  this.widget.characteristics.write(pwBytes);

                  await new Future.delayed(const Duration(milliseconds : 3000));

                  List<int> bleRead = await this.widget.characteristics.rc.read();

                  String readStr = String.fromCharCodes(bleRead);
                  String readStrFixed = readStr.substring(0,readStr.indexOf(String.fromCharCode(0)));

                  String rel_ssi = readStrFixed.substring(0,readStr.indexOf('|'));
                  String wifi_ch = readStrFixed.substring(readStr.indexOf('|')+1);

                  setState(() {
                    rssi = rel_ssi;
                    ch = wifi_ch;
                  });
                  
                },
              ),

              Text(ssidController.text),
              Text("RSSI: " + rssi),
              Text("Channel: " + ch),
            ],
          )
        )
      )
    );
  }
}
