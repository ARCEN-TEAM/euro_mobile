import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
//import 'package:login_test/screens/workplace_screen_details.dart';
import '../classes/constants.dart';
import '../classes/invoice.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter/services.dart';


class InvoiceDetail extends StatefulWidget {

  const InvoiceDetail({required this.guia});
  final Invoice guia;

  @override
  InvoiceDetailState createState() => new InvoiceDetailState();

}


class InvoiceDetailState extends State<InvoiceDetail> {
  late CarouselSliderController _sliderController;
  List<String> clipboard = [];
  String copyCliente = '';
  String copyObra = '';
  String copyRecipe = '';
  String copyTruck = '';
  @override
  void initState(){
    super.initState();
    _sliderController = CarouselSliderController();

    copyCliente = widget.guia.obra.cliente.nome;
    copyObra = widget.guia.obra.nome;
    copyRecipe = widget.guia.receita;
    copyTruck = widget.guia.motorista;
    clipboard.add(widget.guia.obra.cliente.nome);
    clipboard.add(widget.guia.obra.nome);
    clipboard.add(widget.guia.receita);
    clipboard.add(widget.guia.motorista);
  }
  @override
  Widget build(BuildContext context) {

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border.all(width: 0, color: Color(0xFF0e1623)),
        gradient: RadialGradient(
          center: Alignment(-1.4, -1.4),
          colors: [
            Color(0xFF1d4d73),
            Color(0xFF0f1925),
          ],
          radius: 1.2,
        ),
      ),
      child: Scaffold(
        //extendBodyBehindAppBar: true,
        appBar: new AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(widget.guia.codigo,textAlign: TextAlign.center,),

        ),
        body: Padding(
          padding: EdgeInsets.only(top:20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              buildCard(0,FaIcon(FontAwesomeIcons.userTie, size: 30, color: Colors.white ),  "Cliente",[widget.guia.obra.cliente.codigo,widget.guia.obra.cliente.nome] , null,null),
              buildCard(1,FaIcon(FontAwesomeIcons.personDigging, size: 30, color: Colors.white ),  "Obra", [widget.guia.obra.codigo,widget.guia.obra.nome], Icon(Icons.chevron_right, color: Colors.white),null), //WorkplaceScreen(widget.guia.obra)
              buildCard(2,Image.asset('assets/images/pile-concrete.png', width: 35,height: 30, ),  "Composição", [widget.guia.cod_receita,widget.guia.receita], null,null),
              buildCard(3,Image.asset('assets/images/concrete-truck.png', width: 35,height: 30, ),  "Camião", [widget.guia.camiao,widget.guia.motorista], null,null),

            ],
          ),
        ),
      ),
    );
  }

  Widget buildCard(int indexCard,Widget leading, String titulo, List<String> subtitulo, Icon? trailing,dynamic? screenRoute) {

    return Container(
      height: 90,
      child: ListTile(

          leading: ClipRRect(

            borderRadius: BorderRadius.circular(15.0),
            child: Material(
              color: Color(0xFF172b49), //
              child: InkWell(
                splashColor: Colors.white, // inkwell color
                child: SizedBox(
                    width: 56,
                    height: 56,
                    child: Center(child: leading)),
                onTap: () {

                },
              ),
            ),
          ),
          title: Flex(

            direction: Axis.horizontal,
            children:[Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top:10.0),
                child: Text(

                  overflow:TextOverflow.ellipsis,
                  titulo,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),]
          ),
        subtitle:
        new LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              if (subtitulo.length == 1 ) {
                return Flex(
                    direction: Axis.horizontal,
                    children: [Flexible(
                      child: Text(
                        overflow: TextOverflow.ellipsis,
                        subtitulo[0],
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ]
                );
              }else {
                return Container(
                margin: EdgeInsets.only(bottom: 40),


                  child: CarouselSlider.builder(
                  onSlideChanged: (index){
                    setState(() {
                      clipboard[indexCard] = subtitulo[index];

                    });
                  },
                    controller: _sliderController,
                    slideBuilder: (index) {
                      return Flex(
                          direction: Axis.horizontal,
                          children: [Flexible(
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 15),
                              child: Text(
                                overflow: TextOverflow.ellipsis,
                                subtitulo[index],
                                style: TextStyle(color: Colors.grey,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          ]
                      );
                    },
                    slideIndicator: CircularSlideIndicator(
alignment:AlignmentDirectional.bottomStart,
                      indicatorBorderColor: Color(0x5D494a4b),
                      indicatorBackgroundColor: Color(0x5D494a4b),
                      currentIndicatorColor: Colors.white
                    ),
                    itemCount: subtitulo.length,
                    initialPage: 1,
                  ),

                );
              }
            }
        ),


          trailing: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: IntrinsicHeight(

              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    splashColor: Colors.white, // inkwell color
                    child: Icon(Icons.content_copy , color: Colors.white.withOpacity(0.2)),
                    onTap: () {
                      GlobalFunctions.removeToast(context);
                      Clipboard.setData(ClipboardData(text: clipboard[indexCard])).then((_){
                        GlobalFunctions.showToast(context," '" + clipboard[indexCard]+"' copiado!");
                      });
                    },
                  ),
                  (trailing == null ? Container() : Row(children: [
                    SizedBox(width:10),
                    VerticalDivider(
                      color: Colors.white.withOpacity(0.2),
                      thickness: 2,
                    ),
                    SizedBox(width:10),
                    InkWell(
                      splashColor: Colors.white, // inkwell color
                      child: trailing,
                      onTap: ()  {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //       builder: (context) =>
                        //           WorkplaceScreen(widget.guia.obra)),
                        // );

                      },
                    ),
                  ])),

                ],
              ),
            ),
          )

      ),
    );
  }

}
