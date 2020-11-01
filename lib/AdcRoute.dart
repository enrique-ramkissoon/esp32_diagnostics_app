import 'package:flutter/material.dart';

class AdcRoute extends StatelessWidget{

  final String data;

  AdcRoute({Key key, @required this.data}) : super(key: key);

  Widget build(BuildContext context){
    return(
      Scaffold(
        appBar: AppBar(title: Text('ADC Graph')),

        body: Center(
          child: Column(
            children: <Widget>[
              Text('1 $data'),
              Text('2')
            ]
          )
        )
      )
    );
  }
}
