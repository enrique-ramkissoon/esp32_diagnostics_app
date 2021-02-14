import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;

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

  List<StatsDatum> cpuData = new List();
  List<charts.Series> statSeries;

  List<DataRow> tableRows = new List();

  int idleIndex = 0;

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x04;
    this.widget.characteristics.write(cmd);
  }

  StatsRouteState(){
    statSeries = createListData();
  }

  List<charts.Series<StatsDatum, String>> createListData() {
    cpuData.add(new StatsDatum('no_data', 100));

    return [
      new charts.Series<StatsDatum, String>(
        id: 'Stats',
        domainFn: (StatsDatum stat, _) => stat.task,
        measureFn: (StatsDatum stat, _) => stat.cpu,
        data: cpuData,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (StatsDatum stat, _) => (stat.task + ' ' + stat.cpu.toStringAsFixed(1)),
      )
    ];
  }

  List<charts.Series<StatsDatum, String>> updateListData() {
    return [
      new charts.Series<StatsDatum, String>(
        id: 'Stats',
        domainFn: (StatsDatum stat, _) => stat.task,
        measureFn: (StatsDatum stat, _) => stat.cpu,
        data: cpuData,
        // Set a label accessor to control the text of the arc label.
        labelAccessorFn: (StatsDatum stat, _) => (stat.task + ' ' + stat.cpu.toStringAsFixed(1) + '%'),

        colorFn: (_,index){
          return charts.MaterialPalette.green.makeShades(20)[index];
        }
      )
    ];
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
        appBar: new AppBar(title: Text("ESP32 Statistics"),backgroundColor: Colors.grey[800],),

        backgroundColor: Colors.grey[800],

        body: Center(
          child: ListView(
            scrollDirection: Axis.vertical,
            children: [
              RaisedButton(
                child: Text('Download Statistics',style: TextStyle(color: Colors.white)),

                color: Colors.green[600],

                onPressed: () async {

                  await new Future.delayed(const Duration(seconds : 2)); 

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

                    cpuUtil = 100 - (100*( ((double.parse(runtimes[idleIndex+1], (_){return 0;}))) / (double.parse(runtimes[0], (_){return 0;})) ));
                    freeHeap = int.parse(stacks[0]);

                    tableRows.clear();
                    cpuData.clear();

                    //update table and pie chart

                    for(int i=0;i<taskNames.length;i++){

                      double taskCpuUtil = 100* ((double.parse(runtimes[i+1], (_){return 0;}))/(double.parse(runtimes[0], (_){return 0;})));
                      double taskRuntimeMs = int.parse(runtimes[i+1]) / 1000;

                      tableRows.add(new DataRow(cells:[DataCell(Text(taskNames[i], style: TextStyle(color: Colors.white))),
                      DataCell(Text(taskRuntimeMs.toStringAsFixed(0), style: TextStyle(color: Colors.white))),
                      DataCell(Text(stacks[i+1], style: TextStyle(color: Colors.white))), 
                      DataCell(Text(taskCpuUtil.toStringAsFixed(2), style: TextStyle(color: Colors.white)))]));

                      if(taskNames[i] != "IDLE")
                      {
                        cpuData.add(new StatsDatum(taskNames[i],taskCpuUtil));
                        statSeries = updateListData();
                      }

                    }
                  });

                },
              ),

              Text("CPU Utilization: " + cpuUtil.toString(), textAlign: TextAlign.left, style: TextStyle(color: Colors.white)),
              Text("Heap Available: " + freeHeap.toString(), textAlign: TextAlign.left, style: TextStyle(color: Colors.white)),

              Text('Tasks Runtime and CPU Utilization', style: TextStyle(color: Colors.white)),

              DataTable(
                columnSpacing: 2,
                columns: [
                  DataColumn(
                    label: Text('Task',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                  ),

                  DataColumn(
                    label: Text('Run\nTime\n/ms',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                  ),

                  DataColumn(
                    label: Text('Stack\nRemaining\n/bytes',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                  ),

                  DataColumn(
                    label: Text('CPU\nUtilization\n/%',style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white))
                  ),
                ],

                rows: tableRows,

                dataRowColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {

                  if (states.contains(MaterialState.selected))
                    return Colors.green[600];

                  return Colors.grey[800];  // Use the default value.
                }),
              ),

              Container(
                height: 300,
                width: 300,
                //child: Expanded(
                  child: charts.PieChart(
                    statSeries,
                    animate: false,
                    defaultRenderer: new charts.ArcRendererConfig(arcRendererDecorators: [
                        new charts.ArcLabelDecorator(
                            outsideLabelStyleSpec: new charts.TextStyleSpec(fontSize: 10, color: charts.MaterialPalette.white),
                            labelPosition: charts.ArcLabelPosition.outside,
                            leaderLineColor: charts.MaterialPalette.white,
                        ),
                      ]
                    )
                  )
                //)
              )
            ],
          )
        )
      )
    );
  }
}

class StatsDatum{
  String task;
  double cpu;

  StatsDatum(this.task,this.cpu);
}
