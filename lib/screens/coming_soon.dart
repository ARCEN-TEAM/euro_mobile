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
            style: TextStyle(color:Colors.white, fontSize: 34),
          ),
          SizedBox(height:30),
          Icon(
              Icons.construction,
            size:70,
              color: Colors.white,

          )
        ],
      ),
    );
  }
}
