import 'package:flutter/material.dart';
import 'package:esp32_diagnostics_app/main.dart';
import 'package:esp32_diagnostics_app/TextDumpRoute.dart';
import 'package:esp32_diagnostics_app/AdcRoute.dart';
import 'package:esp32_diagnostics_app/StateRoute.dart';
import 'package:esp32_diagnostics_app/StatsRoute.dart';
import 'package:esp32_diagnostics_app/ConnectRoute.dart';


class RouteGen{
  static Route<dynamic> generate(RouteSettings settings){
    final args = settings.arguments;

    switch(settings.name){
      case '/':
        return MaterialPageRoute(builder: (_)=>HomeRoute());
      case '/textdump':
        return MaterialPageRoute(builder: (_)=>TextDumpRoute(characteristics: args));
      case '/adc':
        return MaterialPageRoute(builder: (_)=>AdcRoute(characteristics: args));
      case '/state':
        return MaterialPageRoute(builder: (_)=>StateRoute(characteristics: args));
      case '/stats':
        return MaterialPageRoute(builder: (_)=>StatsRoute(characteristics: args));
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
