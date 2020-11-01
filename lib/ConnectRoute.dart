import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';

class ConnectRoute extends StatefulWidget{
  Function setConnectedFunction;

  ConnectRoute({Key key,@required this.setConnectedFunction}) :super(key: key);

  @override
  ConnectRouteState createState(){
    return ConnectRouteState();    
  }
}

class ConnectRouteState extends State<ConnectRoute>{
  @override
  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('Connect to Device')),

        body: Center(
          child: RaisedButton(
            child: Text('Scan and Connect to ESP (temporary)'),
            onPressed: (){
              this.widget.setConnectedFunction('hELLO');
            }
          )
        )
      )
    );
  }
}
