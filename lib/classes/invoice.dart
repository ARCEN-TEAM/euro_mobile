import 'package:intl/intl.dart';
import 'Location.dart';
import 'workplace.dart';
import 'customer.dart';

class Invoice {
  String totalrows;
  String rownr;
  String codigo;
  Workplace obra;
  String camiao;
  String motorista;
  String cod_receita;
  String receita;
  String data_hora;
  double prod_delivered;
  double prod_total;
  String ord_id;
  String ord_code;
  String operador;
  String inv_type;
  String saidacentral;
  String chegadaobra;
  String saidaobra;
  String chegadacentral;

  Invoice({
    required this.totalrows,
    required this.rownr,
    required this.codigo,
    required this.obra,
    required this.camiao,
    required this.motorista,
    required this.cod_receita,
    required this.receita,
    required this.data_hora,
    required this.prod_delivered,
    required this.prod_total,
    required this.ord_id,
    required this.ord_code,
    required this.operador,
    required this.inv_type,
    required this.saidacentral,
    required this.chegadaobra,
    required this.saidaobra,
    required this.chegadacentral,
  });

  factory Invoice.fromJson(Map<String, dynamic> data) {
    final totalrows = data['total'].toString() as String;
    final rownr = data['rownr'] as String;
    final codigo = data['OTR_SAFT_InvoiceNo'] as String;
    final cliente = Customer(codigo: data['CUS_Code'], nome: data['CUS_Name'], morada:data['CUS_Address'], cidade: data['CUS_City'], telefone: data['CUS_Phone'], email: data['CUS_Email']);
    final obra = Workplace(cliente:cliente,codigo: data['WPL_Code'], nome: data['WPL_Name'], cidade: data['WPL_City'], morada: data['WPL_Address'],codpostal: data['WPL_PostalCode'], gps: Location(latitude: double.parse(data['WPL_GPSLAT']),longitude: double.parse(data['WPL_GPSLON'])), telefone: data['WPL_Phone'], email: data['WPL_Email']);
    final camiao = data['OTR_TruckID'] as String;
    final motorista = data['DRV_Name'].toString();
    final cod_receita = data['OTR_RecipeID'] as String;
    final receita = data['OTR_RecDesc'] as String;
    final data_hora = DateFormat('dd-MM-yyyy HH:mm').format(DateTime.parse(data['Data']["date"].toString()));
    final prod_delivered = double.parse(data['OTR_INV_Quantity'].toString());
    final prod_total = double.parse(data['OTR_INV_QuantityTotal'].toString());
    final ord_id = data['OTR_OrderID'].toString() as String;
    final ord_code = data['ORD_Code'] as String;
    final operador = data['OTR_Operator'] as String;
    final inv_type = data['otr_inv_type'].toString();
    final saidacentral = data['OTR_plantDeparture'].toString();
    final chegadaobra = data['OTR_WorkplaceArrival'].toString();
    final saidaobra = data['OTR_WorkplaceDeparture'].toString();
    final chegadacentral = data['OTR_PlantArrival'].toString();

    return Invoice(
        totalrows: totalrows,
        rownr: rownr,
        codigo: codigo,
        obra: obra,
        camiao: camiao,
        motorista: motorista,
        cod_receita: cod_receita,
        receita: receita,
        data_hora: data_hora,
        prod_delivered: prod_delivered,
        prod_total: prod_total,
        ord_id: ord_id,
        ord_code: ord_code,
        operador:operador,
        inv_type: inv_type,
        saidacentral: saidacentral,
        chegadaobra: chegadaobra,
        saidaobra: saidaobra,
        chegadacentral: chegadacentral,

    );
  }
}
