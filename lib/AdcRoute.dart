import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdcRoute extends StatefulWidget{

  final BluetoothCharacteristic readChar;

  AdcRoute({Key key, @required this.readChar}) : super(key: key);

  @override
  AdcRouteState createState(){
    return AdcRouteState();
  } 
}

class AdcRouteState extends State<AdcRoute>{

  String lastReading = '';
  List<charts.Series<AdcDatum, int>> graphSeries;
  bool animate;

  bool running = false;

  List<AdcDatum> values = new List(50);

  ListQueue<AdcDatum> history_values = new ListQueue();

  AdcRouteState(){
    graphSeries = createListData();
  }

  List<charts.Series<AdcDatum, int>> createListData(){

    for(int i=0;i<=49;i++){
      values[i] = new AdcDatum(i,0);
    }

    return [
      new charts.Series<AdcDatum, int>(
        id: 'ID',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (AdcDatum reading, _) => reading.id,
        measureFn: (AdcDatum reading, _) => reading.value,
        data: values,
      )
    ];
  }

  List<charts.Series<AdcDatum, int>> updateGraphSeries(){
    return [
      new charts.Series<AdcDatum, int>(
        id: 'ID',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (AdcDatum reading, _) => reading.id,
        measureFn: (AdcDatum reading, _) => reading.value,
        data: values,
      )
    ];
  }

  // factory AdcRouteState.withSampleData() {
  //   return new AdcRouteState(
  //     _createSampleData(),
  //     false
  //   );
  // }

  // static List<charts.Series<AdcDatum, int>> _createSampleData() {
  //   var data = [
  //     new AdcDatum(0, 5),
  //     new AdcDatum(1, 25),
  //     new AdcDatum(2, 100),
  //     new AdcDatum(3, 75),
  //   ];

  //   return [
  //     new charts.Series<AdcDatum, int>(
  //       id: 'Sales',
  //       colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
  //       domainFn: (AdcDatum reading, _) => reading.id,
  //       measureFn: (AdcDatum reading, _) => reading.value,
  //       data: data,
  //     )
  //   ];
  // }

  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('ADC Graph')),

        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(lastReading),
              RaisedButton(child: Text('Start Graphing'), onPressed: () async {
                
                setState((){
                  running = true;
                });

                while(true){
                  if(running == false){
                    break;
                  }

                  List<int> reading = await this.widget.readChar.read();
                  String readingStr = new String.fromCharCodes(reading);

                  String fixedStr = readingStr.substring(0,readingStr.indexOf(String.fromCharCode(0)));

                  //print(fixedStr.length);

                  int readingInt = int.parse(fixedStr);
                  //int readingInt = int.parse(readingStr);

                  //Dequeue first term and queue this reading
                  for(int i=0;i<=48;i++){
                    values[i] = values[i+1];
                    values[i].id = i;
                  }

                  setState((){
                    lastReading = fixedStr;
                    values[49] = new AdcDatum(49,readingInt);
                    graphSeries = updateGraphSeries();
                  });
                }
              }),

              Expanded(
                child: GestureDetector(
                  onHorizontalDragEnd: (details){
                    if(details.primaryVelocity > 0){
                      setState((){
                        running = false;
                      });
                      print("Swiped RIght");
                    }
                    if(details.primaryVelocity < 0)
                    {
                      setState((){
                        running = false;
                      });
                      print("Swiped Left");
                    }
                  },

                  child: charts.LineChart(
                    graphSeries,
                    animate: false
                  )
                )
              )

            ]
          )
        )
      )
    );
  }
}

class AdcDatum{
  int id;
  int value;

  AdcDatum(this.id,this.value);
}
