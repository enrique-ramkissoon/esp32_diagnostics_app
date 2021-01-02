import 'package:flutter/material.dart';

import 'package:esp32_diagnostics_app/main.dart';

class StatsRoute extends StatefulWidget{
  final Characteristics characteristics;
  StatsRoute({Key key, @required this.characteristics}) : super(key: key);

  @override
  StatsRouteState createState(){
    return StatsRouteState();
  }
}

class StatsRouteState extends State<StatsRoute>{

  String text = 'Test';

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x04;
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
        appBar: new AppBar(title: Text("ESP32 Statistics")),

        body: Center(
          child: Column(
            children: [
              RaisedButton(
                child: Text('Stream Statistics'),

                onPressed: () async {

                  List<int> bleList;

                  //TASK NAMES.................................................
                  do{
                    bleList = await this.widget.characteristics.rc.read();
                  }while(bleList[0] != 0x31); //0x31 = '1'

                  String bleStr = String.fromCharCodes(bleList);
                  print(bleStr);

                  List<String> taskNames = new List();

                  for(int i=1;i<bleStr.length;i){
                    int nextTaskStart  = bleStr.indexOf('|',i);

                    if(nextTaskStart == -1){
                      break;
                    }

                    String task = bleStr.substring(i,nextTaskStart);
                    i = nextTaskStart + 1;

                    taskNames.add(task);
                  }

                  List<int> ack = new List(1);
                  ack[0] = 0x41;

                  await this.widget.characteristics.write(ack);

                  //bleList.clear();

                  //RUNTIMES.................................................
                  do{
                    bleList = await this.widget.characteristics.rc.read();
                  }while(bleList[0] != 0x31); //0x31 = '1'

                  bleStr = String.fromCharCodes(bleList);
                  print(bleStr);

                  List<String> runtimes = new List();

                  for(int i=1;i<bleStr.length;){
                    int nextRtStart = bleStr.indexOf('|',i);

                    if(nextRtStart == -1){
                      break;
                    }

                    String rt = bleStr.substring(i,nextRtStart);
                    i = nextRtStart + 1;

                    runtimes.add(rt);
                  }

                  ack[0] = 0x42;

                  await this.widget.characteristics.write(ack);

                  //bleList.clear();

                  //STACK.................................................
                  do{
                    bleList = await this.widget.characteristics.rc.read();
                  }while(bleList[0] != 0x31); //0x31 = '1'

                  bleStr = String.fromCharCodes(bleList);
                  print(bleStr);

                  List<String> stacks = new List();

                  for(int i=1;i<bleStr.length;i){
                    int nextStackStart  = bleStr.indexOf('|',i);

                    if(nextStackStart == -1){
                      break;
                    }

                    String rt = bleStr.substring(i,nextStackStart);
                    i = nextStackStart + 1;

                    stacks.add(rt);
                  }

                  if((taskNames.length != stacks.length - 1) || (taskNames.length != runtimes.length - 1)){
                    print("ERROR: Statistics Arrays are not equally sized");
                  }

                  print("Total Stack = " + stacks[0]);
                  print("Total Runtime = " + runtimes[0]);

                  for(int i=0;i<taskNames.length;i++){
                    print(taskNames[i] + "\t" + stacks[i+1] + "\t" + runtimes[i+1]);
                  }

                },
              ),

              // Expanded(
              //   flex: 1,
              //   child: SingleChildScrollView(
              //     scrollDirection: Axis.vertical,
              //     child: Text(text),
              //   )
              // )
            ],
          )
        )
      )
    );
  }
}
