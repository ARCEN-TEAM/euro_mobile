import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../classes/utils.dart';
import '../utilities/constants.dart';
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
            child: Text("Profile",
                style: TextStyle(color: Colors.white, fontSize: 20))),
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
        Center(
            child: Text(widget.username,
                style: TextStyle(color: Colors.white, fontSize: 20))),
        SizedBox(height: 15),
        Center(
          child: FractionallySizedBox(
            widthFactor: 0.85,
            child: Container(
              height: 1.0,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF3ab1ff).withOpacity(0.2),
                    blurRadius: 4,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        ),
        SizedBox(height: 30),
        buildCard(Icon(Icons.menu, color: Colors.white),  "Nome Completo", teste, Icon(Icons.chevron_right, color: Colors.white)),
        buildCard(Icon(Icons.menu, color: Colors.white), "Grupo", "Programador", Icon(Icons.chevron_right, color: Colors.white)),
        ListTile(
          leading: Text(
              'Contacto',
              style: TextStyle(color: Colors.white, fontSize: 20)
          ),
        ),
        buildCard(Icon(Icons.phone_outlined), "Telemóvel", "91..", Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.2))),
        buildCard(Icon(Icons.email_outlined),  "Email", "pe.prg@arcen.pt", Icon(Icons.edit_outlined, color: Colors.white.withOpacity(0.2))),
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
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0xFF3ab1ff).withOpacity(0.5),
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
        color: Color(0xFF0f1925),
        all: 8,
        child: Icon(Icons.edit_outlined, color: Colors.white, size: 20));
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
            color: Color(0xFF172b49), //
            child: InkWell(
              splashColor: Colors.white, // inkwell color
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
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
                splashColor: Colors.white, // inkwell color
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
                splashColor: Colors.white, // inkwell color
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
            backgroundColor: Color(0xFF172b49),

            title: Text('Fotografia', style: TextStyle(color: Colors.white)),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, 'Camara'); },
                child: Text('Camara', style: TextStyle(color: Colors.white)),
              ),
              SimpleDialogOption(
                onPressed: () { Navigator.pop(context, 'Galeria'); },
                child: Text('Galeria', style: TextStyle(color: Colors.white)),
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
