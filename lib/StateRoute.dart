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

  List<Text> macs = new List();
  List<Text> states = new List();
  List<Widget> tiles = new List();

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

                    int indexDuration = bleReadList.indexOf(0x3F,conn+1) - 2;

                    //if true then the next 6 bytes is the mac address
                    if(bleReadList[conn] == 0x3F){
                      readingStr = readingStr + "MAC Address: ";
                      readingStr = readingStr + bleReadList[conn+1].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+2].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+3].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+4].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+5].toRadixString(16) + ":";
                      readingStr = readingStr + bleReadList[conn+6].toRadixString(16) + "|";

                      conn+=7;

                      readingStr = readingStr + "Actions: ";

                      continue;
                    }

                    //the next 2 bytes is the duration
                    if(conn == indexDuration){
                      int dur1 = bleReadList[conn];
                      int dur2 = bleReadList[conn+1];

                      int duration = (dur1*255) + dur2;

                      readingStr  = readingStr + "Duration: " + duration.toString() + "s!!";

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

                    if(bleReadList[conn] == 0x04){
                      readingStr = readingStr + "Viewed Stats,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList[conn] == 0x51){
                      readingStr = readingStr + "Executed Command: Check HX711 Connection,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList[conn] == 0x52){
                      readingStr = readingStr + "Executed Command: Verify HX711 Sample Rate,\n";
                      conn+=1;
                      continue;
                    }

                    if(bleReadList[conn] == 0x06){
                      readingStr = readingStr + "Viewed Network Configuration,\n";
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

                  //text contains the full state info. connections separated by ||
                  //the following code extracts this data into discrete lists

                  String macStr;
                  String actionsStr;

                  for(int iExt=0;iExt<text.length;){

                    print("iExt = "+iExt.toString());

                    if(text.indexOf("|",iExt) != -1){
                      macStr = text.substring(iExt,text.indexOf("|",iExt));
                      iExt = text.indexOf("|",iExt) + 1;

                      if(text.indexOf("!!",iExt) != -1){
                        actionsStr = text.substring(iExt,text.indexOf("!!",iExt));
                        iExt = text.indexOf("!!",iExt) + 2;

                        setState((){
                          tiles.add(ConnectionHistory(mac: macStr, hist: actionsStr));
                        });

                      }else{
                        actionsStr = text.substring(iExt);

                        setState((){
                          tiles.add(ConnectionHistory(mac: macStr, hist: actionsStr));
                        });

                        break;
                      }
                    }
                  }
                },
              ),

              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: tiles.length,
                  itemBuilder: (BuildContext context, int index){
                    return tiles[index];
                  }
                )
              )
            ],
          )
        )
      )
    );
  }
}

class ConnectionHistory extends StatelessWidget{
  const ConnectionHistory({
    Key key,
    this.mac,
    this.hist,
  }) : super(key: key);

  final String mac;
  final String hist;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(mac),
      children: [
        Text(hist),
      ],
    );
  }
}
