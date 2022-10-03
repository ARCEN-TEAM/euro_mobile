import 'dart:convert';
import 'dart:typed_data';
import 'dart:io' as io;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import 'PlantDetails.dart';
import 'package:lottie/lottie.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../classes/constants.dart';
import '../classes/plant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';

class PlantsList extends StatefulWidget {
  @override
  _PlantsListState createState() => _PlantsListState();
}

class _PlantsListState extends State<PlantsList> {
  XFile? _image;
  List<Plant> centrais = [];
  bool zoneChanged = true;
  Map<String,bool> indexPlantChart = {};
  Map<String,dynamic> chartData = {};
  var response2;
  var dio = Dio(BaseOptions(
      connectTimeout: 20000,
      receiveTimeout: 20000,
      baseUrl: ApiConstants.baseUrl,
      contentType: 'application/json',
      responseType: ResponseType.plain,
      headers: ApiConstants.headers));
  List<String>? selectedZone = [];
  ItemScrollController _controller = ItemScrollController();
   ScrollController _scrollController = ScrollController();
  int currentPageIndex = 0;
  late PageController controller;
  final dayList = List<DateTime>.generate(
      11,
      (i) => DateTime.utc(
            DateTime.now().add(Duration(days: -5)).year,
            DateTime.now().add(Duration(days: -5)).month,
            DateTime.now().add(Duration(days: -5)).day,
          ).add(Duration(days: i)));
  var selected = 5;

  Future<dynamic> postRequest() async {
    if(zoneChanged){
      var url = '${ApiConstants.baseUrl}${ApiConstants.plantEndpoint}/plantsDailyProduction/?user=${ApiConstants.UserLogged}&token=${ApiConstants.ApiKey}';

      FormData form = FormData.fromMap({"zonas[]":  (selectedZone)});

      try {
        response2 = await dio.post(url,
            data: form, options: Options(headers: ApiConstants.headers));
      } catch (e) {
        print(e);
      }
      /* stopwatch = new Stopwatch()..start();
    response2 = await http.post(Uri.parse(url),
        headers: ApiConstants.headers,
        body: '{"zonas":' + json.encode(selectedZone) + '}');*/

      try {
        final parsedJson = json.decode(response2.data);
        centrais = [];
        if(parsedJson.runtimeType == List){
          parsedJson.forEach((dynamic data) {
            centrais.add(Plant.fromJson(data));
          });
        }
        zoneChanged=false;
        return 1;
      } catch (e) {
        print(e);
      }
    }
    return 1;

  }

  Future<dynamic> chartsDetails(var data, Plant central) async {
    if(!chartData.containsKey(central.codigo)){
      var resp;
      var url =
          '${ApiConstants.baseUrl}${ApiConstants.plantEndpoint}/plantsListChartData/?user=${ApiConstants.UserLogged}&token=${ApiConstants.ApiKey}&date=${DateFormat('dd-MM-yyyy').format(data)}&plant=${(central.codigo)}';

      try {

        resp =
        await dio.get(url, options: Options(headers: ApiConstants.headers));
        final parsedJson = json.decode(resp.data);
        indexPlantChart[central.codigo]= true;


        central.setChartData = parsedJson;


        chartData[central.codigo]={
          "producao": central.producao,
          "bombagem": central.bombagem,
          "maxXgraph": central.maxXgraph,
          "minXgraph": central.minXgraph,
          "maxYprod": central.maxYprod,
          "maxYpump": central.maxYpump
        };
        return {
          "producao": central.producao,
          "bombagem": central.bombagem,
          "maxXgraph": central.maxXgraph,
          "minXgraph": central.minXgraph,
          "maxYprod": central.maxYprod,
          "maxYpump": central.maxYpump
        };






      } catch (e) {
        print(e);
      }
    }else{
      return chartData[central.codigo];
    }



  }

  @override
  void initState() {
    super.initState();
    controller = PageController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_controller.isAttached) {
        _controller.jumpTo(index: selected, alignment: 0.44);
      }
    });

    selectedZone?.add(ApiConstants.UserPlants[0].toString());
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child:
          CupertinoScrollbar(
            controller: _scrollController,
            child: CustomScrollView(
              controller: _scrollController,
                physics: BouncingScrollPhysics(), slivers: <Widget>[
        _buildAppBar(context),
        SliverToBoxAdapter(
            child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                )),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                          height: 80,
                          child: Center(
                            child: ScrollablePositionedList.builder(
                                physics: BouncingScrollPhysics(),
                                itemScrollController: _controller,
                                scrollDirection: Axis.horizontal,
                                itemBuilder: (context, index) => GestureDetector(
                                      onTap: () => setState(() {
                                        chartData.clear();
                                        selected = index;
                                      }),
                                      child: Container(
                                          padding: EdgeInsets.all(10),
                                          margin:
                                              EdgeInsets.symmetric(horizontal: 2),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            color: selected == index
                                                ? Colors.grey.withOpacity(0.1)
                                                : null,
                                          ),
                                          child: Column(
                                            children: [
                                              Text(
                                                DateFormat('EEEE')
                                                    .format(dayList[index])
                                                    .substring(0, 3),
                                                style: TextStyle(
                                                    shadows: <Shadow>[
                                                      selected == index
                                                          ? Shadow(
                                                              color: AppColors
                                                                  .selectedItemTextShadowColor /*Color(0xFF3ab1ff).withOpacity(0.5)*/,
                                                              //spreadRadius: 3,
                                                              blurRadius: 8,
                                                            )
                                                          : Shadow()
                                                    ],
                                                    color: selected == index
                                                        ? AppColors
                                                            .selectedItemTextColor /*Color(0xFF40a1f0)*/
                                                        : Colors.grey),
                                              ),
                                              SizedBox(height: 5),
                                              Text(
                                                  DateFormat('dd-MM')
                                                      .format(dayList[index]),
                                                  style: TextStyle(
                                                      shadows: <Shadow>[
                                                        selected == index
                                                            ? Shadow(
                                                                color: AppColors
                                                                    .selectedItemTextShadowColor /*Color(0xFF3ab1ff).withOpacity(0.5)*/,
                                                                //spreadRadius: 3,
                                                                blurRadius: 8,
                                                              )
                                                            : Shadow()
                                                      ],
                                                      fontSize: 16,
                                                      fontWeight: FontWeight.bold,
                                                      color: selected == index
                                                          ? AppColors
                                                              .selectedItemTextColor /*Color(0xFF40a1f0)*/
                                                          : Colors.grey))
                                            ],
                                          )),
                                    ),
                                //separatorBuilder: (_, index) => SizedBox(width: 5),
                                itemCount: dayList.length),
                          )),
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: ApiConstants.UserPlants.map(
                            (zone) {
                              bool isSelected = false;
                              if (selectedZone!.contains(zone)) {
                                isSelected = true;
                              }
                              return GestureDetector(
                                onTap: () {
                                  chartData.clear();
                                  zoneChanged = true;
                                  if (!selectedZone!.contains(zone)) {
                                    if (selectedZone!.length <
                                        ApiConstants.UserPlants.length) {
                                      selectedZone!.add(zone);
                                      setState(() {});
                                    }
                                  } else {
                                    selectedZone!.removeWhere(
                                        (element) => element == zone);
                                    setState(() {});
                                  }
                                },
                                child: Container(
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 5, vertical: 4),
                                    child: Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 1, horizontal: 12),
                                      decoration: BoxDecoration(
                                          color: isSelected
                                              ? Colors.grey.withOpacity(0.1)
                                              : Colors.transparent,
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                              color: Colors.transparent,
                                              width: 2)),
                                      child: Text(
                                        zone,
                                        style: TextStyle(
                                            shadows: <Shadow>[
                                              isSelected
                                                  ? Shadow(
                                                      color: Color(0xFF3ab1ff)
                                                          .withOpacity(0.5),
                                                      //spreadRadius: 3,
                                                      blurRadius: 8,
                                                    )
                                                  : Shadow()
                                            ],
                                            color: isSelected
                                                ? Color(0xFF40a1f0)
                                                : Colors.grey,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    )),
                              );
                            },
                          ).toList(),
                        ),
                      )
                    ])),
        ),
        FutureBuilder(
              future: postRequest(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (centrais.length > 0) {
                    return   SliverList(

                      delegate:    SliverChildBuilderDelegate((context, index) {
                        return buildCard(centrais[index]);
                      }, childCount: centrais.length),
                    );
                  } else {
                    return SliverFillRemaining(
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.transparent,
                        ),
                        child: Center(
                            //     child: CircularProgressIndicator(
                            //   color: Color(0xFF73AEF5),
                            // )
                            child: Opacity(
                          opacity: 0.4,
                          child: Lottie.asset(
                              'assets/images/lotties/notfound.json',
                              repeat: false),
                        )),
                      ),
                    );
                  }
                } else {
                  return SliverFillRemaining(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.transparent,
                      ),
                      child: Center(
                          //     child: CircularProgressIndicator(
                          //   color: Color(0xFF73AEF5),
                          // )
                          child:
                              Lottie.asset('assets/images/lotties/search.json')),
                    ),
                  );
                }
              })
      ]),
          ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      leading: GestureDetector(
        child:buildProfileImage(),
        onTap: () {
        Scaffold.of(context).openDrawer();
        },
    ),
      floating: false,
      automaticallyImplyLeading: false,
      snap: false,
      expandedHeight: 65,
      backgroundColor: AppColors.transparent,
      flexibleSpace: FlexibleSpaceBar(
          title: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Centrais',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ))
        ],
      )),
    );
  }

  Widget buildCard(Plant central) {

    return Container(
        width: MediaQuery.of(context).size.width,
        constraints: BoxConstraints(minHeight: 50),
        decoration: BoxDecoration(
          color: AppColors.transparent,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Card(
                  color: AppColors.cardBackgroundColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                    side: BorderSide(
                      color: AppColors.cardBackgroundColor,
                      width: 1,
                    ),
                  ),
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: FutureBuilder(
                      future: chartsDetails(dayList[selected], central),
                      builder: (context,snapshot)
                      {
                        if(snapshot.connectionState == ConnectionState.done){

                          if (snapshot.hasData) {
                            return chartExpansionTile('success',central,snapshot.data);
                          } else {
                            return chartExpansionTile('error',central,null);
                          }

                          // By default, show a loading spinner.

                      }
                        return chartExpansionTile('loading',central,null);

                      },
                      )),
            ),
          ],
        ));
  }

  loadChart(dynamic data, bool chartprod) {
    if (data["producao"].isNotEmpty) {
      return BarChart(
        mainData(data["minXgraph"], data["maxXgraph"], data["maxYprod"],
            (chartprod) ? data["producao"] : data["bombagem"], true),
      );
    } else {
      return Center(
        child: Text("Sem Dados",
            style: TextStyle(color: Colors.white)),
      );
    }
  }
  Widget chartExpansionTile(String status,Plant central,dynamic chart){
    switch(status) {
      case 'loading':
        return
          ExpansionTile(

            textColor: AppColors.textColorOnDarkBG,
            collapsedTextColor: AppColors.textColorOnDarkBG,
            collapsedIconColor: AppColors.textColorOnDarkBG,
            iconColor: AppColors.selectedItemTextColor,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.3, 0.05),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              central.codigo + ' - ' + central.nome,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorOnDarkBG),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          Hero(
                              tag: 'plant-' + central.codigo,
                              child: Container(
                                width: 50,
                                height: 50,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    imageUrl:
                                    'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ')/' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw',
                                  ),
                                ),
                              )),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4,
                                    child: Container(
                                      padding:
                                      EdgeInsets.only(left: 20),
                                      child:  Center(
                                          child:
                                          CircularProgressIndicator()),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
            children: [
              SizedBox(height: 25),
              FractionallySizedBox(
                widthFactor: 0.65,
                child: AspectRatio(
                  aspectRatio: 4,
                  child: Container(
                    //padding: EdgeInsets.only(left: 20,top:20,bottom:20),
                    margin: EdgeInsets.only(left: 30),
                    child:  Center(child: CircularProgressIndicator()),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: Colors.lightBlueAccent,
                            shadows: [
                              Shadow(
                                color: Colors.lightBlueAccent,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('producao'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: AppColors.chartLineColorSecondary,
                            shadows: [
                              Shadow(
                                color:
                                AppColors.chartLineColorSecondary,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('bombagens'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.transparent, width: 0),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    color: AppColors.backgroundBlue.withOpacity(0.4)),
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity(
                        vertical: -4,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantScreen(central,
                                  dayList[selected].toString())),
                        );
                      },
                      title: Center(
                        child: Text(translate('ver_mais'),
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG)),
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          );

      case 'error':
        return
          ExpansionTile(

            textColor: AppColors.textColorOnDarkBG,
            collapsedTextColor: AppColors.textColorOnDarkBG,
            collapsedIconColor: AppColors.textColorOnDarkBG,
            iconColor: AppColors.selectedItemTextColor,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.3, 0.05),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              central.codigo + ' - ' + central.nome,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorOnDarkBG),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          Hero(
                              tag: 'plant-' + central.codigo,
                              child: Container(
                                width: 50,
                                height: 50,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    imageUrl:
                                    'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ')/' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw',
                                  ),
                                ),
                              )),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4,
                                    child: Container(
                                      padding:
                                      EdgeInsets.only(left: 20),
                                      child:  Center(
                                          child:
                                          Text('Sem Dados',style: TextStyle(color:AppColors.textColorOnDarkBG,fontSize: 15),)),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
            children: [
              SizedBox(height: 25),
              FractionallySizedBox(
                widthFactor: 0.65,
                child: AspectRatio(
                  aspectRatio: 4,
                  child: Container(
                    //padding: EdgeInsets.only(left: 20,top:20,bottom:20),
                    margin: EdgeInsets.only(left: 30),
                    child: Center(
                        child:
                        Text('Sem Dados',style: TextStyle(color:AppColors.textColorOnDarkBG,fontSize: 15),)),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: Colors.lightBlueAccent,
                            shadows: [
                              Shadow(
                                color: Colors.lightBlueAccent,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('producao'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: AppColors.chartLineColorSecondary,
                            shadows: [
                              Shadow(
                                color:
                                AppColors.chartLineColorSecondary,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('bombagens'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.transparent, width: 0),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    color: AppColors.backgroundBlue.withOpacity(0.4)),
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity(
                        vertical: -4,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantScreen(central,
                                  dayList[selected].toString())),
                        );
                      },
                      title: Center(
                        child: Text(translate('ver_mais'),
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG)),
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          );

      case 'success':
        return
          ExpansionTile(

            textColor: AppColors.textColorOnDarkBG,
            collapsedTextColor: AppColors.textColorOnDarkBG,
            collapsedIconColor: AppColors.textColorOnDarkBG,
            iconColor: AppColors.selectedItemTextColor,
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Align(
                    alignment: AlignmentDirectional(0.3, 0.05),
                    child: Column(
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          //crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              central.codigo + ' - ' + central.nome,
                              style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColorOnDarkBG),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(children: [
                          Hero(
                              tag: 'plant-' + central.codigo,
                              child: Container(
                                width: 50,
                                height: 50,
                                clipBehavior: Clip.antiAlias,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                ),
                                child: Align(
                                  alignment: AlignmentDirectional(0, 0),
                                  child: CachedNetworkImage(
                                    placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                    imageUrl:
                                    'https://api.mapbox.com/styles/v1/mapbox/satellite-v9/static/pin-l+aa001a(' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ')/' +
                                        central.gps.longitude
                                            .toString() +
                                        ',' +
                                        central.gps.latitude
                                            .toString() +
                                        ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw',
                                  ),
                                ),
                              )),
                          Flexible(
                            flex: 1,
                            child: Container(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.stretch,
                                children: [
                                  AspectRatio(
                                    aspectRatio: 4,
                                    child: Container(
                                      padding:
                                      EdgeInsets.only(left: 20),
                                      child:  loadChart(
                                          chart,
                                          true)
                                           ,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ])
                      ],
                    ),
                  ),
                ],
              ),
            ),
            children: [
              SizedBox(height: 25),
              FractionallySizedBox(
                widthFactor: 0.65,
                child: AspectRatio(
                  aspectRatio: 4,
                  child: Container(
                    //padding: EdgeInsets.only(left: 20,top:20,bottom:20),
                    margin: EdgeInsets.only(left: 30),
                    child:   loadChart(chart, false) ,
                  ),
                ),
              ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: Colors.lightBlueAccent,
                            shadows: [
                              Shadow(
                                color: Colors.lightBlueAccent,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('producao'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: TextButton.icon(
                        icon: Icon(Icons.radio_button_checked_rounded,
                            color: AppColors.chartLineColorSecondary,
                            shadows: [
                              Shadow(
                                color:
                                AppColors.chartLineColorSecondary,
                                /*AppColors.chartLineColorPrimary*/ /*Color(0xFF3ab1ff).withOpacity(0.5)*/
                                //spreadRadius: 3,
                                blurRadius: 8,
                              )
                            ]),
                        label: Text(
                          translate('bombagens'),
                          style: TextStyle(
                              color: AppColors.textColorOnDarkBG),
                        ),
                        onPressed: () {}),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.transparent, width: 0),
                    borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25)),
                    color: AppColors.backgroundBlue.withOpacity(0.4)),
                child: Column(
                  children: [
                    ListTile(
                      visualDensity: VisualDensity(
                        vertical: -4,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => PlantScreen(central,
                                  dayList[selected].toString())),
                        );
                      },
                      title: Center(
                        child: Text(translate('ver_mais'),
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG)),
                      ),
                      trailing: Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            ],
          );

      default:
        return Container();
    }


  }
  Widget bottomTitleWidgets(
      double value, TitleMeta meta, double min, double max) {
    const style = TextStyle(
      color: Colors.white,
      fontSize: 13,
    );
    if (value % meta.appliedInterval == 0) {
      String txt =
          value == ((value != max) ? (max - meta.appliedInterval + 1) : max)
              ? ('${value.toInt()} h')
              : ('${value.toInt()}');
      Widget text = Text(txt, style: style);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 8.0,
        child: text,
      );
    } else
      return SizedBox();
  }

  BarTouchData get barTouchData => BarTouchData(
        enabled: true,
        touchTooltipData: BarTouchTooltipData(
          tooltipBgColor: Colors.transparent,
          tooltipPadding: const EdgeInsets.all(0),
          tooltipMargin: -4,
          getTooltipItem: (
            BarChartGroupData group,
            int groupIndex,
            BarChartRodData rod,
            int rodIndex,
          ) {
            return BarTooltipItem(
              rod.toY.round().toString(),
              const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            );
          },
        ),
      );

  BarChartData mainData(double minX, double maxX, double maxY,
      List<BarChartGroupData> data, bool showAxisX) {
    return BarChartData(
      gridData: FlGridData(show: false),
      barTouchData: barTouchData,
      minY: 0,
      maxY: maxY,
      titlesData: FlTitlesData(
        show: true,
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
              getTitlesWidget: (value, meta) =>
                  bottomTitleWidgets(value, meta, minX, maxX),
              reservedSize: 22,
              showTitles: showAxisX,
              interval: (data.length / 15).ceilToDouble() + 1),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      barGroups: data,
    );
  }

  Widget buildProfileImage() {
    ImageProvider image =
    NetworkImage('https://www.w3schools.com/howto/img_avatar.png');

    if (_image != null) {
      List<int> imageBase64 = io.File(_image!.path).readAsBytesSync();
      String imageAsString = base64Encode(imageBase64);
      Uint8List uint8list = base64.decode(imageAsString);
      image = Image.memory(uint8list).image;
    }

    return  Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        margin: EdgeInsets.only(left: 10),

          decoration: BoxDecoration(
            shape:  BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.cover,  image: image,
            ),
          )),
    );
  }
}
