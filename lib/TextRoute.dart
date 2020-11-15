import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';

class TextRoute extends StatefulWidget{

  final BluetoothCharacteristic readLogChar;

  TextRoute({Key key, @required this.readLogChar}) : super(key: key);

  @override
  TextRouteState createState(){
    return TextRouteState();
  } 
}

class TextRouteState extends State<TextRoute>{
  String text = '';

  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: new AppBar(title: Text("TextDump")),

        body: Center(
          child: Column(
            children: [
              RaisedButton(child: Text("Download Logs"),onPressed: () async {
                List<int> bleReadLogs = await this.widget.readLogChar.read();
                String readingStr = new String.fromCharCodes(bleReadLogs);

                //String fixedReadingStr = readingStr.substring(0,readingStr.indexOf(String.fromCharCode(0)));

                setState((){
                  text = readingStr;
                });

              }),

              Text(text)
            ],
          )
        )
      )
    );
  }
}
