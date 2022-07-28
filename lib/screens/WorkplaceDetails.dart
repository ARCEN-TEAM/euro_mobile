import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../classes/constants.dart';
import '../classes/enterExitPage.dart';
import '../classes/workplace.dart';
import '../classes/utils.dart';
import '../classes/MapUtils.dart';
import '../utilities/constants.dart';
import 'package:flutter_animation_progress_bar/flutter_animation_progress_bar.dart';

class WorkplaceScreen extends StatefulWidget {
  const WorkplaceScreen(this.obra);

  final Workplace obra;

  @override
  State<WorkplaceScreen> createState() => _WorkplaceScreenWidgetState();
}

List<String> categories = ['Detalhes'];
var currentIndex = 0;
var pageIndex = 0;
var response;
var limit = 10;
bool hasMore = true;
bool postRequestLoading = false;
var lengthsliver = 1;

class _WorkplaceScreenWidgetState extends State<WorkplaceScreen> {

  late CarouselSliderController _sliderController;
  List<String> clipboard = [];

  @override
  void initState() {
    super.initState();

    _sliderController = CarouselSliderController();

    clipboard.add(widget.obra.cliente.nome);
    clipboard.add(widget.obra.cliente.morada);
    clipboard.add(widget.obra.nome);
    clipboard.add(widget.obra.morada);
    clipboard.add(widget.obra.telefone);

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Workplace obralocal = widget.obra;
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
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          elevation: 0.0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
        ),
        body: Container(

          child: CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              forceElevated: true,
              floating: false,
              automaticallyImplyLeading: false,
              snap: false,
              pinned: false,

              flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 16),
                  title: SingleChildScrollView(
                    child: ListTile(
                      leading:  Padding(
                                  padding: const EdgeInsets.only(left: 7.0),
                                  child: new GestureDetector(
                                    onTap: () {
                                      MapUtils.openMap(obralocal.gps.latitude,
                                          obralocal.gps.longitude);
                                    },
                                    child: Container(
                                      width: 80,
                                      height: 80,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.blue,
                                      ),
                                      child: Align(
                                        alignment: AlignmentDirectional(0, 0),
                                        child: Image.network(
                                            'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                                                obralocal.gps.longitude.toString() +
                                                ',' +
                                                obralocal.gps.latitude.toString() +
                                                ')/' +
                                                obralocal.gps.longitude.toString() +
                                                ',' +
                                                obralocal.gps.latitude.toString() +
                                                ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw'),
                                      ),
                                    ),
                                  )),
                      title:  Flex(
                        direction: Axis.horizontal,
                        children: [
                          Flexible(
                            child: Container(
                                                child: Text(
                                                  overflow:
                                                  TextOverflow.ellipsis,
                                              obralocal.nome,
                                              style: TextStyle(fontWeight: FontWeight.bold,
                                                  fontSize: 18, color: Colors.white),
                                            )),
                          ),
                        ],
                      ),
                      subtitle: Padding(
                                        padding: const EdgeInsets.only(top: 8.0),
                                        child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Icon(Icons.phone_android_rounded,
                                                  color: Colors.white, size: 17),
                                              Flexible(
                                                child: Padding(
                                                    padding: const EdgeInsets.only(
                                                        left: 8.0),
                                                    child: InkWell(
                                                      child: Text(
                                                          obralocal.telefone
                                                              .replaceAll(
                                                                  '+351', ''),
                                                          overflow:
                                                              TextOverflow.ellipsis,
                                                          style: TextStyle(
                                                              color: Colors.white,
                                                              wordSpacing: 2,
                                                              fontSize: 12,
                                                              letterSpacing: 4)),
                                                      onTap: () {
                                                        Utils.launchCaller(
                                                            util_call,
                                                            obralocal.telefone
                                                                .replaceAll(
                                                                    '+351', ''));
                                                      },
                                                    )),
                                              )
                                            ]),
                                      ),
                    )
                    // child: Column(
                    //   mainAxisAlignment: MainAxisAlignment.end,
                    //   crossAxisAlignment: CrossAxisAlignment.start,
                    //   children: [
                    //     Row(
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       children: <Widget>[
                    //         Padding(
                    //             padding: const EdgeInsets.only(left: 7.0),
                    //             child: new GestureDetector(
                    //               onTap: () {
                    //                 MapUtils.openMap(obralocal.gps.latitude,
                    //                     obralocal.gps.longitude);
                    //               },
                    //               child: Container(
                    //                 width: 80,
                    //                 height: 80,
                    //                 clipBehavior: Clip.antiAlias,
                    //                 decoration: BoxDecoration(
                    //                   shape: BoxShape.circle,
                    //                   color: Colors.blue,
                    //                 ),
                    //                 child: Align(
                    //                   alignment: AlignmentDirectional(0, 0),
                    //                   child: Image.network(
                    //                       'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                    //                           obralocal.gps.longitude.toString() +
                    //                           ',' +
                    //                           obralocal.gps.latitude.toString() +
                    //                           ')/' +
                    //                           obralocal.gps.longitude.toString() +
                    //                           ',' +
                    //                           obralocal.gps.latitude.toString() +
                    //                           ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw'),
                    //                 ),
                    //               ),
                    //             )),
                    //         Flexible(
                    //           child: Padding(
                    //             padding: const EdgeInsets.only(left: 20.0),
                    //             child: Column(
                    //               crossAxisAlignment: CrossAxisAlignment.start,
                    //               children: <Widget>[
                    //                 Container(
                    //                     child: Text(
                    //                   obralocal.codigo,
                    //                   style: TextStyle(
                    //                       fontSize: 10, color: Colors.white),
                    //                 )),
                    //                 Container(
                    //                     child: Text(
                    //                   obralocal.nome,
                    //                   overflow: TextOverflow.ellipsis,
                    //                   style: TextStyle(
                    //                       fontWeight: FontWeight.bold,
                    //                       fontSize: 15,
                    //                       color: Colors.white),
                    //                 )),
                    //                 Padding(
                    //                   padding: const EdgeInsets.only(top: 8.0),
                    //                   child: Row(
                    //                       crossAxisAlignment:
                    //                           CrossAxisAlignment.center,
                    //                       children: <Widget>[
                    //                         Icon(Icons.phone_android_rounded,
                    //                             color: Colors.white, size: 17),
                    //                         Flexible(
                    //                           child: Padding(
                    //                               padding: const EdgeInsets.only(
                    //                                   left: 8.0),
                    //                               child: InkWell(
                    //                                 child: Text(
                    //                                     obralocal.telefone
                    //                                         .replaceAll(
                    //                                             '+351', ''),
                    //                                     overflow:
                    //                                         TextOverflow.ellipsis,
                    //                                     style: TextStyle(
                    //                                         color: Colors.white,
                    //                                         wordSpacing: 2,
                    //                                         fontSize: 10,
                    //                                         letterSpacing: 4)),
                    //                                 onTap: () {
                    //                                   Utils.launchCaller(
                    //                                       util_call,
                    //                                       obralocal.telefone
                    //                                           .replaceAll(
                    //                                               '+351', ''));
                    //                                 },
                    //                               )),
                    //                         )
                    //                       ]),
                    //                 )
                    //               ],
                    //             ),
                    //           ),
                    //         ),
                    //       ],
                    //     ),
                    //   ],
                    // ),
                  )),
            ),
            SliverToBoxAdapter(
              child: Container(
                  width: double.infinity,

                  child: Container(
                    alignment: Alignment.topCenter,
                    child: Container(
                      height: 40,
                      child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(

                              child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: currentIndex == index
                                          ? Colors.grey
                                          .withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius:
                                      BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.transparent,
                                          width: 2)),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (currentIndex != index){
                                          pageIndex = 1;
                                          hasMore = true;
                                          currentIndex = index;
                                          lengthsliver = 1;
                                          // postRequest(
                                          //     currentIndex,
                                          //     centrallocal.codigo,
                                          //     datainicio,
                                          //     datafim,
                                          //     pageIndex);
                                        }

                                      });
                                    },
                                    child: new Text(categories[index],
                                        style: TextStyle(
                                            shadows: <Shadow>[
                                              index == currentIndex
                                                  ? Shadow(
                                                color: Color(
                                                    0xFF3ab1ff)
                                                    .withOpacity(
                                                    0.5),
                                                //spreadRadius: 3,
                                                blurRadius:
                                                8,
                                              )
                                                  : Shadow()
                                            ],
                                            color: index == currentIndex ? Color(0xFF73AEF5) : Colors.grey
                                                .withOpacity(0.9),
                                            fontSize: 14)),
                                  )

                              ));
                        },
                      ),
                    ),
                  )),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                switch (currentIndex) {
                  case 0:
                    return Container(
                        margin: new EdgeInsets.only(top: 5.0),
                        width: MediaQuery.of(context).size.width,
                        child: Column(children: [

                          buildCard(
                              0,
                              1,
                              translate('cliente'),
                              [
                                obralocal.cliente.codigo,
                                obralocal.cliente.nome
                              ],
                              null,
                              null),
                          buildCard(
                              1,
                              0,
                              "Sede cliente",
                              [
                                obralocal.cliente.morada
                              ],
                              null,
                              null),
                          buildCard(
                              2,
                              1,
                              translate('obra'),
                              [
                                obralocal.codigo,
                                obralocal.nome
                              ],
                              null,
                              null),
                          buildCard(
                              3,
                              0,
                              translate('morada'),
                              [
                                obralocal.morada,
                                obralocal.codpostal + ' ' + obralocal.cidade
                              ],
                              null,
                              null),
                          buildCard(
                              4,
                              1,
                              translate('contactos'),
                              [
                                obralocal.email,
                                obralocal.telefone
                              ],
                              null,
                              null),

                        ]));

                  case 1:
                  case 2:
                  case 3:
                }
              }, childCount: 1),
            ),
          ]),
        ),
      ),
    );
  }

  Widget buildCard(int indexCard, int titulinicial, String titulo, List<String> subtitulo,
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
                      initialPage: titulinicial,
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
