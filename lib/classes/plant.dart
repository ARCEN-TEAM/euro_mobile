import 'Location.dart';

class Plant {
  String codigo;
  String nome;
  Location gps;
  String zona;
  String telefone;
  String email;
  double prod_desired;
  double prod_delivered;
  double pump_desired;
  double pump_delivered;

  Plant({ required this.codigo, required this.nome, required this.gps, required this.zona, required this.telefone, required this.email, required this.prod_desired, required this.prod_delivered, required this.pump_delivered, required this.pump_desired});

  factory Plant.fromJson(Map<String, dynamic> data) {
    final codigo = data['PLN_Code'] as String;
    final nome = data['PLN_Name'] as String;
    final gps = Location(latitude: double.parse(data['PLN_Longitude']), longitude: double.parse(data['PLN_Latitude']));
    final zona = data['PLN_Zone'] as String;
    final telefone = data['PLN_Phone'] as String;
    final email = data['PLN_Email'] as String;
    final prod_desired = double.parse(data['prod_Desired']);
    final prod_delivered =  double.parse(data['quant_prod']);
    final pump_desired = double.parse(data['pump_Desired']);
    final pump_delivered = double.parse(data['quant_pump']);

    return Plant(codigo: codigo, nome: nome, gps: gps, zona: zona, telefone: telefone, email: email, prod_desired: prod_desired, prod_delivered: prod_delivered, pump_desired: pump_desired, pump_delivered: pump_delivered);
  }
}