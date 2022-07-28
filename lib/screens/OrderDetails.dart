import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../classes/constants.dart';
import '../classes/order.dart';
import '../classes/enterExitPage.dart';

import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';

import 'WorkplaceDetails.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

class OrderDetails extends StatefulWidget {
  const OrderDetails({required this.pedido});

  final Order pedido;

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  late CarouselSliderController _sliderController;
  List<String> clipboard = [];

  @override
  void initState() {
    super.initState();
    _sliderController = CarouselSliderController();

    clipboard.add(widget.pedido.obra.cliente.nome);
    clipboard.add(widget.pedido.obra.nome);
    clipboard.add(widget.pedido.receita);
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
            colors: AppColors.backgroundGradientColors,
            radius: 1.2,
          ),
        ),
        child: Scaffold(
            appBar: new AppBar(
              iconTheme: IconThemeData(color: AppColors.textColorOnDarkBG),
              elevation: 0.0,
              backgroundColor: Colors.transparent,
              centerTitle: true,
              title: Text(
                translate('pedido'),
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textColorOnDarkBG),
              ),
            ),
            body: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 110,
                          child: Padding(
                              padding: const EdgeInsets.only(left: 35),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        widget.pedido.cod,
                                        style: TextStyle(
                                            color: AppColors.textColorOnDarkBG,
                                            fontSize: 20),
                                      ),
                                      Text(
                                        widget.pedido.date,
                                        style: TextStyle(
                                            color: AppColors.textColorOnDarkBG,
                                            fontSize: 15),
                                      ),
                                      SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        widget.pedido.codref,
                                        style: TextStyle(
                                            color: AppColors.textColorOnDarkBG,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                                  Flexible(
                                    child: Stack(
                                      children: [
                                        Container(
                                          margin: EdgeInsets.only(top: 55),
                                          child:
                                              SfRadialGauge(
                                                enableLoadingAnimation: true,
                                                  animationDuration: 2000,

                                                  axes: <RadialAxis>[
                                            RadialAxis(

                                              canScaleToFit: true,
                                              showLastLabel: true,
                                              maximumLabels: widget
                                                  .pedido.prod_desired
                                                  .toInt(),
                                              showLabels: true,
                                              showTicks: true,
                                              startAngle: 180,
                                              endAngle: 0,
                                              interval:
                                                  widget.pedido.prod_desired /
                                                      5,
                                              radiusFactor: 2.5,
                                              maximum:
                                                  widget.pedido.prod_desired,
                                              canRotateLabels: true,
                                              pointers: <GaugePointer>[

                                                RangePointer(
                                                    gradient: SweepGradient(
                                                        colors: [
                                                          const Color(
                                                              0xFF3a9bea),
                                                          const Color(
                                                              0xFF2E4E7C),
                                                          const Color(
                                                              0xFF132642),
                                                        ].reversed.toList(),
                                                        stops: <double>[
                                                          0.2,
                                                          0.5,
                                                          0.8
                                                        ]),
                                                    value: widget
                                                        .pedido.prod_delivered,
                                                    width: 0.1,
                                                    color: AppColors
                                                        .buttonPrimaryColor,
                                                    sizeUnit:
                                                        GaugeSizeUnit.factor,
                                                    cornerStyle:
                                                        CornerStyle.bothCurve),
                                                 if(widget
                                                     .pedido.prod_delivered>0 && widget
                                                     .pedido.prod_delivered<widget
                                                     .pedido.prod_desired)...[
                                                   MarkerPointer(
                                                       value: widget
                                                           .pedido.prod_delivered,
                                                       markerOffset: -5,
                                                       color: Colors.white),
                                                   WidgetPointer(
                                                     offset: -25,
                                                     value: widget
                                                         .pedido.prod_delivered,
                                                     child: Text(
                                                       widget.pedido.prod_delivered
                                                           .toString(),
                                                       style: TextStyle(
                                                           color: Colors.white,
                                                           fontSize: 12,
                                                           fontWeight:
                                                           FontWeight.bold),
                                                     ),
                                                   ),
                                                 ]

                                              ],
                                            )
                                          ]),
                                        ),
                                        Center(
                                            child: Padding(
                                          padding:
                                              const EdgeInsets.only(top: 70),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                (widget.pedido.prod_delivered /
                                                            widget.pedido
                                                                .prod_desired *
                                                            100)
                                                        .round()
                                                        .toString() +
                                                    '%',
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18,fontWeight: FontWeight.bold),
                                              ),
                                            ],
                                          ),
                                        ))
                                      ],
                                    ),
                                  ),
                                ],
                              )),
                        ),
                        SizedBox(height: 25,),
                        buildCard(
                            0,
                            translate('cliente'),
                            [
                              widget.pedido.obra.cliente.codigo,
                              widget.pedido.obra.cliente.nome
                            ],
                            null,
                            null),
                        buildCard(
                            1,
                            translate('obra'),
                            [
                              widget.pedido.obra.codigo,
                              widget.pedido.obra.nome
                            ],
                            Icon(Icons.chevron_right, color: Colors.white),
                            WorkplaceScreen(widget.pedido.obra)),
                        buildCard(
                            2,
                            translate('composicao'),
                            [widget.pedido.cod_receita, widget.pedido.receita],
                            null,
                            null),
                      ],
                    )))));
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
                              Navigator.push(
                                context,
                                SlideInPageRoute(
                                    exitPage: widget, enterPage: screenRoute),
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
