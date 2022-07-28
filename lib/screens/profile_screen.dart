import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:euro_mobile/screens/widgets/DialogExitPopup.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../classes/constants.dart';
import '../classes/enterExitPage.dart';
import '../classes/utils.dart';
import '../utilities/constants.dart';
import 'login_screen.dart';
import 'widgets/my_arc.dart';
//import 'AddEntryDialog.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({required this.username});

  final String username;

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String teste = 'DEV ARCEN';

  XFile? _image;
  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose(){

    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 30),
        Center(
            child: Text(widget.username,
                style: TextStyle(color: AppColors.textColorOnDarkBG, fontSize: 20))),
        SizedBox(height: 30),
        Stack(
          children: [
            Center(
                child: CustomPaint(
              painter: MyPainter(),
              size: Size(80, 80),
            )),
            Center(
              child: Stack(
                children: [
                  buildProfileImage(),
                  Positioned(
                      bottom: 0,
                      right: 4,
                      child: InkWell(
                        onTap: _askedToLead,
                          child: buildEditIcon()
                      )
                  )
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 30),

        SizedBox(height: 15),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                color: AppColors.textColorOnDarkBG.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.buttonSecondaryColor.withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        buildCard(Icon(Icons.menu, color: AppColors.textColorOnDarkBG),  "Nome Completo", teste, Icon(Icons.chevron_right, color: AppColors.textColorOnDarkBG)),
        buildCard(Icon(Icons.menu, color: AppColors.textColorOnDarkBG), "Grupo", "Programador", Icon(Icons.chevron_right, color: AppColors.textColorOnDarkBG)),
        ListTile(
          leading: Text(
              'Contacto',
              style: TextStyle(color: AppColors.textColorOnDarkBG, fontSize: 20)
          ),
        ),
        buildCard(Icon(Icons.phone_outlined,color: AppColors.textColorOnDarkBG), "Telemóvel", "91..", Icon(Icons.edit_outlined, color: AppColors.textColorOnDarkBG.withOpacity(0.2))),
        buildCard(Icon(Icons.email_outlined,color: AppColors.textColorOnDarkBG),  "Email", "pe.prg@arcen.pt", Icon(Icons.edit_outlined, color: AppColors.textColorOnDarkBG.withOpacity(0.2))),

        Row(children: [
           
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(

                onPressed: () {
                  showExitPopup(context, "Deseja terminar sessão?",() {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                          (Route<dynamic> route) => false,
                    );

                });},
                child: Text("Terminar sessão",style: TextStyle(color: AppColors.textColorOnDarkBG,),),
                style: ElevatedButton.styleFrom(

                    primary: AppColors.buttonPrimaryColor),
              ),
            ),
          )
        ],)

      ],
    );
  }

  Widget buildProfileImage() {
    ImageProvider image = NetworkImage('https://www.w3schools.com/howto/img_avatar.png');

    if (_image != null){
      List<int> imageBase64 = io.File(_image!.path).readAsBytesSync();
      String imageAsString = base64Encode(imageBase64);
      Uint8List uint8list = base64.decode(imageAsString);
      image = Image.memory(uint8list).image;
    }

    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color:AppColors.textColorOnDarkBG,
        boxShadow: [
          BoxShadow(
            color: AppColors.selectedItemTextShadowColor,
            //spreadRadius: 3,
            blurRadius: 30,
          )
        ],
      ),
      child: ClipOval(
        child: Material(
          color: Colors.transparent,
          child: Ink.image(
            image: image,
            fit: BoxFit.cover,
            width: 128,
            height: 128,
            // child: InkWell(onTap: onClicked),
          ),
        ),
      ),
    );
  }

  Widget buildEditIcon() {
    return buildCircle(
        color: AppColors.backgroundBlue,
        all: 8,
        child: Icon(Icons.edit_outlined, color: AppColors.textColorOnDarkBG, size: 20));
  }

  Widget buildCircle(
      {required Widget child, required double all, required Color color}) {
    return ClipOval(
        child: Container(
      padding: EdgeInsets.all(all),
      color: color,
      child: child,
    ));
  }

  Widget buildCard(Icon leading, String titulo, String subtitulo, Icon trailing) {
    return Container(
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(15.0),
          child: Material(
            color: AppColors.cardBackgroundColor/*Color(0xFF172b49)*/, //
            child: InkWell(
              splashColor: AppColors.textColorOnDarkBG, // inkwell color
              child: SizedBox(
                  width: 56,
                  height: 56,
                  child: leading),
              onTap: () {

              },
            ),
          ),
        ),
        title: Text(
         titulo,
          style: TextStyle(color: AppColors.textColorOnDarkBG, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          subtitulo,
          style: TextStyle(color: Colors.grey),
        ),
        trailing: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                splashColor: AppColors.textColorOnDarkBG, // inkwell color
                child: Icon(Icons.content_copy , color: Colors.white.withOpacity(0.2)),
                onTap: () {},
              ),
              SizedBox(width:10),
              VerticalDivider(
                color: Colors.white.withOpacity(0.2),
                thickness: 2,
              ),
              SizedBox(width:10),
              InkWell(
                splashColor: AppColors.textColorOnDarkBG, // inkwell color
                child: trailing,
                onTap: () async {
                  String? teste2 = await Navigator.of(context).push(new MaterialPageRoute<String>(
                      builder: (BuildContext context) {
                        return Container(); //new AddEntryDialog();
                      },
                      fullscreenDialog: true
                  ));
                  if (teste2 != null){
                    setState(() {
                      teste = teste2;
                    });
                  }
                },
              ),
            ],
          ),
        )

      ),
    );
  }

  Future<void> _askedToLead() async {
    switch (await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor:AppColors.cardBackgroundColor /*Color(0xFF172b49)*/,

            title: Text('Fotografia', style: TextStyle(color: AppColors.textColorOnDarkBG)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, 'Camara'); },
                child: Text('Camara', style: TextStyle(color: AppColors.textColorOnDarkBG)),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, 'Galeria'); },
                child: Text('Galeria', style: TextStyle(color: AppColors.textColorOnDarkBG)),
              ),
            ],
          );
        }
    )) {
      case 'Camara':
        print('camara');
        pickImageC();
        break;
      case 'Galeria':
        print('galeria');
        pickImage();
        break;
      case null:
        break;
    }
  }



  Future pickImage() async {
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null){
        setState(() {
          _image = image;
        });
      }

    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImageC() async {
    try {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image != null){
        setState(() {
          _image = image;
        });
      }
    } on PlatformException catch(e) {
      print('Failed to pick image: $e');
    }
  }
}
