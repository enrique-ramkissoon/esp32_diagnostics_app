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

  double cpuUtil = -1;
  int freeHeap = -1;

  List<String> taskNames = new List();
  List<String> runtimes = new List();
  List<String> stacks = new List();

  List<DataRow> tableRows = new List();

  int idleIndex = 0;

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
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              RaisedButton(
                child: Text('Download Statistics'),

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

                  setState((){
                    for(int i=0;i<taskNames.length;i++)
                    {
                      if(taskNames[i] == "IDLE"){
                        idleIndex = i;
                        break;
                      }
                    }

                    cpuUtil = 100 - (100*( ((double.parse(runtimes[idleIndex+1]))) / (double.parse(runtimes[0])) ));
                    freeHeap = int.parse(stacks[0]);

                    tableRows.clear();

                    for(int i=0;i<taskNames.length;i++){

                      double taskCpuUtil = 100* ((double.parse(runtimes[i+1]))/(double.parse(runtimes[0])));
                      double taskRuntimeMs = int.parse(runtimes[i+1]) / 1000;

                      tableRows.add(new DataRow(cells:[DataCell(Text(taskNames[i])),DataCell(Text(taskRuntimeMs.toStringAsFixed(0))),DataCell(Text(stacks[i+1])), DataCell(Text(taskCpuUtil.toStringAsFixed(2)))]));
                    }
                  });

                },
              ),

              Text("CPU Utilization: " + cpuUtil.toString(), textAlign: TextAlign.left),
              Text("Heap Available: " + freeHeap.toString(), textAlign: TextAlign.left),

              Text('Tasks Runtime and CPU Utilization'),

              DataTable(
                columnSpacing: 2,
                columns: [
                  DataColumn(
                    label: Text('Task',style: TextStyle(fontWeight: FontWeight.bold))
                  ),

                  DataColumn(
                    label: Text('Run\nTime\n/ms',style: TextStyle(fontWeight: FontWeight.bold))
                  ),

                  DataColumn(
                    label: Text('Stack\nRemaining\n/bytes',style: TextStyle(fontWeight: FontWeight.bold))
                  ),

                  DataColumn(
                    label: Text('CPU\nUtilization\n/%',style: TextStyle(fontWeight: FontWeight.bold))
                  ),
                ],

                rows: tableRows
              )
            ],
          )
        )
      )
    );
  }
}
