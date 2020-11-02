import 'dart:math';

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

  List<AdcDatum> values = new List(10);

  AdcRouteState(){
    graphSeries = createListData();
  }

  List<charts.Series<AdcDatum, int>> createListData(){

    for(int i=0;i<=9;i++){
      values[i] = new AdcDatum(i,0);
    }

    return [
      new charts.Series<AdcDatum, int>(
        id: 'Sales',
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
              RaisedButton(child: Text('Start Graphing'), onPressed: () async{
                
                //while(true){
                  //List<int> reading = await this.widget.readChar.read();
                  //String readingStr = new String.fromCharCodes(reading);
                  setState((){
                    //lastReading = readingStr;
                    ////int readingInt = int.parse(readingStr);

                    //Dequeue first term and queue this reading
                    for(int i=0;i<=8;i++){
                      values[i] = values[i+1];
                      values[i].id = i;
                    }
                    values[9] = new AdcDatum(9, Random().nextInt(2000));
                  });
                //}
              }),

              Expanded( 
                  child: charts.LineChart(
                    graphSeries,
                    animate: true
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
  final int value;

  AdcDatum(this.id,this.value);
}
