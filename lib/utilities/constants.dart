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
  color: AppColors.primaryBlue,
  borderRadius: BorderRadius.circular(10.0),
  boxShadow: [
    BoxShadow(
      color: AppColors.textBoxShadowBlue,
      spreadRadius: 2,
      blurRadius: 8,
    ),
  ],
);