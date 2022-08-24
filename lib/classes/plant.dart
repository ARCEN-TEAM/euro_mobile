import 'package:fl_chart/fl_chart.dart';
import 'Location.dart';

class Plant {
  String codigo;
  String nome;
  Location gps;
  String zona;
  String telefone;
  String email;
  double minXgraph;
  double maxXgraph;
  double maxYprod;
  double maxYpump;
  List<FlSpot> producao;
  List<FlSpot> bombagem;

  Plant({
    required this.codigo,
    required this.nome,
    required this.gps,
    required this.zona,
    required this.telefone,
    required this.email,
    required this.minXgraph,
    required this.maxXgraph,
    required this.maxYprod,
    required this.maxYpump,
    required this.producao,
    required this.bombagem
  });

  factory Plant.fromJson(Map<String, dynamic> data) {
    final codigo = data['PLN_Code'] as String;
    final nome = data['PLN_Name'] as String;
    final gps = Location(latitude: double.parse(data['PLN_Longitude']), longitude: double.parse(data['PLN_Latitude']));
    final zona = data['PLN_Zone'] as String;
    final telefone = data['PLN_Phone'] as String;
    final email = data['PLN_Email'] as String;
    late List<FlSpot> producao =[];

    final parsedJson = data['production'];
    final mingraph = double.parse(data['production'][0]['x'].toString());
    final maxgraph = double.parse(data['production'][data['production'].length-1]['x'].toString());
    late double maxYgraphProd = 0;

    parsedJson.forEach((dynamic data) {
      if(double.parse(data['y'].toString()) > maxYgraphProd){
        maxYgraphProd = double.parse(data['y'].toString());
      }
      producao.add(FlSpot(double.parse(data['x'].toString()), double.parse(data['y'].toString())));
    });

    maxYgraphProd = maxYgraphProd + 5;

    List<FlSpot> bombagem =[];

    final parsedJson2 = data['pumping'];

    late double maxYgraphPump = 0;

    parsedJson2.forEach((dynamic data) {
      bombagem.add(FlSpot(double.parse(data['x'].toString()), double.parse(data['y'].toString())));

      if(double.parse(data['y'].toString()) > maxYgraphPump){
        maxYgraphPump = double.parse(data['y'].toString());
      }
    });

    maxYgraphPump = maxYgraphPump + 5;


    return Plant(
        codigo: codigo,
        nome: nome,
        gps: gps,
        zona: zona,
        telefone: telefone,
        email: email,
        minXgraph: mingraph,
        maxXgraph: maxgraph,
        maxYprod: maxYgraphProd,
        maxYpump: maxYgraphPump,
        producao: producao,
        bombagem: bombagem
    );
  }
}