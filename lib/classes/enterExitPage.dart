import 'package:flutter/material.dart';
class SlideInPageRoute extends PageRouteBuilder {
  final Widget enterPage;
  final Widget exitPage;
  SlideInPageRoute({required this.exitPage, required this.enterPage})
      : super(
    pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        ) =>
    enterPage,
    transitionDuration: Duration(milliseconds: 200),
    transitionsBuilder: (

        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
        Widget child,
        ) =>
        Stack(
          children: <Widget>[
            SlideTransition(
              position: new Tween<Offset>(
                begin: Offset.zero,
                end: Offset.zero,
              ).animate(animation),
              child: enterPage,
            ),
            SlideTransition(
              position: new Tween<Offset>(
                begin: const Offset(0.0, 0.0),
                end: const Offset( -1.0, 0.0),
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeIn,
              )),
              child: exitPage,
            )

          ],
        ),
  );
}