import 'package:euro_mobile/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io' as io;
import '../classes/constants.dart';
import 'widgets/my_arc.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:euro_mobile/screens/widgets/DialogExitPopup.dart';
import '../utilities/constants.dart';
import 'login_screen.dart';

class SideDrawer extends StatefulWidget {
  const SideDrawer({required this.username});

  final String username;

  @override
  _SideDrawerState createState() => _SideDrawerState();
}

class _SideDrawerState extends State<SideDrawer> {
  XFile? _image;

  @override
  Widget build(BuildContext context) {
    var localizationDelegate = LocalizedApp.of(context).delegate;
    return Container(
      decoration: BoxDecoration(color: AppColors.cardBackgroundColor),
      child:
          Column(
            children: [
              Expanded(
                child: ListView(
                   physics:  NeverScrollableScrollPhysics(),

                  padding: EdgeInsets.zero,
                  children: [
                    SizedBox(height: 70),
                    Center(
                        child: Text(widget.username,
                            style: TextStyle(
                                color: AppColors.textColorOnDarkBG, fontSize: 20))),
                    SizedBox(height: 10),
                    Stack(
                      children: [
                        Center(
                            child: CustomPaint(
                          painter: MyPainter(),
                          size: Size(50, 50),
                        )),
                        Center(
                          child: buildProfileImage(),
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Center(
                      child: FractionallySizedBox(
                        widthFactor: 0.9,
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
                    SizedBox(height: 10),
                    buildCard(
                      Icon(Icons.person), translate('perfil'), () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return ProfileScreen(username: widget.username);
                        }));
                      },
                    ),
                    buildCard(Icon(Icons.translate), translate('idioma'), () {
                      showDialog<String>(
                          context: context,
                          builder: (BuildContext context) {
                            return SimpleDialog(
                              backgroundColor:AppColors.cardBackgroundColor /*Color(0xFF172b49)*/,

                              title: Text('Escolher idioma', style: TextStyle(color: AppColors.textColorOnDarkBG)),
                              children: <Widget>[
                                buildLanguageOption(context, 'pt', 'pt'),
                                buildLanguageOption(context, 'en', 'gb'),
                                buildLanguageOption(context, 'fr', 'fr'),
                                buildLanguageOption(context, 'es', 'es'),

                              ],
                            );
                          }
                      );
                    }
                    ),
                    buildCard(Icon(Icons.settings), translate('definicoes'), () {}),

                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child:  ElevatedButton(


                    onPressed: () {
                      showExitPopup(context, translate('deseja_terminar_sessao'),() {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (Route<dynamic> route) => false,
                        );

                      });},
                    child: Text(translate('terminar_sessao'),style: TextStyle(color: AppColors.textColorOnDarkBG,),),
                    style: ElevatedButton.styleFrom(

                        primary: AppColors.buttonPrimaryColor),
                  ),

              ),
            ],
          ),



    );
  }



  Widget buildProfileImage() {
    ImageProvider image =
        NetworkImage('https://www.w3schools.com/howto/img_avatar.png');

    if (_image != null) {
      List<int> imageBase64 = io.File(_image!.path).readAsBytesSync();
      String imageAsString = base64Encode(imageBase64);
      Uint8List uint8list = base64.decode(imageAsString);
      image = Image.memory(uint8list).image;
    }

    return Container(
      margin: EdgeInsets.only(top: 15),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textColorOnDarkBG,
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
            width: 64,
            height: 64,
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
        child: Icon(Icons.edit_outlined,
            color: AppColors.textColorOnDarkBG, size: 20));
  }

  Widget buildLanguageOption(BuildContext context, String lingua, String bandeira) {
    return SimpleDialogOption(
      onPressed: () {
        changeLocale(context, lingua);
        Navigator.pop(context, lingua);
      },
      child: Row(
        children: [
          Container(
            width:40,
            height:30,
            child: SvgPicture.asset(
                'assets/flag/' + bandeira + '.svg',
            ),
          ),
          SizedBox(width:10),
          Text(translate('linguagem.' + lingua), style: TextStyle(color: AppColors.textColorOnDarkBG)),
        ],
      ),
    );
  }
  Widget buildCard(Icon leading, String titulo, VoidCallback acao ) {
    return GestureDetector(
      onTap: acao,
      //     () {
      //   Navigator.push(context, MaterialPageRoute(builder: (context) {
      //     return ProfileScreen(username: widget.username);
      //   }));
      // },
      child: Container(
        child: ListTile(
          leading: leading,
          horizontalTitleGap: 30,
          title: Text(
            titulo,
            style: TextStyle(
                color: AppColors.textColorOnDarkBG,
                fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
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
}
