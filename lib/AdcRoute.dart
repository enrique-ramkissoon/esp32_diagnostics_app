import 'package:flutter/material.dart';
import 'package:flutter_blue/flutter_blue.dart';
import 'package:charts_flutter/flutter.dart' as charts;

class AdcRoute extends StatefulWidget{

  final BluetoothCharacteristic readChar;

  AdcRoute({Key key, @required this.readChar}) : super(key: key);

  @override
  AdcRouteState createState(){
    return AdcRouteState.withSampleData();
  } 
}

class AdcRouteState extends State<AdcRoute>{

  String lastReading = '';
  List<charts.Series> graphSeries;
  bool animate;

  AdcRouteState(this.graphSeries,this.animate);

  factory AdcRouteState.withSampleData() {
    return new AdcRouteState(
      _createSampleData(),
      false
    );
  }

  static List<charts.Series<AdcDatum, int>> _createSampleData() {
    final data = [
      new AdcDatum(0, 5),
      new AdcDatum(1, 25),
      new AdcDatum(2, 100),
      new AdcDatum(3, 75),
    ];

    return [
      new charts.Series<AdcDatum, int>(
        id: 'Sales',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (AdcDatum reading, _) => reading.id,
        measureFn: (AdcDatum reading, _) => reading.value,
        data: data,
      )
    ];
  }

  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('ADC Graph')),

        body: Center(
          child: Column(
            children: <Widget>[
              Text(lastReading),
              RaisedButton(child: Text('Start Graphing'), onPressed: () async{
                
                while(true){
                  List<int> reading = await this.widget.readChar.read();
                  setState((){
                    lastReading = new String.fromCharCodes(reading);
                  });
                }
              }),

              Container(
                child: charts.LineChart(
                  graphSeries,
                  animate: false
                ),

                height: 900


              )
            ]
          )
        )
      )
    );
  }
}

class AdcDatum{
  final int id;
  final int value;

  AdcDatum(this.id,this.value);
}
