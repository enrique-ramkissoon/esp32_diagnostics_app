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
    this.widget.characteristics.write(cmd); //TODO: Properly deinitialize page.
  }

  Widget build(BuildContext context){
    return WillPopScope(
      onWillPop: () async {
        setState((){
          running = false;
        });

        List<int> stop = new List(1);
        stop[0] = 0x00;

        await this.widget.characteristics.write(stop);

        return true;
      },

      child: Scaffold(
        appBar: new AppBar(title: Text("Text Dump")),

        body: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text('Stream Logs'),

                onPressed: () async {
                  running = true;
                  while(true){
                    if(running == false){
                      break;
                    }

                    List<int> bleReadList = await this.widget.characteristics.rc.read();
                    String readingStr = new String.fromCharCodes(bleReadList);

                    setState(() {
                      text = text + readingStr;
                    });

                    List<int> ack = new List(1);
                    ack[0] = 0x1F;
                    await this.widget.characteristics.write(ack);

                    // await new Future.delayed(const Duration(milliseconds: 100));
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
      )
    );
  }
}
