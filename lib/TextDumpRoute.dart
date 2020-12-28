import 'package:flutter/material.dart';

import 'package:esp32_diagnostics_app/main.dart';

class TextDumpRoute extends StatefulWidget{
  final Characteristics characteristics;
  TextDumpRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  TextRouteState createState(){
    return TextRouteState();
  }
}

class TextRouteState extends State<TextDumpRoute>{
  String text = '';

  bool running = false;

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x01;
    this.widget.characteristics.write(cmd);
  }

  Widget build(BuildContext context){
    return Scaffold(
      appBar: new AppBar(title: Text("Text Dump")),

      body: Center(
        child: Column(
          children: [
            RaisedButton(
              child: Text('Stream Logs'),

              onPressed: () async {
                while(true){
                  if(running == true){
                    break;
                  }

                  List<int> bleReadList = await this.widget.characteristics.rc.read();
                  String readingStr = new String.fromCharCodes(bleReadList);

                  setState(() {
                    text = text + readingStr;
                  });

                  //await new Future.delayed(const Duration(milliseconds: 1000));
                }
              },
            ),

            Expanded(
              flex: 1,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Text(text),
              )
            )
          ],
        )
      )
    );
  }
}
