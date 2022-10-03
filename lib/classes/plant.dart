

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Location.dart';
import 'constants.dart';

final _barsGradient = LinearGradient(
  colors: [

    AppColors.chartLineColorPrimary,
    Colors.greenAccent,
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);
final _barsGradientPump = LinearGradient(
  colors: [
    AppColors.chartLineColorSecondary,
    Colors.greenAccent,
  ],
  begin: Alignment.bottomCenter,
  end: Alignment.topCenter,
);

class Plant {
  String codigo;
  String nome;
  Location gps;
  String zona;
  String telefone;
  String email;
  double minXgraph = 0;
  double maxXgraph = 0;
  double maxYprod = 0;
  double maxYpump = 0;
  List<BarChartGroupData> producao = <BarChartGroupData>[];
  List<BarChartGroupData> bombagem = <BarChartGroupData>[];
  Plant(
      {required this.codigo,
      required this.nome,
      required this.gps,
      required this.zona,
      required this.telefone,
      required this.email });

  factory Plant.fromJson(Map<String, dynamic> data) {
    final codigo = data['PLN_Code'] as String;
    final nome = data['PLN_Name'] as String;
    final gps = Location(
        latitude: double.parse(data['PLN_Longitude']),
        longitude: double.parse(data['PLN_Latitude']));
    final zona = data['PLN_Zone'] as String;
    final telefone = data['PLN_Phone'] as String;
    final email = data['PLN_Email'] as String;


    return Plant(
        codigo: codigo,
        nome: nome,
        gps: gps,
        zona: zona,
        telefone: telefone,
        email: email);
  }

  void set setChartData(dynamic data){


     producao = [];

    final parsedJson = data['production'];
    if(data['production'].length>0){
      minXgraph =   double.parse(data['production'][0]['x'].toString()) ;
      maxXgraph =  double.parse( data['production'][data['production'].length - 1]['x'].toString());
    }else{
      minXgraph =  0.0;
      maxXgraph = 0.0;
    }

    late double maxYgraphProd = 0;

    parsedJson.forEach((dynamic data) {
      if (double.parse(data['y'].toString()) > maxYgraphProd) {
        maxYgraphProd = double.parse(data['y'].toString());
      }
      producao.add(
          BarChartGroupData(
            x: int.parse(data['x'].toString()),
            barRods: [
              BarChartRodData(
                  gradient: _barsGradient,
                  toY: double.parse(data['y'].toString())
              )
            ],
          ));
    });

    maxYprod = maxYgraphProd + 5;

      bombagem = [];

    final parsedJson2 = data['pumping'];

    late double maxYgraphPump = 0;

    parsedJson2.forEach((dynamic data) {
      bombagem.add(
          BarChartGroupData(
            x: int.parse(data['x'].toString()),
            barRods: [
              BarChartRodData(
                  gradient: _barsGradientPump,
                  toY: double.parse(data['y'].toString())
              )
            ],

          ));

      if (double.parse(data['y'].toString()) > maxYgraphPump) {
        maxYgraphPump = double.parse(data['y'].toString());
      }
    });

    maxYpump = maxYgraphPump + 5;
  }

}
