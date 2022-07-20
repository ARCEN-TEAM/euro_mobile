import 'dart:convert';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
//import 'package:login_test/screens/plant_screen_details.dart';
import 'package:lottie/lottie.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../classes/constants.dart';
import '../classes/plant.dart';

class PlantsList extends StatefulWidget {

  @override
  _PlantsListState createState() => _PlantsListState();
}

class _PlantsListState extends State<PlantsList> {

  List<Plant> centrais = [];
  var response2;
  List<String>? selectedZone = [];

  ItemScrollController _controller = ItemScrollController();
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

  Future<dynamic> postRequest(var data) async {
    var url = ApiConstants.baseUrl +
        ApiConstants.plantEndpoint +
        '/plantsDailyProduction/?user=' +
        ApiConstants.UserLogged +
        '&token=' +
        ApiConstants.ApiKey +
        '&date=' +
        DateFormat('dd-MM-yyyy').format(data);

    response2 = await http.post(Uri.parse(url),
        headers: ApiConstants.headers,
        body: '{"zonas":' + json.encode(selectedZone) + '}');

    final parsedJson = json.decode(response2.body);
    centrais = [];

    parsedJson.forEach((dynamic data) {
      centrais.add(Plant.fromJson(data));
    });
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
    return  Container(
      child: CustomScrollView(slivers: <Widget>[
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
                              itemScrollController: _controller,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) =>
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      selected = index;
                                    }),
                                    child: Container(
                                        padding: EdgeInsets.all(10),
                                        margin: EdgeInsets.symmetric(
                                            horizontal: 2),
                                        decoration: BoxDecoration(
                                          borderRadius:
                                          BorderRadius.circular(20),
                                          color: selected == index
                                              ? Colors.grey
                                              .withOpacity(0.1)
                                              : null,
                                        ),
                                        child: Column(
                                          children: [
                                            Text(
                                              DateFormat('EEEE')
                                                  .format(
                                                  dayList[index])
                                                  .substring(0, 3),
                                              style: TextStyle(
                                                  shadows: <Shadow>[
                                                    selected == index
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
                                                  color: selected ==
                                                      index
                                                      ? Color(
                                                      0xFF40a1f0)
                                                      : Colors.grey),
                                            ),
                                            SizedBox(height: 5),
                                            Text(
                                                DateFormat('dd-MM')
                                                    .format(
                                                    dayList[index]),
                                                style: TextStyle(
                                                    shadows: <Shadow>[
                                                      selected == index
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
                                                    fontSize: 16,
                                                    fontWeight:
                                                    FontWeight.bold,
                                                    color: selected ==
                                                        index
                                                        ? Color(
                                                        0xFF40a1f0)
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
                                        vertical: 5, horizontal: 12),
                                    decoration: BoxDecoration(
                                        color: isSelected
                                            ? Color(0xFF73AEF5)
                                            : Colors.white,
                                        borderRadius:
                                        BorderRadius.circular(18),
                                        border: Border.all(
                                            color: isSelected
                                                ? Color(0xFF73AEF5)
                                                : Colors.grey,
                                            width: 2)),
                                    child: Text(
                                      zone,
                                      style: TextStyle(
                                          color: isSelected
                                              ? Colors.white
                                              : Colors.grey,
                                          fontSize: 14),
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
            future: postRequest(dayList[selected]),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (centrais.length > 0) {
                  return SliverList(
                    delegate:
                    SliverChildBuilderDelegate((context, index) {
                      return buildCard(centrais[index]);
                    }, childCount: centrais.length),
                  );
                } else {
                  return SliverFillRemaining(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Color(0x00000000),
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
                      color: Color(0x00000000),
                    ),
                    child: Center(
                      //     child: CircularProgressIndicator(
                      //   color: Color(0xFF73AEF5),
                      // )
                        child: Lottie.asset(
                            'assets/images/lotties/search.json')),
                  ),
                );
              }
            })
      ]),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: false,
      automaticallyImplyLeading: false,
      snap: false,
      expandedHeight: 80,
      backgroundColor: Color(0x00000000),
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
    return GestureDetector(
        onTap: () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //       builder: (context) =>
          //           PlantScreen(central, dayList[selected].toString())),
          // );
        },
        child: Container(
            width: MediaQuery.of(context).size.width,
            constraints: BoxConstraints(minHeight: 50),
            decoration: BoxDecoration(
              color: Color(0x00000000),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Card(
                      color: Color(0xFF172842),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: BorderSide(
                          color: Color(0xFF162a45),
                          width: 1,
                        ),
                      ),
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      child: ExpansionTile(

                        collapsedIconColor: Colors.white,
                        iconColor: Color(0xFF40a1f0),
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
                                      mainAxisAlignment:
                                      MainAxisAlignment.start,
                                      //crossAxisAlignment: CrossAxisAlignment.stretch,
                                      children: [
                                        Text(
                                          central.codigo + ' - ' + central.nome,
                                          style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.white),
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
                                              alignment:
                                              AlignmentDirectional(0, 0),
                                              child: Image.network(
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
                                                      ',17.00,0/400x400?access_token=sk.eyJ1IjoiYXJjZW4tZW5nZW5oYXJpYSIsImEiOiJjbDNsbHFibjIwMWY4M2pwajBscDNhMm9vIn0.bGRvEk1qIOvE2tMlriJwTw'),
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
                                                aspectRatio: 5,
                                                child: Container(
                                                  padding:
                                                  EdgeInsets.only(left: 20),
                                                  child: LineChart(
                                                    mainData(),
                                                  ),
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
                          FractionallySizedBox(
                            widthFactor: 0.65,
                            child: AspectRatio(
                              aspectRatio: 5,
                              child: Container(
                                //padding: EdgeInsets.only(left: 20,top:20,bottom:20),
                                margin: EdgeInsets.only(left: 30),
                                child: LineChart(
                                  mainData(),
                                ),
                              ),
                            ),
                          ),
                          Text("Ver mais",
                              style: TextStyle(color: Colors.white))
                        ],
                      )),
                ),
              ],
            )));
  }

  LineChartData mainData() {
    return LineChartData(
      gridData: FlGridData(show: false),
      minX: 0,
      maxX: 10,
      minY: 0,
      maxY: 60,
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
            showTitles: false,
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: false,
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(horizontalLines: [
        HorizontalLine(
            y: 10,
            color: Colors.white.withOpacity(0.8),
            strokeWidth: 1,
            label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.centerRight,
                padding: EdgeInsets.only(right: -30)))
      ]),
      borderData: FlBorderData(
          show: false,
          border: Border.all(color: const Color(0xff37434d), width: 1)),
      lineBarsData: [
        LineChartBarData(
          shadow: Shadow(
            color: Color(0xFF3ab1ff).withOpacity(0.5),
            //spreadRadius: 3,
            blurRadius: 8,
          ),
          spots: const [
            FlSpot(0, 20),
            FlSpot(2, 32),
            FlSpot(4, 8),
            FlSpot(6, 27),
            FlSpot(8, 10),
            FlSpot(10, 4),
          ],
          isCurved: true,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: false,
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: gradientColors
                  .map((color) => color.withOpacity(0.2))
                  .toList(),
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ],
    );
  }

  List<Color> gradientColors = [
    const Color(0xff40a1f0),
    const Color(0xff172842),
  ];
}
