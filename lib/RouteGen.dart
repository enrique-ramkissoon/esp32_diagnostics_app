import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';
import 'package:esp32_diagnostics_app/AdcRoute.dart';
import 'package:esp32_diagnostics_app/ConnectRoute.dart';


class RouteGen{
  static Route<dynamic> generate(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>HomeRoute());
      case '/adc':
        return MaterialPageRoute(builder: (_)=>AdcRoute(characteristics: args));
      case '/connect':
        return MaterialPageRoute(builder: (_)=>ConnectRoute(arg: args));
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
