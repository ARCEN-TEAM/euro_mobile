class Customer {
  String codigo;
  String nome;
  String morada;
  String cidade;
  String telefone;
  String email;

  Customer({ required this.codigo, required this.nome, required this.morada, required this.cidade, required this.telefone, required this.email});

  factory Customer.fromJson(Map<String, dynamic> data) {
    final codigo = data['CUS_Code'] as String;
    final nome = data['CUS_Name'] as String;
    final morada = data['CUS_Address'] as String;
    final cidade = data['CUS_City'] as String;
    final telefone = data['CUS_Phone'] as String;
    final email = data['CUS_Email'] as String;

    return Customer(codigo: codigo, nome: nome, morada:morada, cidade: cidade, telefone: telefone, email: email);
  }
}