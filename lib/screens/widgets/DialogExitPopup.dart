import 'dart:io';
import 'package:flutter/material.dart';

import '../../classes/constants.dart';

  showExitPopup(context,title,VoidCallback confirmAction) async{
  return await showDialog(
    useSafeArea: true,

      context: context,
      builder: (BuildContext context) {
        return AlertDialog(

          backgroundColor: AppColors.cardBackgroundColor,
          content: Container(
            height: 90,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,style: TextStyle(color: AppColors.textColorOnDarkBG,fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed:  confirmAction,

                        child: Text("Sim",style: TextStyle(color: AppColors.textColorOnDarkBG),),
                        style: ElevatedButton.styleFrom(
                            primary: AppColors.buttonPrimaryColor),
                      ),
                    ),
                    SizedBox(width: 15),
                    Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text("Não", style: TextStyle(color: Colors.black)),
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white,
                          ),
                        ))
                  ],
                )
              ],
            ),
          ),
        );
      });
} 