import 'package:flutter/material.dart';
import '../classes/plant.dart';
import '../classes/constants.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
//import 'package:login_test/screens/plant_screen_details.dart';
import 'package:intl/intl.dart';
import 'plants_list.dart';
import 'profile_screen.dart';
import 'timelineTest.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'coming_soon.dart';

class MainScreen extends StatefulWidget {

  const MainScreen({required this.username});

  final String username;

  @override
  _MainScreenWidgetState createState() => _MainScreenWidgetState();
}

List<Plant> centrais = [];
var response2;
List<String>? selectedZone = [];

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

class _MainScreenWidgetState extends State<MainScreen> {
  ItemScrollController _controller = ItemScrollController();
  int currentPageIndex = 0;
  bool navTapped = false;
  late PageController controller;
  final dayList = List<DateTime>.generate(
      11,
      (i) => DateTime.utc(
            DateTime.now().add(Duration(days: -5)).year,
            DateTime.now().add(Duration(days: -5)).month,
            DateTime.now().add(Duration(days: -5)).day,
          ).add(Duration(days: i)));

  var selected = 5;

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(width: 0, color: AppColors.backgroundBlue /*Color(0xFF0f1925)*/),
          gradient: RadialGradient(
            center: Alignment(-1.4, -1.4),
            colors: AppColors.backgroundGradientColors /*[
              Color(0xFF1d4d73),
              Color(0xFF0f1925),
            ]*/,
            radius: 1.2,
          ),
        ),
        child: PageView(
          physics: BouncingScrollPhysics() /*NeverScrollableScrollPhysics()*/,
          onPageChanged: (int pageIndex){
            {
              if(!navTapped){
                setState(() {
                  currentPageIndex = pageIndex;
                });
                controller.animateToPage(currentPageIndex,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuad);
              }

            }
          },
          controller: controller,
          children: [
            PlantsList(),
            ComingSoon(),
            // Container(
            //   height: 100,
            //   child: LineChart(
            //     mainData(),
            //   ),
            // ),
            ComingSoon(),
            ComingSoon(),
            ListView(
              physics: BouncingScrollPhysics(),
              children: [
                ProfileScreen(username: widget.username)
              ],
            )
          ],
        ),
      ),
      bottomNavigationBar: Theme(
          data: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: Container(
            decoration: BoxDecoration(
                border: Border.all(width: 0, color: AppColors.backgroundBlue)),
            child: BottomNavigationBar(
              currentIndex: currentPageIndex,
              onTap: (int index) {
                setState(() {
                  currentPageIndex = index;
                  navTapped = true;
                });
                controller.animateToPage(currentPageIndex,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutQuad)
                    .then((value)
                      {
                        navTapped = false;
                      });
              },
              elevation: 0,

              type: BottomNavigationBarType.shifting,
              unselectedItemColor: AppColors.navbarUnselectedItemColor /*Color(0xFF7b93af)*/,
              selectedItemColor:  AppColors.textColorOnDarkBG,
              backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
              items: [
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.factory),
                  icon: Icon(Icons.factory_outlined),
                  label: 'Produção',
                  backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.fact_check),
                  icon: Icon(Icons.fact_check_outlined),
                  label: 'Planeamento',
                  backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.biotech),
                  icon: Icon(Icons.biotech_outlined),
                  label: 'Laboratório',
                  backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.handyman),
                  icon: Icon(Icons.handyman_outlined),
                  label: 'Manutenção',
                  backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
                ),
                BottomNavigationBarItem(
                  activeIcon: Icon(Icons.person),
                  icon: Icon(Icons.person_outline),
                  label: 'Perfil',
                  backgroundColor: AppColors.backgroundBlue /*Color(0xFF0f1925)*/,
                ),
              ],
            ),
          )),
    );
  }



}
