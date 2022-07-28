import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
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
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import '../utilities/constants.dart';
import 'package:open_file/open_file.dart';
import 'InvoiceDetails.dart';
import 'OrderDetails.dart';

class PlantScreen extends StatefulWidget {
  const PlantScreen(this.central, this.data);

  final Plant central;
  final String data;

  @override
  State<PlantScreen> createState() => _PlantScreenWidgetState();
}

List<Invoice> guias = [];
List<Order> pedidos = [];
List<String> categories = ['Resumo', 'Pedidos', 'Guias', 'Bombagens'];
List<Tab> tabs = [
  Tab(text: 'Resumo'),
  Tab(text: 'Pedidos'),
  Tab(text: 'Guias'),
  Tab(text: 'Bombagens'),
];
var currentIndex = 0;
var pageIndex = 1;
var response;
var limit = 10;
bool hasMore = true;
bool postRequestLoading = false;
bool firstLoad = true;
bool noResults = false;
var lengthsliver = 0;

class _PlantScreenWidgetState extends State<PlantScreen>
    with SingleTickerProviderStateMixin {
  TextEditingController textController = TextEditingController();

  GetInvoice(String plantCode, String invoice, String tipoguia) async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }

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
    var response = httpClient.send(request);

    String dir = (await getApplicationDocumentsDirectory()).path;
    var fileName = invoice.replaceAll('/', '-') + '.pdf';
    List<List<int>> chunks = [];

    response.asStream().listen((http.StreamedResponse r) {
      r.stream.listen((List<int> chunk) {
        chunks.add(chunk);
      }, onDone: () async {
        // Save the file
        File file = new File('$dir/$fileName');
        int tamanho = int.parse(r.contentLength.toString());
        final Uint8List bytes = Uint8List(tamanho);
        int offset = 0;
        for (List<int> chunk in chunks) {
          bytes.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }
        await file.writeAsBytes(bytes);
        OpenFile.open("$dir/$fileName");
        return;
      });
    });
  }

  Future postRequest(int index, String plantCode, String dataInicio,
      String DataFim, int page) async {
    if(!postRequestLoading)
    {

      var tempResp;
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
     // print(index);
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
                await http.post(Uri.parse(url), headers: ApiConstants.headers);
            var tempResp = await json.decode(response.body);
            if (tempResp != false && tempResp != null) {


              final List parsedJson = await json.decode(response.body);

              if (page == 1) {
                pedidos = [];
              }

              parsedJson.forEach((dynamic data) {
                pedidos.add(Order.fromJson(data));
                if (Order.fromJson(data).totalrows ==
                    Order.fromJson(data).rownr) {
                  hasMore = false;
                }
              });

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

              parsedJson.forEach((dynamic data) {
                guias.add(Invoice.fromJson(data));
                if (Invoice.fromJson(data).totalrows ==
                    Invoice.fromJson(data).rownr) {
                  hasMore = false;
                }
              });
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
  String exemplo = '01/05/2022 - 31/05/2022';
  var _scrollController;
      late TabController _tabController;

  @override
  void initState() {
    _scrollController = ScrollController();
    _tabController = TabController(vsync: this, length: tabs.length);
    super.initState();
    datainicio = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data));
    datafim = DateFormat('dd/MM/yyyy').format(DateTime.parse(widget.data));
    exemplo = datainicio + ' - ' + datafim;

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
          leading: IconButton(
            icon: new Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () {
              Navigator.pop(context, true);
            },
          ),
          elevation: 0,
          backgroundColor: Color(0x00000000),
          actions: <Widget>[
            Padding(
                padding: const EdgeInsets.all(8.0),
                child: IconButton(
                  icon: new Icon(Icons.more_vert, color: Colors.white),
                  onPressed: () {
                    showModalBottomSheet(
                      isScrollControlled: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(20),
                        ),
                      ),
                      context: context,
                      builder: (context) {
                        // Using Wrap makes the bottom sheet height the height of the content.
                        // Otherwise, the height will be half the height of the screen.
                        return Wrap(children: [
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
                                      '$exemplo',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    //SizedBox(height: 40),
                                    SfDateRangePicker(
                                      view: DateRangePickerView.month,
                                      monthViewSettings:
                                      DateRangePickerMonthViewSettings(
                                          showTrailingAndLeadingDates:
                                          true),
                                      selectionColor: ApiConstants.mainColor,
                                      startRangeSelectionColor:
                                      ApiConstants.mainColor,
                                      endRangeSelectionColor:
                                      ApiConstants.mainColor,
                                      rangeSelectionColor: ApiConstants
                                          .mainColor
                                          .withOpacity(0.4),
                                      rangeTextStyle: const TextStyle(
                                          color: Colors.white, fontSize: 15),
                                      onSelectionChanged:
                                          (DateRangePickerSelectionChangedArgs
                                      args) {
                                        if (args.value is PickerDateRange) {
                                          setStateSB(() {
                                            exemplo = DateFormat('dd/MM/yyyy')
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

                                          datainicio = exemplo
                                              .split(' - ')[0]
                                              .replaceAll('/', '-');
                                          datafim = exemplo
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
                                      selectionMode:
                                      DateRangePickerSelectionMode.range,
                                      initialSelectedRange: _valuesDate,
                                    ),
                                    TextButton(
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
                                      child: Text("Apply"),
                                      style: TextButton.styleFrom(
                                        elevation: 10,
                                      ),
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

                  forceElevated: true,
                  floating: false,
                  automaticallyImplyLeading: false,
                  snap: false,
                  pinned: false,

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
                                            child: Image.network(
                                                'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
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
                                                    ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw'),
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

                    tabs: tabs,
                    controller: _tabController,
                  ),
                ),
              ];
            }, body: TabBarView(

            controller: _tabController,
            children:  [
              buildTabViews(0==currentIndex),
              buildTabViews(1==currentIndex),
              buildTabViews(2==currentIndex),
              buildTabViews(3==currentIndex)
            ]


          ),)

          /*CustomScrollView(slivers: <Widget>[
            SliverAppBar(
              forceElevated: true,
              floating: false,
              automaticallyImplyLeading: false,
              snap: false,
              pinned: false,

              backgroundColor: Color(0x00000000),
              flexibleSpace: FlexibleSpaceBar(
                  titlePadding: EdgeInsetsDirectional.only(start: 20, bottom: 16),
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
                                  alignment: AlignmentDirectional(0, 0),
                                  child: Image.network(
                                      'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
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
                                          ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw'),
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
                            subtitle:Column(
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
                        itemCount: (categories == null ? 0 : categories.length),
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                              child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                      color: currentIndex == index
                                          ? Colors.grey.withOpacity(0.1)
                                          : Colors.transparent,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                          color: Colors.transparent, width: 2)),
                                  child: TextButton(
                                    onPressed: () {
                                      setState(() {
                                        if (currentIndex != index) {
                                          pageIndex = 1;
                                          hasMore = true;
                                          currentIndex = index;
                                          firstLoad = true;
                                          lengthsliver = 0;
                                          postRequest(
                                              currentIndex,
                                              centrallocal.codigo,
                                              datainicio,
                                              datafim,
                                              pageIndex);
                                        }
                                      });
                                    },
                                    child: new Text(categories[index],
                                        style: TextStyle(
                                            shadows: <Shadow>[
                                              index == currentIndex
                                                  ? Shadow(
                                                color: Color(0xFF3ab1ff)
                                                    .withOpacity(0.5),
                                                //spreadRadius: 3,
                                                blurRadius: 8,
                                              )
                                                  : Shadow()
                                            ],
                                            color: index == currentIndex
                                                ? Color(0xFF73AEF5)
                                                : Colors.grey.withOpacity(0.9),
                                            fontSize: 14)),
                                  )));
                        },
                      ),
                    ),
                  )),
            ),

          ])*/,
        ),
      ),
    );
  }

  Widget buildTabViews(tabIndex) {

   if(tabIndex){

     if ((!postRequestLoading && !noResults) || !firstLoad) {
       return  CustomScrollView(slivers: [ SliverList(
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
           ))]);


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
        child: Container(
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
        ));
  }

  Widget buildCardOrder(Order pedido) {
    return GestureDetector(
        onTap: () {
          Navigator.of(context).push(
              PageRouteBuilder(
                  fullscreenDialog: true,
                  pageBuilder: (BuildContext context,
                      Animation<double> animation,
                      Animation<double> secondaryAnimation) {
                    return OrderDetails(pedido: pedido);
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
        child: Container(
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
                          child: SfCircularChart(
                              annotations: <CircularChartAnnotation>[
                                CircularChartAnnotation(
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
                              series: <CircularSeries>[
                                // Render pie chart
                                RadialBarSeries<ChartData, String>(
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
                                      ? CornerStyle.bothFlat
                                      : CornerStyle.bothCurve),
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
        ));
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