import 'package:flutter/material.dart';

import 'package:esp32_diagnostics_app/main.dart';

class StateRoute extends StatefulWidget{
  final Characteristics characteristics;
  StateRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  StateRouteState createState(){
    return StateRouteState();
  }
}

class StateRouteState extends State<StateRoute>{
  String text = '';

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x03;
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
        appBar: new AppBar(title: Text("State Information")),

        body: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text('Download State'),

                onPressed: () async {
                  List<int> bleReadList = await this.widget.characteristics.rc.read();
                  String readingStr = '';

                  for(int conn = 0;conn < bleReadList.length;){
                    print(conn.toString());

                    if((bleReadList[conn] == 0x3F) && (bleReadList[conn+1] == 0x3F)){
                      conn+=1;
                      continue;
                    }

                    int index_duration = bleReadList.indexOf(0x3F,conn+1) - 2;

                    //if true then the next 6 bytes is the mac address
                    if(bleReadList[conn] == 0x3F){
                      readingStr = readingStr + "MAC Address: ";
                      readingStr = readingStr + bleReadList[conn+1].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+2].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+3].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+4].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+5].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+6].toRadixString(16) + "\n";

                      conn+=7;

                      readingStr = readingStr + "Actions: ";

                      continue;
                    }

                    //the next 2 bytes is the duration
                    if(conn == index_duration){
                      int dur1 = bleReadList[conn];
                      int dur2 = bleReadList[conn+1];

                      int duration = (dur1*255) + dur2;

                      readingStr  = readingStr + "Duration: " + duration.toString() + "s\n\n";

                      conn+=2;
                      continue;
                    }

                    if(bleReadList[conn] == 0x01){
                      readingStr = readingStr + "Viewed Text Dump,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList[conn] == 0x02){
                      readingStr = readingStr + "Viewed ADC Graph,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList[conn] == 0x03){
                      readingStr = readingStr + "Viewed State,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList.indexOf(0x3F,conn+1) == -1)
                    {
                      break;
                    }
                  }

                  readingStr = readingStr + "\n";

                  setState(() {
                    text = text + readingStr;
                  });
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
