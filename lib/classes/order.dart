import 'package:intl/intl.dart';
import 'Location.dart';
import 'workplace.dart';
import 'customer.dart';

class Order {
  String totalrows;
  String rownr;
  String cod;
  String codref;
  Workplace obra;
  String cod_receita;
  String receita;
  String date;
  double prod_delivered;
  double prod_desired;
  String statusColor;

  Order({
    required this.totalrows,
    required this.rownr,
    required this.cod,
    required this.codref,
    required this.obra,
    required this.cod_receita,
    required this.receita,
    required this.date,
    required this.prod_delivered,
    required this.prod_desired,
    required this.statusColor,
  });

  factory Order.fromJson(Map<String, dynamic> data) {
    final totalrows = data['total'].toString() as String;
    final rownr = data['rownr'] as String;
    final cod = data['ORD_Code'] as String;
    final codref = data['ORD_CodeRef'] as String;
    final cliente = Customer(codigo: data['CUS_Code'], nome: data['CUS_Name'], morada:data['CUS_Address'], cidade: data['CUS_City'], telefone: data['CUS_Phone'], email: data['CUS_Email']);
    final obra = Workplace(cliente:cliente,codigo: data['WPL_Code'], nome: data['WPL_Name'], cidade: data['WPL_City'], morada: data['WPL_Address'],codpostal: data['WPL_PostalCode'], gps: Location(latitude: double.parse(data['WPL_GPSLAT']),longitude: double.parse(data['WPL_GPSLON'])), telefone: data['WPL_Phone'], email: data['WPL_Email']);
    final cod_receita = data['ORD_RecName'] as String;
    final receita = data['ORD_RecDesc'] as String;
    final date = DateFormat('dd-MM-yyyy').format(DateTime.parse(data['ORD_Date']["date"].toString()));
    final prod_delivered = double.parse(data['ORD_QuantityDelivered'].toString());
    final prod_desired = double.parse(data['ORD_QuantityDesired'].toString());
    final statusColor = data['statusColor'] as String;

    return Order(
        totalrows: totalrows,
        rownr: rownr,
        cod: cod,
        codref: codref,
        obra: obra,
        cod_receita: cod_receita,
        receita: receita,
        date: date,
        prod_delivered: prod_delivered,
        prod_desired: prod_desired,
        statusColor:statusColor,
    );
  }
}
