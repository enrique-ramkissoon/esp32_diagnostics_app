import 'dart:collection';

import 'package:flutter/material.dart';
//import 'package:flutter_blue/flutter_blue.dart';
import 'package:charts_flutter/flutter.dart' as charts;

import 'package:esp32_diagnostics_app/main.dart';

class AdcRoute extends StatefulWidget{

  final Characteristics characteristics;

  AdcRoute({Key key, @required this.characteristics}) : super(key: key);

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
  bool exitRequested = false;

  //number of points displayed at any time
  int viewportSize = 50;
  List<AdcDatum> values = new List(50);

  //current index of history_values currently being displayed.
  int currentDisplayStart = 0;
  //shifted points per swipe
  int shiftSize = 10;
  //number of right swipes performed. Only this number of left swipes is permitted
  int rightSwipes = 0;
  //Contains history of points.
  ListQueue<AdcDatum> historyValues = new ListQueue();

  AdcRouteState(){
    graphSeries = createListData();
  }

  @override
  void initState(){
    super.initState();

    List<int> cmd = new List(1);
    cmd[0] = 0x02;
    this.widget.characteristics.write(cmd);
  }

  List<charts.Series<AdcDatum, int>> createListData(){

    for(int i=0;i<=viewportSize-1;i++){
      values[i] = new AdcDatum(i,0);
      historyValues.add(new AdcDatum(i,0)); // add to history
    }

    return [
      new charts.Series<AdcDatum, int>(
        id: 'ID',
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
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
        colorFn: (_, __) => charts.MaterialPalette.green.shadeDefault,
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
      WillPopScope(
        onWillPop: () async {
          setState((){
            if(running == false){
              List<int> stop = new List(1);
              stop[0] = 0x00;

              this.widget.characteristics.write(stop);
              Navigator.pop(context);
            }else{
              exitRequested = true;
              running = false;
            }
          });

          return false;
        },

        child: Scaffold(
          appBar: AppBar(title: Text('ADC Graph'),backgroundColor: Colors.grey[800],),

          backgroundColor: Colors.grey[800],

          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text("Last Reading|Timestamp: " + lastReading, style: TextStyle(color: Colors.white)),
                Row(
                  children: [
                    RaisedButton.icon(icon: Icon(Icons.play_arrow, color: Colors.green[600]), label: Text(""),color: Colors.grey[800], onPressed: () async {
                      
                      //Reset view to last 50 values before resuming (if the viewport was shifted). This condition is false at the start of graphing
                      if(historyValues.length > 50){
                        print(historyValues.length);
                        currentDisplayStart = historyValues.length-viewportSize-1;

                        setState((){ 
                          int j = 0;

                          for(int i=currentDisplayStart;i<currentDisplayStart+viewportSize;i++){
                            values[j] = historyValues.elementAt(i);
                            j++;
                          }

                          graphSeries = updateGraphSeries();
                        });
                      }

                      setState((){
                        running = true;
                      });

                      while(true){
                        if(running == false){
                          break;
                        }

                        List<int> reading = await this.widget.characteristics.rc.read(); //Reading|timestamp + remaining null terminators
                        String readingStr = new String.fromCharCodes(reading);

                        String fixedStr = readingStr.substring(0,readingStr.indexOf(String.fromCharCode(0))); //Reading|timestamp without null terminators

                        String adcValStr = fixedStr.substring(0,fixedStr.indexOf("|")); // Reading only
                        String ts = fixedStr.substring(fixedStr.indexOf("|")+1,fixedStr.length); //Timestamp only

                        //print(fixedStr.length);

                        int readingInt = int.parse(adcValStr);
                        int tsInt = int.parse(ts);
                        //int readingInt = int.parse(readingStr);

                        //Dequeue first term and queue this reading
                        for(int i=0;i<=viewportSize-2;i++){
                          values[i] = values[i+1];
                          //values[i].id = tsInt;
                        }

                        

                        setState((){
                          lastReading = fixedStr;
                          values[viewportSize-1] = new AdcDatum(tsInt,readingInt);
                          historyValues.add(new AdcDatum(tsInt,readingInt));
                          currentDisplayStart++;
                          graphSeries = updateGraphSeries();
                        });
                      }

                      if(exitRequested == true){
                        List<int> stop = new List(1);
                        stop[0] = 0x00;

                        await this.widget.characteristics.write(stop);
                        Navigator.pop(context);
                      }

                    }),

                    RaisedButton.icon(
                      icon: Icon(Icons.pause, color: Colors.green[600]),
                      label: Text(""),
                      color: Colors.grey[800],
                      onPressed: (){
                        setState((){
                          running = false;
                        });
                      }
                    )
                  ],
                ),

                Expanded(
                  child: GestureDetector(
                    onHorizontalDragEnd: (details){

                      if(details.primaryVelocity > 0){
                        setState((){
                          running = false;
                        });
                        print("Swiped Right");

                        if(currentDisplayStart-shiftSize >= 0){
                          currentDisplayStart-=shiftSize;

                          setState((){
                            
                            int j = 0;

                            for(int i=currentDisplayStart;i<currentDisplayStart+viewportSize;i++){
                              values[j] = historyValues.elementAt(i);
                              j++;
                            }

                            graphSeries = updateGraphSeries();
                            rightSwipes++;
                          });
                        }

                      }
                      if(details.primaryVelocity < 0)
                      {
                        setState((){
                          running = false;
                        });
                        print("Swiped Left");

                        if(rightSwipes >= 1){
                          rightSwipes--;
                          currentDisplayStart+=shiftSize;

                          setState((){
                            
                            int j = 0;

                            for(int i=currentDisplayStart;i<currentDisplayStart+viewportSize;i++){
                              values[j] = historyValues.elementAt(i);
                              j++;
                            }

                            graphSeries = updateGraphSeries();
                          });
                        }

                      }
                    },

                    child: charts.LineChart(
                      graphSeries,
                      animate: false,
                      

                      behaviors: [
                        // Add the sliding viewport behavior to have the viewport center on the
                        // domain that is currently selected.
                        new charts.SlidingViewport(),
                        // A pan and zoom behavior helps demonstrate the sliding viewport
                        // behavior by allowing the data visible in the viewport to be adjusted
                        // dynamically.
                        new charts.PanAndZoomBehavior(),
                      ],
                      
                      //domainAxis: can be removed for a graph with smoother transitions, but significanly reduced domain ticks
                      domainAxis: new charts.NumericAxisSpec(
                        tickProviderSpec: charts.BasicNumericTickProviderSpec(desiredTickCount: 0, desiredMaxTickCount: 1, desiredMinTickCount: 0, zeroBound: false,),
                        renderSpec: new charts.GridlineRendererSpec(
                          labelStyle: new charts.TextStyleSpec(
                            color: charts.MaterialPalette.white
                          )
                        )
                      ),

                      primaryMeasureAxis: new charts.NumericAxisSpec(
                        renderSpec: new charts.GridlineRendererSpec(
                          labelStyle: new charts.TextStyleSpec(
                            color: charts.MaterialPalette.white
                          )
                        ) 
                      ),
                    )
                  )
                )

              ]
            )
          )
        )
      )
    );
  }
}

class AdcDatum{
  int id = 0;
  int value = 0;

  AdcDatum(this.id,this.value);
}
