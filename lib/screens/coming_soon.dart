import 'package:euro_mobile/classes/constants.dart';
import 'package:flutter/material.dart';

class ComingSoon extends StatefulWidget {

  @override
  _ComingSoonState createState() => _ComingSoonState();
}

class _ComingSoonState extends State<ComingSoon> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        
        children: [
          Text(
            'Coming soon',
            style: TextStyle(color:AppColors.textColorOnDarkBG, fontSize: 34),
          ),
          SizedBox(height:30),
          Icon(
              Icons.construction,
            size:70,
              color: AppColors.textColorOnDarkBG,

          )
        ],
      ),
    );
  }
}
