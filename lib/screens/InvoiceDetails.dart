import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_translate/flutter_translate.dart';

import 'timelineTest.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'WorkplaceDetails.dart';
import '../classes/constants.dart';
import '../classes/invoice.dart';
import '../classes/plant.dart';
import '../classes/enterExitPage.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter/services.dart';
import 'widgets/my_arc.dart';

enum ButtonState { idle, loading, sucess }

class InvoiceDetail extends StatefulWidget {
  const InvoiceDetail({required this.central, required this.guia});

  final Plant central;
  final Invoice guia;

  @override
  InvoiceDetailState createState() => new InvoiceDetailState();
}

class InvoiceDetailState extends State<InvoiceDetail> {
  late CarouselSliderController _sliderController;
  List<String> clipboard = [];

  String dir = "";
  var fileName = "";
  var response;

  @override
  void initState()   {
    super.initState();
    _sliderController = CarouselSliderController();

    clipboard.add(widget.guia.obra.cliente.nome);
    clipboard.add(widget.guia.obra.nome);
    clipboard.add(widget.guia.receita);
    clipboard.add(widget.guia.motorista);
    getDir(widget.guia.codigo);

  }
  getDir(String inv) async{
    String localdir = (await getApplicationDocumentsDirectory()).path;
    var fileNamedir = inv.replaceAll('/', '-') + '.pdf';

    bool exists = await File("$localdir/$fileNamedir").exists();

    setState(() {
      dir = localdir;
      fileName = fileNamedir;

      if(exists){
        currentState = 2;
      }

    });
  }
  Future<void> GetInvoice(
      String plantCode, String invoice, String tipoguia) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

    String localdir = (await getApplicationDocumentsDirectory()).path;
    var fileNamedir = invoice.replaceAll('/', '-') + '.pdf';

    var url = ApiConstants.baseUrl +
        ApiConstants.invoiceEndpoint +
        '/file/?user=' +
        ApiConstants.UserLogged +
        '&token=' +
        ApiConstants.ApiKey +
        '&plant=' +
        plantCode +
        '&inv=' +
        invoice +
        '&type=' +
        tipoguia;

    var httpClient = http.Client();
    var request = new http.Request('GET', Uri.parse(url));
    response = httpClient.send(request);

    List<List<int>> chunks = [];
    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        chunks.add(chunk);
      }, onDone: () async {
        // Save the file

        File file = new File('$localdir/$fileNamedir');
        int tamanho = int.parse(r.contentLength.toString());
        final Uint8List bytes = Uint8List(tamanho);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);

        setState(() {
          dir = localdir;
          fileName = fileNamedir;
          currentState = 2;
        });
        return;
      });
    });
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
          iconTheme: IconThemeData(color: AppColors.textColorOnDarkBG),
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title: Text(

            (widget.guia.inv_type == "1" ? translate('guia_remessa'): translate('guia_bombagem')),
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textColorOnDarkBG),
          ),
          actions: <Widget>[
            Center(
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    switch (currentState) {
                      case 0: //idle
                        GetInvoice(widget.central.codigo, widget.guia.codigo,
                            widget.guia.inv_type);
                        currentState = 1;
                        break;

                      case 1:
                        break;

                      case 2:
                        OpenFile.open("$dir/$fileName");
                        break;
                    }
                  });
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 20.0),
                  child: downloadProgress(currentState),
                ),
              ),
            )
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(top: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 70.0, left: 35),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.guia.codigo,
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG,
                                fontSize: 20),
                          ),
                          Text(
                            widget.guia.data_hora.substring(0, 10),
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG,
                                fontSize: 15),
                          ),
                          SizedBox(
                            height: 20,
                          ),
                          Text(
                            widget.guia.ord_code,
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG,
                                fontSize: 15),
                          ),
                        ],
                      ),
                      Stack(
                        children: [
                          Center(
                              child: CustomPaint(
                            painter: MyPainter(),
                            size: Size(80, 80),
                          )),
                          Container(
                              width: 80,
                              padding: const EdgeInsets.only(top: 20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    widget.guia.prod_delivered.toString(),
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 28, height:1.5),
                                  ),

                                 Text(

                                      'm³',
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 20, height:0.8),
                                    ),

                                ],
                              )),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                buildCard(
                    0,
                    translate('cliente'),
                    [
                      widget.guia.obra.cliente.codigo,
                      widget.guia.obra.cliente.nome
                    ],
                    null,
                    null),
                buildCard(
                    1,
                    translate('obra'),
                    [widget.guia.obra.codigo, widget.guia.obra.nome],
                    Icon(Icons.chevron_right, color: Colors.white),
                    WorkplaceScreen(widget.guia.obra)),
                buildCard(2, translate('composicao'),
                    [widget.guia.cod_receita, widget.guia.receita], null, null),
                buildCard(3, translate('camiao'),
                    [widget.guia.camiao, widget.guia.motorista], null, null),
                DeliveryTimeline(
                  timeList: [
                    widget.guia.data_hora.substring(11), //inicio carga
                    //widget.guia.fimcarga, //fim carga
                    widget.guia.saidacentral, //saida central
                    widget.guia.chegadaobra, //chegada obra
                    widget.guia.iniciodescarga, //inicio descarga
                    widget.guia.saidaobra, //saida obra
                    widget.guia.chegadacentral //chegada central
                  ], 
                  lastTimestmp: (widget.guia.chegadacentral != "")
                      ? 6
                      : (widget.guia.saidaobra != "")
                        ? 5
                        : (widget.guia.iniciodescarga != "")
                          ? 4
                          :  (widget.guia.chegadaobra != "")
                            ? 3
                            :  (widget.guia.saidacentral != "")
                              ? 2
                              : 1,
                  inv_type: widget.guia.inv_type)
              ],
            ),
          ),
        ),
      ),
    );
  }

  int currentState = 0;

  Widget downloadProgress(int state) {
    switch (state) {
      case 0: //idle
        return Icon(
          Icons.file_download,
          color: AppColors.textColorOnDarkBG,
        );

      case 1: //loading
        return SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
            backgroundColor: Colors.transparent,
          ),
        );

      case 2: //sucess
        return Icon(
          Icons.file_download_done,
          color: AppColors.textColorOnDarkBG,
        );

      default:
        return Container();
    }
  }

  Widget buildCard(int indexCard, String titulo, List<String> subtitulo,
      Icon? trailing, dynamic? screenRoute) {
    return Container(
      height: 90,
      padding: EdgeInsets.only(left: 20),
      child: ListTile(
          title: Flex(direction: Axis.horizontal, children: [
            Flexible(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: Text(
                  overflow: TextOverflow.ellipsis,
                  titulo,
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ]),
          subtitle: new LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
            if (subtitulo.length == 1) {
              return Flex(direction: Axis.horizontal, children: [
                Flexible(
                  child: Text(
                    overflow: TextOverflow.ellipsis,
                    subtitulo[0],
                    style: TextStyle(
                        color: Colors.grey, fontWeight: FontWeight.bold),
                  ),
                ),
              ]);
            } else {
              return Container(
                margin: EdgeInsets.only(bottom: 55),
                child: CarouselSlider.builder(
                  onSlideChanged: (index) {
                    setState(() {
                      clipboard[indexCard] = subtitulo[index];
                    });
                  },
                  controller: _sliderController,
                  slideBuilder: (index) {
                    return Flex(direction: Axis.horizontal, children: [
                      Flexible(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            subtitulo[index],
                            style: TextStyle(
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ]);
                  },
                  slideIndicator: CircularSlideIndicator(
                      itemSpacing: 10,
                      indicatorRadius: 4,
                      alignment: AlignmentDirectional.bottomStart,
                      indicatorBorderColor: Color(0x5D494a4b),
                      indicatorBackgroundColor: Color(0x5D494a4b),
                      currentIndicatorColor: AppColors.buttonPrimaryColor),
                  itemCount: subtitulo.length,
                  initialPage: 1,
                ),
              );
            }
          }),
          trailing: Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: IntrinsicHeight(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  InkWell(
                    splashColor: Colors.white, // inkwell color
                    child: Icon(Icons.content_copy,
                        color: Colors.white.withOpacity(0.2)),
                    onTap: () {
                      GlobalFunctions.removeToast(context);
                      Clipboard.setData(
                              ClipboardData(text: clipboard[indexCard]))
                          .then((_) {
                        GlobalFunctions.showToast(context,
                            " '" + clipboard[indexCard] + "' " + translate('copiado') + "!");
                      });
                    },
                  ),
                  (trailing == null
                      ? Container()
                      : Row(children: [
                          SizedBox(width: 10),
                          VerticalDivider(
                            color: Colors.white.withOpacity(0.2),
                            thickness: 2,
                          ),
                          SizedBox(width: 10),
                          InkWell(
                            splashColor: Colors.white, // inkwell color
                            child: trailing,
                            onTap: () {
                              Navigator.push(context, SlideInPageRoute(exitPage: widget, enterPage:screenRoute),
                              );
                            },
                          ),
                        ])),
                ],
              ),
            ),
          )),
    );
  }
}
