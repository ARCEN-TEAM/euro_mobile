import 'package:flutter/material.dart';
import '../classes/constants.dart';

final util_email = "mailto";
final util_call = "tel";
final util_sms = "sms";

final kHintTextStyle = TextStyle(
  color: Colors.white54,
  fontFamily: 'OpenSans',
);

final kLabelStyle = TextStyle(
  color: Colors.white,
  fontWeight: FontWeight.bold,
  fontFamily: 'OpenSans',
);

final kBoxDecorationStyle = BoxDecoration(
  color: ApiConstants.mainColor,
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: Color(0xFF3ab1ff).withOpacity(0.7),
      spreadRadius: 2,
      blurRadius: 8,
    ),
  ],
);