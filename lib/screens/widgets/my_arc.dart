import 'dart:math' as math;
import 'package:flutter/painting.dart';
import 'package:flutter/material.dart';

class MyArc extends StatelessWidget {
  final double diameter;

  const MyArc({Key? key, this.diameter = 100}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: MyPainter(),
      size: Size(diameter, diameter),
    );
  }
}


// This is the Painter class
class MyPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final redCircle = Paint()
      ..color = Color(0xff40a1f0).withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..shader = RadialGradient(
          colors: [
            Color(0xff40a1f0),
            Color(0xff172842),
          ]
      ).createShader(Rect.fromCircle(
        center: Offset(40,0),
        radius: 100,
      ));
    final arcRect = Rect.fromCircle(
        center: size.bottomCenter(Offset.zero), radius: size.shortestSide);
    canvas.drawArc(arcRect, 0, -math.pi, false, redCircle);

  }

  @override
  bool shouldRepaint(MyPainter oldDelegate) => false;
}