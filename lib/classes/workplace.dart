import 'Location.dart';
import 'customer.dart';

class Workplace {
  Customer cliente;
  String codigo;
  String nome;
  String cidade;
  String morada;
  String codpostal;
  Location gps;
  String telefone;
  String email;

  Workplace({ required this.cliente, required this.codigo, required this.nome, required this.cidade, required this.morada, required this.codpostal, required this.gps, required this.telefone, required this.email});

  factory Workplace.fromJson(Map<String, dynamic> data) {
    final cliente = Customer(codigo: data['CUS_Code'], nome: data['CUS_Name'], morada:data['CUS_Address'], cidade: data['CUS_City'], telefone: data['CUS_Phone'], email: data['CUS_Email']);
    final codigo = data['WPL_Code'] as String;
    final nome = data['WPL_Name'] as String;
    final cidade = data['WPL_City'] as String;
    final morada = data['WPL_Address'] as String;
    final codpostal = data['WPL_PostalCode'] as String;
    final gps = Location(latitude: double.parse(data['WPL_GPSLAT']), longitude: double.parse(data['WPL_GPSLON']));
    final telefone = data['WPL_Phone'] as String;
    final email = data['WPL_Email'] as String;

    return Workplace(cliente:cliente,codigo: codigo, nome: nome, cidade: cidade, morada:morada, codpostal:codpostal, gps: gps, telefone: telefone, email: email);
  }
}