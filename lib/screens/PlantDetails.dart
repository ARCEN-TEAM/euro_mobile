import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:euro_mobile/screens/timelineTest.dart';
import 'package:euro_mobile/screens/widgets/my_arc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_carousel_slider/carousel_slider.dart';
import 'package:flutter_carousel_slider/carousel_slider_indicators.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:lottie/lottie.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart' as gauges;
import '../classes/enterExitPage.dart';
import '../classes/plant.dart';
import '../classes/invoice.dart';
import '../classes/order.dart';
import '../classes/utils.dart';
import '../classes/MapUtils.dart';
import '../classes/constants.dart';

//import 'WorkplaceDetails.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart' as charts;
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utilities/constants.dart';
import 'package:open_file/open_file.dart';
import 'InvoiceDetails.dart';
import 'OrderDetails.dart';
import 'WorkplaceDetails.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen(this.central, this.data);

  final Plant central;
  final String data;

  @override
  State<PlantScreen> createState() => _PlantScreenWidgetState();
}

List<Invoice> guias = [];
List<Order> pedidos = [];
List<Tab> tabs = [
  Tab(text: translate('resumo')),
  Tab(text: translate('pedidos')),
  Tab(text: translate('remessas')),
  Tab(text: translate('bombagens')),
];
var currentIndex = 1;
var pageIndex = 1;
var response;
var limit = 20;
bool hasMore = true;
bool postRequestLoading = false;
bool firstLoad = true;
bool noResults = false;
var lengthsliver = 0;
bool selectedorder = false;
bool selectedInvoice = false;
int downloadState = 0;

String dir = "";
var fileName = "";


var dio = Dio(BaseOptions(
    connectTimeout: 20000,
    receiveTimeout: 20000,
    baseUrl: ApiConstants.baseUrl,
    contentType: 'application/json',
    responseType: ResponseType.plain,
    headers: ApiConstants.headers));


class _PlantScreenWidgetState extends State<PlantScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController textController = TextEditingController();


  Order? orderselected;
  Invoice? invoiceSelected;
  Future postRequest(int index, String plantCode, String dataInicio,
      String DataFim, int page) async {

    if(!postRequestLoading)
    {


      bool localNoResults = false;
      bool localFirstLoad = false;
      setState(() {
        noResults = false;
        postRequestLoading = true;
      });
      if (page == 1) {
        guias = [];
        pedidos = [];
      }
      switch (index) {
        case 0:
          //TODO resumo
          break;
        case 1:
          if (hasMore) {
            var url = '${ApiConstants.baseUrl}'
                '${ApiConstants.plantEndpoint}'
                '/orders/?user='
                '${ApiConstants.UserLogged}'
                '&token='
                '${ApiConstants.ApiKey}'
                '&plant='
                '$plantCode'
                '&limit='
                '$limit'
                '&page='
                '$page'
                '&dateBegin='
                '${dataInicio.replaceAll("/", "-")}'
                '&dateEnd='
                '${DataFim.replaceAll("/", "-")}';

            response =
                await await dio.post(url,  options: Options(headers: ApiConstants.headers));
            var tempResp = await json.decode(response.data);

            if (tempResp != false && tempResp != null) {


              final List parsedJson = await json.decode(response.data);

              if (page == 1) {
                pedidos = [];
              }

              for (var data in parsedJson) {
                pedidos.add(Order.fromJson(data));
                if (Order.fromJson(data).totalrows ==
                    Order.fromJson(data).rownr) {
                  hasMore = false;
                }
              }

              setState(() {
                lengthsliver = pedidos.length;
                pageIndex += 1;
              });
            } else {
              setState(() {
                localFirstLoad = true;
                localNoResults = true;
              });
            }
          }
          break;
        case 2:
        case 3:
          if (hasMore) {
            var funcao = 'invoices';
            if (index == 3) {
              funcao = 'invoicespumping';
            }
            var url = '${ApiConstants.baseUrl}'
                '${ApiConstants.plantEndpoint}'
                '/$funcao/?user='
                '${ApiConstants.UserLogged}'
                '&token='
                '${ApiConstants.ApiKey}'
                '&plant='
                '$plantCode'
                '&limit='
                '$limit'
                '&page='
                '$page'
                '&dateBegin='
                '${dataInicio.replaceAll("/", "-")}'
                '&dateEnd='
                '${DataFim.replaceAll("/", "-")}';

            response =
                await http.post(Uri.parse(url), headers: ApiConstants.headers);
            var tempResp = await json.decode(response.body);

            if (tempResp != false && tempResp != null) {
              final List parsedJson = tempResp;
              if (page == 1) {
                guias = [];
              }

              for (var data in parsedJson) {
                guias.add(Invoice.fromJson(data));
                if (Invoice.fromJson(data).totalrows ==
                    Invoice.fromJson(data).rownr) {
                  hasMore = false;
                }
              }
              setState(() {
                lengthsliver = guias.length;
                pageIndex += 1;
              });
            } else {
              setState(() {
                localFirstLoad = true;
                localNoResults = true;
              });
            }
          } else {
            localFirstLoad = true;
          }
          break;
      }
      setState(() {
        firstLoad = localFirstLoad;
        noResults = localNoResults;
        postRequestLoading = false;
      });
    }
  }

  late PickerDateRange _valuesDate;

  String datainicio = '01/05/2022';
  String datafim = '31/05/2022';
  String datarange = '01/05/2022 - 31/05/2022';
  var _scrollController;
  var _scrollController2;
  var _scrollController3;
      late TabController _tabController;

  late CarouselSliderController _sliderController;
  List<String> clipboard = [];

  @override
  void initState() {
    _sliderController = CarouselSliderController();

    selectedorder = false;
    selectedInvoice = false;
    _scrollController = ScrollController();
    _scrollController2 = ScrollController();
    _scrollController3 = ScrollController();
    _tabController = TabController(vsync: this, length: tabs.length,initialIndex: currentIndex);
    super.initState();
    datainicio = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data));
    datafim = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data));
    datarange = '$datainicio - $datafim';

    _valuesDate = PickerDateRange(
        DateTime.parse(widget.data), DateTime.parse(widget.data));

    setState(() {
      {
        firstLoad = true;
        lengthsliver = 0;
        pageIndex = 1;
        hasMore = true;
        postRequest(currentIndex, widget.central.codigo, datainicio, datafim,
            pageIndex);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Plant centrallocal = widget.central;
    _tabController.addListener(() {
      if(  !_tabController.indexIsChanging){
        setState(() {
          //print(_tabController.index);
          selectedorder = false;
          selectedInvoice = false;
          currentIndex = _tabController.index;
          pageIndex = 1;
          hasMore = true;
          firstLoad = true;
          lengthsliver = 0;
          postRequest(
              _tabController.index,
              centrallocal.codigo,
              datainicio,
              datafim,
              pageIndex);
        });
      }


    });
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(

          backgroundColor: AppColors.transparent,
          bottomOpacity: 0.0,
          leading: IconButton(
            icon:   Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          elevation: 0,
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon:   Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      backgroundColor: AppColors.cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      context: context,
                      builder: (context) {
                        // Using Wrap makes the bottom sheet height the height of the content.
                        // Otherwise, the height will be half the height of the screen.
                        return Wrap(
                            children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 12, 0, 0),
                                  child: Container(
                                    width: 50,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Color(0xFFDBE2E7),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ]),
                          StatefulBuilder(builder:
                              (BuildContext context, StateSetter setStateSB) {
                            return Container(
                                margin: const EdgeInsets.only(top: 20.0),
                                child: Column(
                                  children: [
                                    Text(
                                      '$datarange',
                                      style: TextStyle(color: Colors.white,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    //SizedBox(height: 40),
                                    SfDateRangePicker(
                                      view: DateRangePickerView.month,
                                      monthCellStyle: DateRangePickerMonthCellStyle(
                                        todayTextStyle: TextStyle(color: AppColors.selectedItemTextColor),
                                        todayCellDecoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(color:AppColors.selectedItemTextColor)
                                        ),
                                      ),
                                      monthViewSettings:
                                      DateRangePickerMonthViewSettings(
                                          showTrailingAndLeadingDates:
                                          true),
                                      selectionTextStyle: TextStyle(color:Colors.white, fontWeight: FontWeight.bold),
                                      selectionColor: ApiConstants.mainColor,
                                      startRangeSelectionColor:ApiConstants.mainColor,
                                      endRangeSelectionColor:ApiConstants.mainColor,
                                      rangeSelectionColor: ApiConstants.mainColor.withOpacity(0.4),
                                      rangeTextStyle: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                      onSelectionChanged:
                                          (DateRangePickerSelectionChangedArgs
                                      args) {
                                        if (args.value is PickerDateRange) {
                                          setStateSB(() {
                                            datarange = DateFormat('dd/MM/yyyy')
                                                .format(
                                                args.value.startDate)
                                                .toString() +
                                                ' - ' +
                                                DateFormat('dd/MM/yyyy')
                                                    .format(args
                                                    .value.endDate ??
                                                    args.value.startDate)
                                                    .toString();
                                          });

                                          datainicio = datarange
                                              .split(' - ')[0]
                                              .replaceAll('/', '-');
                                          datafim = datarange
                                              .split(' - ')[1]
                                              .replaceAll('/', '-');

                                          _valuesDate = PickerDateRange(
                                              DateTime.parse(DateFormat(
                                                  'yyyy-MM-dd')
                                                  .format(args.value.startDate)
                                                  .toString()),
                                              DateTime.parse(
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(args
                                                      .value.endDate ??
                                                      args.value.startDate)
                                                      .toString()));
                                        }
                                      },
                                      selectionMode:DateRangePickerSelectionMode.range,
                                      initialSelectedRange: _valuesDate,
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        setState(() {
                                          pageIndex = 1;
                                          hasMore = true;
                                          lengthsliver = 0;
                                          postRequest(
                                              currentIndex,
                                              widget.central.codigo,
                                              datainicio,
                                              datafim,
                                              pageIndex);
                                        });
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(translate('aplicar'), style: TextStyle(color: AppColors.textColorOnDarkBG),),
                                      style: ElevatedButton.styleFrom(
  elevation: 5, backgroundColor: AppColors.buttonPrimaryColor),
                                    )
                                  ],
                                ));
                          }),
                        ]);
                      },
                    );
                  },
                ))
          ]),
      body: Container(
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
        child: NotificationListener<ScrollNotification>(

          onNotification: (ScrollNotification scrollInfo) {

            if (scrollInfo.metrics.pixels ==
                scrollInfo.metrics.maxScrollExtent && (scrollInfo.metrics.axisDirection == AxisDirection.down)) {
              // here you update your data or load your data from network
              setState(() {
                if (!postRequestLoading && hasMore && !noResults) {
                  postRequest(currentIndex, centrallocal.codigo, datainicio,
                      datafim, pageIndex);
                }
              });
            }
            return true;
          },
          child: NestedScrollView(
            controller: _scrollController,
            physics: BouncingScrollPhysics(),

            headerSliverBuilder: (BuildContext context,
                bool innerBoxIsScrolled) {
              return <Widget>[
                SliverAppBar(


                  automaticallyImplyLeading: false,
                  snap: false,

                  pinned: false,
                  floating: false,
                  forceElevated: innerBoxIsScrolled,

                  backgroundColor: Color(0x00000000),
                  flexibleSpace: FlexibleSpaceBar(
                      titlePadding: EdgeInsetsDirectional.only(
                          start: 30, bottom: 70),
                      title: SingleChildScrollView(
                          child: ListTile(
                              leading: Padding(
                                  padding: const EdgeInsets.only(left: 7.0),
                                  child: new GestureDetector(
                                      onTap: () {
                                        MapUtils.openMap(
                                            centrallocal.gps.latitude,
                                            centrallocal.gps.longitude);
                                      },
                                      child: Hero(
                                        tag: 'plant-' + centrallocal.codigo,
                                        child: Container(
                                          width: 80,
                                          height: 80,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.blue,
                                          ),
                                          child: Align(
                                            alignment: AlignmentDirectional(
                                                0, 0),
                                            child: CachedNetworkImage(
                                              placeholder: (context, url) => const CircularProgressIndicator(),
                                              imageUrl: 'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                                                  centrallocal.gps.longitude
                                                      .toString() +
                                                  ',' +
                                                  centrallocal.gps.latitude
                                                      .toString() +
                                                  ')/' +
                                                  centrallocal.gps.longitude
                                                      .toString() +
                                                  ',' +
                                                  centrallocal.gps.latitude
                                                      .toString() +
                                                  ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw',
                                            ),
                                          ),
                                        ),
                                      ))),
                              title: Container(
                                  child: Text(
                                    centrallocal.nome,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.white,),
                                  )),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[

                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                        children: <Widget>[
                                          Icon(Icons.phone_android_rounded,
                                              color: Colors.white, size: 17),
                                          Padding(
                                              padding: const EdgeInsets.only(
                                                  left: 8.0),
                                              child: InkWell(
                                                child: Text(
                                                    centrallocal.telefone,
                                                    style: TextStyle(
                                                        color: Colors.white,
                                                        wordSpacing: 2,
                                                        fontSize: 12,
                                                        letterSpacing: 4)),
                                                onTap: () {
                                                  Utils.launchCaller(util_call,
                                                      centrallocal.telefone);
                                                },
                                              ))
                                        ]),
                                  )
                                ],
                              ))

                      )),
                  bottom: TabBar(

                    indicator: BoxDecoration(

                        color:   Colors.grey.withOpacity(0.1),

                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: Colors.transparent, width: 2)
                    ),
                     labelStyle: TextStyle(

                         shadows: <Shadow>[
                           Shadow(
                             color: Color(0xFF3ab1ff)
                                 .withOpacity(0.5),
                             //spreadRadius: 3,
                             blurRadius: 8,
                           )

                         ],
                         color:  Color(0xFF73AEF5),
                         fontSize: 16),
                    unselectedLabelColor: Colors.grey.withOpacity(0.9),
                    labelColor: Color(0xFF73AEF5),
                    unselectedLabelStyle: TextStyle(
                        color:  Colors.grey.withOpacity(0.9),
                        fontSize: 16),
                    isScrollable: true,
                    physics: BouncingScrollPhysics(),
                    enableFeedback: true,

                    padding: EdgeInsets.only(bottom: 10),
                    tabs: tabs,
                    controller: _tabController,
                  ),
                ),
              ];
            }, body: Align(
              alignment: Alignment.topLeft,
          child: OrientationBuilder(
              builder: (_, orientation) {

                if (orientation == Orientation.portrait) {
                  return TabBarView(

                      controller: _tabController,
                      children:
                      List<Widget>.generate(tabs.length, (index) =>  buildTabViews(index==currentIndex))
                  );
                } else {
                  return Row(
                    children: [
                      Container(
                          width: MediaQuery.of(context).size.width / 2,
                          child: TabBarView(
                                controller: _tabController,
                                children:
                                List<Widget>.generate(tabs.length, (index) =>  buildTabViews(index==currentIndex))

                        ),
                      ),
                      Expanded(
                        child: sideViewDetails()

                      )
                    ],
                  );
                } // else show the landscape one
              }
          )
            ),
            )

        ),
      ),
    );
  }
  sideViewDetails(){
    switch(currentIndex) {
      case 1:
        return (selectedorder) ? OrderDetailsLandScape(orderselected!) : Container();
       case 2:
      case 3:
      return (selectedInvoice) ? InvoiceDetailsLandScape(invoiceSelected!) : Container();

    }
    return Container();
  }
  Widget buildTabViews(tabIndex) {

   if(tabIndex){

     if ((!postRequestLoading && !noResults) || !firstLoad) {
       return  MediaQuery.removePadding(
         context: context,
         removeTop: true,
         child:
         CupertinoScrollbar(

           controller: _scrollController3,
           child: CustomScrollView(
      controller: _scrollController3,

               slivers: [
                 SliverList(
                     delegate: SliverChildBuilderDelegate(
                           (BuildContext context, int index) {
                         switch (currentIndex) {
                           case 1:
                             if (pedidos.isNotEmpty) {
                               return buildCardOrder(pedidos[index]);
                             }
                             break;

                           case 2:
                           case 3:
                             if (guias.isNotEmpty) {
                               return buildCardInvoice(guias[index]);
                             }
                             break;
                         }
                         return Container();
                       },
                       // 40 list items
                       childCount: lengthsliver,
                     ))]),
         ),
       );

     }
     else {
       return   Container(
         decoration: BoxDecoration(
           color: AppColors.transparent,
         ),
         child: Center(
           //     child: CircularProgressIndicator(
           //   color: Color(0xFF73AEF5),
           // )
             child: (!noResults)
                 ? Lottie.asset('assets/images/lotties/search.json')
                 : Opacity(
               opacity: 0.2,
               child: Lottie.asset(
                   'assets/images/lotties/notfound.json',
                   repeat: false),
             )),
       );

     }
   }else{
     return Container();
   }

  }

  Widget buildCardInvoice(Invoice guia) {


    if (MediaQuery.of(context).orientation == Orientation.portrait){

      return GestureDetector(
          onTap: () {
            Navigator.of(context).push(
                PageRouteBuilder(
                    fullscreenDialog: true,
                    pageBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return InvoiceDetail(central: widget.central, guia: guia);
                    },
                    transitionDuration: Duration(milliseconds: 300),
                    transitionsBuilder: (BuildContext context,
                        Animation<double> animation,
                        Animation<double> secondaryAnimation,
                        Widget child,) {
                      return SlideTransition(

                        position: Tween<Offset>(
                          begin: const Offset(0.0, 1.0),
                          end: Offset.zero,
                        ).animate(
                            CurvedAnimation(
                              parent: animation,
                              curve: Curves.fastOutSlowIn,
                            )),
                        child: child, // child is the value returned by pageBuilder
                      );
                    }
                )
            );
          },
          child: invoiceCard(guia));
    }// if orientation is portrait, show your portrait layout
    else {
      return GestureDetector(
          onTap: () {

            setState(() {

              clipboard.add(guia.obra.cliente.nome);
              clipboard.add(guia.obra.nome);
              clipboard.add(guia.receita);
              if(guia.codigo != invoiceSelected?.codigo){
                selectedInvoice = true;
                invoiceSelected = guia;
              }else{
                selectedInvoice = !selectedInvoice;

              }

            });
          },
          child: invoiceCard(guia));
    }
  }

  Widget invoiceCard(Invoice guia){
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration: BoxDecoration(
        color: Color(0x00000000),
        border: Border.all(width: 0, color: Color(0x00000000)),
      ),
      child: Card(
        color: Color(0xFF172842),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
        ),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: ListTile(
          dense: true,
          contentPadding:
          EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          leading: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(

                guia.prod_delivered.toString() + ' m³',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white),
              ),
            ],
          ),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                guia.codigo,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF40a1f0),
                  shadows: <Shadow>[
                    Shadow(
                      color: Color(0xFF3ab1ff).withOpacity(0.5),
                      //spreadRadius: 3,
                      blurRadius: 3,
                    )
                  ],
                ),
              ),
              Text(guia.data_hora,
                  style: TextStyle(fontSize: 12, color: Colors.white)),
            ],
          ),

          // subtitle: Text("Intermediate", style: TextStyle(color: Colors.white)),

          subtitle: Column(
            children: <Widget>[
              Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                            child: Text(
                              guia.obra.cliente.nome,
                              overflow: TextOverflow.fade,
                              maxLines: 1,
                              softWrap: false,
                              style: TextStyle(
                                  color: Colors.white.withOpacity(0.8)),
                            )),
                      ])),
              Align(
                  alignment: AlignmentDirectional.centerStart,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                          child: Text(
                            guia.obra.nome,
                            overflow: TextOverflow.fade,
                            maxLines: 1,
                            softWrap: false,
                            style:
                            TextStyle(color: Colors.white.withOpacity(0.8)),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: Container(
                            padding: EdgeInsets.only(left: 10,
                                right: 10,
                                top: 3,
                                bottom: 3),
                            decoration: BoxDecoration(color: AppColors
                                .backgroundBlue,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              guia.rownr + '/' + guia.totalrows,
                              style: TextStyle(color: Colors.white),
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCardOrder(Order pedido) {
        if (MediaQuery.of(context).orientation == Orientation.portrait){

          return GestureDetector(
            onTap: () {

              Navigator.of(context).push(
                  PageRouteBuilder(
                      fullscreenDialog: true,
                      pageBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation) {
                        return OrderDetails(pedido: pedido, central: widget.central);
                      },
                      transitionDuration: Duration(milliseconds: 300),
                      transitionsBuilder: (BuildContext context,
                          Animation<double> animation,
                          Animation<double> secondaryAnimation,
                          Widget child,) {
                        return SlideTransition(

                          position: Tween<Offset>(
                            begin: const Offset(0.0, 1.0),
                            end: Offset.zero,
                          ).animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.fastOutSlowIn,
                              )),
                          child: child, // child is the value returned by pageBuilder
                        );
                      }
                  )
              );
            },
            child: OrderCard(pedido));
        }// if orientation is portrait, show your portrait layout
        else {
          return GestureDetector(
              onTap: () {

                setState(() {

                  clipboard.add(pedido.obra.cliente.nome);
                  clipboard.add(pedido.obra.nome);
                  clipboard.add(pedido.receita);
                  if(orderselected != null){
                    if(pedido.codref != orderselected?.codref){
                      selectedorder = true;
                      orderselected = pedido;
                    }else{
                      selectedorder = !selectedorder;

                    }
                  }else{
                    selectedorder = true;
                    orderselected = pedido;
                  }


                });
              },
              child: OrderCard(pedido));
        } // else show the landscape one
  }

  Widget OrderCard(Order pedido){
    return Container(
      width: MediaQuery
          .of(context)
          .size
          .width,
      decoration: BoxDecoration(
        color: Color(0x00000000),
        border: Border.all(width: 0, color: Color(0x00000000)),
      ),
      child: Card(
        color: Color(0xFF172842),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // if you need this
        ),
        margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        child: ClipPath(
          clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10))),
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                  left: BorderSide(
                      color: Color(int.parse(pedido.statusColor)),
                      width: 10
                  )
              ),
            ),
            alignment: Alignment.centerLeft,
            child: ListTile(
              dense: true,
              visualDensity: VisualDensity(vertical: 4),
              contentPadding:
              EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              leading: Container(
                //decoration: BoxDecoration(border: Border.all(color: Colors.red)),
                constraints: BoxConstraints(maxWidth: 60),
                child: Column(
                  //mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Text(
                            pedido.prod_delivered.toString() +
                                '/' +
                                pedido.prod_desired.toString(),
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: Colors.white))),
                    Flexible(
                      flex: 4,
                      fit: FlexFit.loose,
                      child: charts.SfCircularChart(
                          annotations: <charts.CircularChartAnnotation>[
                            charts.CircularChartAnnotation(
                              widget: Container(
                                  child: Text(
                                      (pedido.prod_delivered /
                                          pedido.prod_desired *
                                          100)
                                          .toStringAsFixed(0) +
                                          '%',
                                      style: TextStyle(fontSize: 11,
                                          color: Colors.white))),
                            )
                          ],
                          margin: EdgeInsets.all(5),
                          series: <charts.CircularSeries>[
                            // Render pie chart
                            charts.RadialBarSeries<ChartData, String>(
                              dataSource: <ChartData>[
                                ChartData('m3', pedido.prod_delivered)
                              ],
                              xValueMapper: (ChartData data, _) => data.x,
                              yValueMapper: (ChartData data, _) => data.y,
                              pointColorMapper: (ChartData data, _) =>
                              (pedido.statusColor == "0x00ffffff"
                                  ? AppColors.buttonPrimaryColor
                                  : Color(int.parse(pedido.statusColor))),
                              cornerStyle: (pedido.prod_delivered ==
                                  pedido.prod_desired
                                  ? charts.CornerStyle.bothFlat
                                  : charts.CornerStyle.bothCurve),
                              maximumValue: pedido.prod_desired,
                              radius: '100%',
                              innerRadius: '80%',
                            )
                          ]),
                    )
                  ],
                ),
              ),

              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    pedido.cod,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF40a1f0),
                      shadows: <Shadow>[
                        Shadow(
                          color: Color(0xFF3ab1ff).withOpacity(0.5),
                          //spreadRadius: 3,
                          blurRadius: 3,
                        )
                      ],
                    ),
                  ),
                  Text(pedido.date,
                      style: TextStyle(fontSize: 12, color: Colors.white)),
                ],
              ),

              subtitle: Column(
                children: <Widget>[
                  Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                                child: Text(
                                    pedido.obra.cliente.nome,
                                    overflow: TextOverflow.fade,
                                    maxLines: 1,
                                    softWrap: false,
                                    style: TextStyle(color: Colors.white)
                                )),
                          ])),
                  Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                              child: Text(
                                  pedido.obra.nome,
                                  overflow: TextOverflow.fade,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(color: Colors.white)
                              )),
                          Padding(
                            padding: const EdgeInsets.only(left: 15),
                            child: Container(
                                padding: EdgeInsets.only(
                                    left: 10, right: 10, top: 3, bottom: 3),
                                decoration: BoxDecoration(
                                    color: AppColors.backgroundBlue,
                                    borderRadius: BorderRadius.circular(
                                        10)),
                                child: Text(
                                  pedido.rownr + '/' + pedido.totalrows,
                                  style: TextStyle(color: Colors.white),
                                )),
                          )

                        ],
                      )),
                ],
              ),
              /*trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(guia.data_hora),
                      Text(
                        guia.prod_delivered.toString() + ' m³',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      )
                    ],
                  ),*/
            ),
          ),
        ),
      ),
    );
  }

  Widget OrderDetailsLandScape(Order pedidolocal){

    return Container(
        height: double.infinity,
        width: double.infinity,
        child: Card(
          color: Color(0xFF172842),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // if you need this
          ),
          margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            child: MediaQuery.removePadding(

              context: context,
              removeTop: true,

              child: CupertinoScrollbar(
                controller: _scrollController2,
                child: SingleChildScrollView(
                  padding: EdgeInsets.all(10),
                      controller: _scrollController2,
                      physics: BouncingScrollPhysics(),
                      child:   Padding(
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
                                            mainAxisAlignment:
                                            MainAxisAlignment.start,
                                            crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                pedidolocal.cod,
                                                style: TextStyle(
                                                    color:
                                                    AppColors.textColorOnDarkBG,
                                                    fontSize: 20),
                                              ),
                                              Text(
                                                pedidolocal.date,
                                                style: TextStyle(
                                                    color:
                                                    AppColors.textColorOnDarkBG,
                                                    fontSize: 15),
                                              ),
                                              SizedBox(
                                                height: 20,
                                              ),
                                              Text(
                                                pedidolocal.codref,
                                                style: TextStyle(
                                                    color:
                                                    AppColors.textColorOnDarkBG,
                                                    fontSize: 15),
                                              ),
                                            ],
                                          ),
                                          Flexible(
                                            child: Stack(
                                              children: [
                                                Container(
                                                  margin: EdgeInsets.only(top: 55),
                                                  child: gauges.SfRadialGauge(
                                                      enableLoadingAnimation: false,
                                                      animationDuration: 2000,
                                                      axes: <gauges.RadialAxis>[
                                                        gauges.RadialAxis(
                                                          canScaleToFit: true,
                                                          showLastLabel: true,
                                                          maximumLabels: pedidolocal
                                                              .prod_desired
                                                              .toInt(),
                                                          showLabels: true,
                                                          showTicks: true,
                                                          startAngle: 180,
                                                          endAngle: 0,
                                                          interval: pedidolocal
                                                              .prod_desired /
                                                              5,
                                                          radiusFactor: 2.5,
                                                          maximum: pedidolocal
                                                              .prod_desired,
                                                          canRotateLabels: true,
                                                          pointers: <gauges.GaugePointer>[
                                                            gauges.RangePointer(
                                                                gradient:
                                                                SweepGradient(
                                                                    colors: [
                                                                      const Color(
                                                                          0xFF3a9bea),
                                                                      const Color(
                                                                          0xFF2E4E7C),
                                                                      const Color(
                                                                          0xFF132642),
                                                                    ]
                                                                        .reversed
                                                                        .toList(),
                                                                    stops: <double>[
                                                                      0.2,
                                                                      0.5,
                                                                      0.8
                                                                    ]),
                                                                value: pedidolocal
                                                                    .prod_delivered,
                                                                width: 0.1,
                                                                color: AppColors
                                                                    .buttonPrimaryColor,
                                                                sizeUnit:
                                                                gauges.GaugeSizeUnit
                                                                    .factor,
                                                                cornerStyle:
                                                                gauges.CornerStyle
                                                                    .bothCurve),
                                                            if (pedidolocal
                                                                .prod_delivered >
                                                                0 &&
                                                                pedidolocal
                                                                    .prod_delivered <
                                                                    pedidolocal
                                                                        .prod_desired) ...[
                                                              gauges.MarkerPointer(
                                                                  value: pedidolocal
                                                                      .prod_delivered,
                                                                  markerOffset: -5,
                                                                  color:
                                                                  Colors.white),
                                                              gauges.WidgetPointer(
                                                                offset: -20,
                                                                value: pedidolocal
                                                                    .prod_delivered,
                                                                child: Text(
                                                                  pedidolocal
                                                                      .prod_delivered
                                                                      .toString(),
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontSize: 12,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                                ),
                                                              ),
                                                            ]
                                                          ],
                                                        )
                                                      ]),
                                                ),
                                                Center(
                                                    child: Padding(
                                                      padding: const EdgeInsets.only(
                                                          top: 70),
                                                      child: Column(
                                                        mainAxisAlignment:
                                                        MainAxisAlignment.center,
                                                        children: [
                                                          Text(
                                                            (pedidolocal.prod_delivered /
                                                                pedidolocal
                                                                    .prod_desired *
                                                                100)
                                                                .round()
                                                                .toString() +
                                                                '%',
                                                            style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 18,
                                                                fontWeight:
                                                                FontWeight.bold),
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
                                SizedBox(
                                  height: 25,
                                ),
                                buildCard(
                                    0,
                                    translate('cliente'),
                                    [
                                      pedidolocal.obra.cliente.codigo,
                                      pedidolocal.obra.cliente.nome
                                    ],
                                    null,
                                    null),
                                buildCard(
                                    1,
                                    translate('obra'),
                                    [
                                      pedidolocal.obra.codigo,
                                      pedidolocal.obra.nome
                                    ],
                                    Icon(Icons.chevron_right, color: Colors.white),
                                    WorkplaceScreen(pedidolocal.obra)),
                                buildCard(
                                    2,
                                    translate('composicao'),
                                    [pedidolocal.cod_receita, pedidolocal.receita],
                                    null,
                                    null),
                              ],
                            )),
                ),
              ),
            ),
            ));
  }


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
  getDir(String inv) async{
    String localdir = (await getApplicationDocumentsDirectory()).path;
    var fileNamedir = inv.replaceAll('/', '-') + '.pdf';

    bool exists = await File("$localdir/$fileNamedir").exists();

    setState(() {
      dir = localdir;
      fileName = fileNamedir;

      if(exists){
        downloadState = 2;
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
          downloadState = 2;
        });
        return;
      });
    });
  }
  Widget InvoiceDetailsLandScape(Invoice guialocal){





    return Card(
      color: Color(0xFF172842),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10), // if you need this
      ),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: MediaQuery.removePadding(
        context: context,
        removeTop: true,
        child: CupertinoScrollbar(
          controller: _scrollController2,
          child: SingleChildScrollView(
            controller: _scrollController2,
            physics: BouncingScrollPhysics(),
              child: Padding(
                padding: EdgeInsets.only(top: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0, right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                setState(() {
                                  switch (downloadState) {
                                    case 0: //idle
                                      GetInvoice(widget.central.codigo, guialocal.codigo,
                                          guialocal.inv_type);
                                      downloadState = 1;
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
                                child: downloadProgress(downloadState),
                              ),
                            ),
                          )
                        ],
                      )
                    ),
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
                                guialocal.codigo,
                                style: TextStyle(
                                    color: AppColors.textColorOnDarkBG,
                                    fontSize: 20),
                              ),
                              Text(
                                guialocal.data_hora.substring(0, 10),
                                style: TextStyle(
                                    color: AppColors.textColorOnDarkBG,
                                    fontSize: 15),
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              Text(
                                guialocal.ord_code,
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
                                        guialocal.prod_delivered.toString(),
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
                          guialocal.obra.cliente.codigo,
                          guialocal.obra.cliente.nome
                        ],
                        null,
                        null),
                    buildCard(
                        1,
                        translate('obra'),
                        [guialocal.obra.codigo, guialocal.obra.nome],
                        Icon(Icons.chevron_right, color: Colors.white),
                        WorkplaceScreen(guialocal.obra)),
                    buildCard(2, translate('composicao'),
                        [guialocal.cod_receita, guialocal.receita], null, null),
                    buildCard(3, translate('camiao'),
                        [guialocal.camiao, guialocal.motorista], null, null),
                    DeliveryTimeline(
                        timeList: [
                          guialocal.data_hora.substring(11), //inicio carga
                          //guialocal.fimcarga, //fim carga
                          guialocal.saidacentral, //saida central
                          guialocal.chegadaobra, //chegada obra
                          guialocal.iniciodescarga, //inicio descarga
                          guialocal.saidaobra, //saida obra
                          guialocal.chegadacentral //chegada central
                        ],
                        lastTimestmp: (guialocal.chegadacentral != "")
                            ? 6
                            : (guialocal.saidaobra != "")
                            ? 5
                            : (guialocal.iniciodescarga != "")
                            ? 4
                            :  (guialocal.chegadaobra != "")
                            ? 3
                            :  (guialocal.saidacentral != "")
                            ? 2
                            : 1,
                        inv_type: guialocal.inv_type)
                  ],
                ),
              ),
            ),
        ),
      ),

    );
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
                        GlobalFunctions.showToast(
                            context,
                            " '" +
                                clipboard[indexCard] +
                                "' " +
                                translate('copiado') +
                                "!");
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



List<InvoiceChart> getChartInvoices() {
  return <InvoiceChart>[
    InvoiceChart(
        date: DateTime.now().add(Duration(days: -3)), delivered: 130.2),
    InvoiceChart(
        date: DateTime.now().add(Duration(days: -2)), delivered: 150.2),
    InvoiceChart(date: DateTime.now().add(Duration(days: -1)), delivered: 12.2),
    InvoiceChart(date: DateTime.now(), delivered: 122.2),
  ];
}

class InvoiceChart {
  InvoiceChart({required this.date, required this.delivered});

  final DateTime date;
  final double delivered;
}

class ChartData {
  ChartData(this.x, this.y);

  final String x;
  final double y;
}

class ChartDataResume {
  ChartDataResume(this.x, this.y);

  final String x;
  final int y;
}