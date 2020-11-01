import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';

class RouteGen{
  static Route<dynamic> generate(RouteSettings settings){
    //final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>HomeRoute());
      default:
        return errorRoute();
    }
  }

  static Route<dynamic> errorRoute(){
    return MaterialPageRoute(builder: (_){
      return Scaffold(
        appBar: AppBar(title: Text('ERROR')),

        body: Center(
          child: Text('Invalid Route Entered')
        )
      );
    });
  }
}
