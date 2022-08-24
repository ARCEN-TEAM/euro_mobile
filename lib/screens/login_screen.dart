import 'dart:convert';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';

import 'package:crypto/crypto.dart';
import '../utilities/constants.dart';
import '../classes/constants.dart';
import 'main_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_translate/flutter_translate.dart';

import '../localization/keys.dart';



class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  bool _https = false;
  bool _rememberMe = false;
  bool _passwordVisible = false;

  @override
  void initState() {
    init();

      isAuthenticating = false;

  }

  Future init() async {
    final https = await StorageService.readSecureData('https');
    final url = await StorageService.readSecureData('url');
    final token = await StorageService.readSecureData('token');
    final remember = await StorageService.readSecureData('rememberME');
    final login = await StorageService.readSecureData('login');
    final senha = await StorageService.readSecureData('senha');

    setState(() {
      _https = https.toString() == 'true';
      _tUrl.text = url.toString();
      _tToken.text = token.toString();
      _rememberMe = remember.toString() == 'true';

      if (_rememberMe) {
        _tLogin.text = login.toString();
        _tSenha.text = senha.toString();
      }
      ApiConstants.baseUrl = 'http' +
          (https.toString() == 'true' ? 's' : '') +
          '://' +
          url.toString() +
          '/api/androidAPI/' +
          token.toString();
    });
  }

  Widget _buildEmailTF(BuildContext context) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translate('utilizador'),
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(

          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _tLogin,
            keyboardType: TextInputType.emailAddress,
            style: TextStyle(
              color: AppColors.textColorOnDarkBG,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.person,
                color: AppColors.textColorOnDarkBG,
              ),
              hintText: translate('inserir_utilizador'),
              hintStyle: kHintTextStyle,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordTF() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          translate('password'),
          style: kLabelStyle,
        ),
        SizedBox(height: 10.0),
        Container(
          alignment: Alignment.centerLeft,
          decoration: kBoxDecorationStyle,
          height: 60.0,
          child: TextField(
            controller: _tSenha,
            obscureText: !_passwordVisible,
            style: TextStyle(
              color: AppColors.textColorOnDarkBG,
              fontFamily: 'OpenSans',
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.only(top: 14.0),
              prefixIcon: Icon(
                Icons.lock,
                color: AppColors.textColorOnDarkBG,
              ),
              hintText: translate('inserir_pass'),
              hintStyle: kHintTextStyle,
              suffixIcon: IconButton(
                icon: Icon(
                  _passwordVisible ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textColorOnDarkBG,
                ),
                onPressed: () {
                  setState(() {
                    _passwordVisible = !_passwordVisible;
                  });
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildForgotPasswordBtn() {
    return Container(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () => print('Forgot Password Button Pressed'),
        child: Padding(
          padding: EdgeInsets.only(right: 0.0),
          child: Text(
            'Forgot Password?',
            style: kLabelStyle,
          ),
        ),
      ),
    );
  }

  Widget _buildRememberMeCheckbox() {
    return Container(
      height: 20.0,
      child: Row(
        children: <Widget>[
          Theme(
            data: ThemeData(unselectedWidgetColor: AppColors.buttonPrimaryColor),
            child: Checkbox(
              value: _rememberMe,
              checkColor: AppColors.textColorOnDarkBG,
              activeColor: AppColors.buttonPrimaryColor,
              onChanged: (value) {
                setState(() {
                  _rememberMe = value!;
                });
              },
            ),
          ),
          Text(
            translate('lembrar'),
            style: kLabelStyle,
          ),
        ],
      ),
    );
  }

  bool isAuthenticating = false;
  final _tLogin = TextEditingController();
  final _tSenha = TextEditingController();

  final _tUrl = TextEditingController();
  final _tToken = TextEditingController();

  _onClickLogin(BuildContext context) {
    final login = _tLogin.text;
    final senha = _tSenha.text;

    if (login.isEmpty || senha.isEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(translate('erro')),
              content: Text(translate('credenciais_erradas')),
              actions: <Widget>[
                TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]);
        },
      );
    } else {
      postRequest();
    }
  }

  String textToMd5(String text) {
    return md5.convert(utf8.encode(text)).toString();
  }
  var response;
  Future<dynamic> postRequest() async {
    setState(() {
      isAuthenticating = true;
    });
    final login = _tLogin.text;
    final senha = textToMd5(_tSenha.text);
    var url = ApiConstants.baseUrl +
        ApiConstants.usersEndpoint +
        '/auth/?user=' +
        login +
        '&psw=' +
        senha;

     response =
        await http.post(Uri.parse(url), headers: ApiConstants.headers);
    final res = json.decode(response.body);

    try {
      if (res.containsKey('token')) {
        ApiConstants.ApiKey = res['token'];
        ApiConstants.UserLogged = login;
        ApiConstants.UserPlants = (res['plantGroups']).cast<String>();
      }
    } catch (error) {
      ApiConstants.ApiKey = '';

    }

    if (ApiConstants.ApiKey != '') {
      setState(() {
        isAuthenticating = false;
      });
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainScreen(username: login)),
      );
    } else {
      setState(() {
        isAuthenticating=false;
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
              title: Text(translate('erro')),
              content: Text(translate('credenciais_erradas')),
              actions: <Widget>[
                TextButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.pop(context);
                    })
              ]);
        },
      );
    }
    return response;
  }

  void _onSwitchChanged(bool value) {
    _https = value;
  }

  Widget _buildLoginBtn(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 25.0),
      width: double.infinity,
      child: TextButton(
        style:
            TextButton.styleFrom(elevation: 10, backgroundColor: (isAuthenticating ? AppColors.buttonPrimaryColor.withOpacity(0.5): AppColors.buttonPrimaryColor)),
        onPressed: () async {
          String loginController = _tLogin.text;
          String senhaController = _tSenha.text;

          final rememb = new StorageItem('rememberME', _rememberMe.toString());
          await StorageService.writeSecureData(rememb);
          if (!_rememberMe) {
            loginController = '';
            senhaController = '';
          }

          final login = new StorageItem('login', loginController);
          await StorageService.writeSecureData(login);
          final senha = new StorageItem('senha', senhaController);
          await StorageService.writeSecureData(senha);

          setState(() {
            ApiConstants.UserLogged = loginController;
            ApiConstants.psw = senhaController;
          });
          _onClickLogin(context);
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: (isAuthenticating ? Container(height: 22,width: 22,child:CircularProgressIndicator( strokeWidth: 2.0,backgroundColor: AppColors.textColorOnDarkBG )) : Text(
            translate('login') ,
            style: TextStyle(
              color: AppColors.textColorOnDarkBG,
              letterSpacing: 1.5,
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              fontFamily: 'OpenSans',
            ),
          ) ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar:
          AppBar(elevation: 0, backgroundColor: AppColors.transparent, actions: <
              Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 20),
          child: IconButton(
            icon: Icon(
              Icons.settings,
              size: 35,
              color: AppColors.textColorOnDarkBG /*Colors.white*/,
            ),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                backgroundColor: AppColors.cardBackgroundColor,//Color(0xFF182943),
                context: context,
                builder: (context) {
                  // Using Wrap makes the bottom sheet height the height of the content.
                  // Otherwise, the height will be half the height of the screen.
                  return SingleChildScrollView(
                    child: AnimatedPadding(
                      padding: MediaQuery.of(context).viewInsets,
                      duration: const Duration(milliseconds: 1),
                      curve: Curves.decelerate,
                      child: Column(
                        children: [
                          Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      0, 12, 0, 0),
                                  child: Container(
                                    width: 50,
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: AppColors.buttonSecondaryColor,
                                      borderRadius: BorderRadius.circular(8),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.selectedItemTextShadowColor,//Color(0xFF3ab1ff).withOpacity(0.5),
                                          spreadRadius: 3,
                                          blurRadius: 8,
                                          //offset: Offset(0, 3), // changes position of shadow
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ]),
                          StatefulBuilder(builder: (context, setStateSB) {
                            return SwitchListTile(
                              title:   Text('HTTPS',
                                  style: TextStyle(color:   AppColors.textColorOnDarkBG )),
                              activeColor: AppColors.buttonPrimaryColor,//Color(0xFF3ab1ff),
                              value: _https,
                              onChanged: (bool value) {
                                setState(() {
                                  _onSwitchChanged(value);
                                });
                                setStateSB(() {
                                  _onSwitchChanged(value);
                                });
                              },
                              secondary:
                                    Icon(Icons.https, color:  AppColors.textColorOnDarkBG),
                            );
                          }),
                          ListTile(
                            leading:
                                Icon(Icons.insert_link, color:  AppColors.textColorOnDarkBG),
                            title: Container(
                              decoration: kBoxDecorationStyle,
                              padding: EdgeInsets.only(left: 10),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top:0.0),
                                ),
                                controller: _tUrl,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color: AppColors.textColorOnDarkBG,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ListTile(
                            leading: Icon(Icons.generating_tokens,
                                color:  AppColors.textColorOnDarkBG),
                            title: Container(
                              decoration: kBoxDecorationStyle,
                              padding: EdgeInsets.only(left: 10,top:0,bottom: 0),
                              child: TextField(
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.only(top:0.0),
                                ),
                                controller: _tToken,
                                keyboardType: TextInputType.text,
                                style: TextStyle(
                                  color:  AppColors.textColorOnDarkBG,
                                  fontFamily: 'OpenSans',
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              TextButton(
                                onPressed: () async {
                                  //TODO testa ligaçao
                                  final urlController = _tUrl.text;
                                  final tokenController = _tToken.text;
                                  var url = 'http' +
                                      (_https.toString() == 'true' ? 's' : '') +
                                      '://' +
                                      urlController.toString() +
                                      '/api/androidAPI/' +
                                      tokenController.toString() +
                                      ApiConstants.testEndpoint +
                                      '/connection';
                                  var result;

                                  try {
                                    response = await http
                                        .post(Uri.parse(url),
                                            headers: ApiConstants.headers)
                                        .timeout(Duration(seconds: 2));

                                    result = response.statusCode;
                                  } catch (e) {
                                    result = '408';
                                  }

                                  final snackBar = SnackBar(
                                    content: Text((result.toString() == '200'
                                        ?  translate('conexao.sucesso')
                                        : (result.toString() == '408'
                                            ? translate('conexao.falhada')
                                            : translate('conexao.recusada')))),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                    margin: EdgeInsets.only(
                                        bottom:
                                            MediaQuery.of(context).size.height -
                                                100 -
                                                MediaQuery.of(context)
                                                    .viewInsets
                                                    .bottom,
                                        right: 20,
                                        left: 20),
                                  );

                                  // Find the ScaffoldMessenger in the widget tree
                                  // and use it to show a SnackBar.

                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                },
                                child: Text(
                                  translate('testar_ligacao'),
                                  style: TextStyle(color:  AppColors.textColorOnDarkBG/*Color(0xFF1d4d73)*/),
                                ),
                                style: TextButton.styleFrom(
                                  elevation: 10,
                                  backgroundColor: AppColors.buttonPrimaryColor ,//Colors.white,
                                ),
                              ),
                              TextButton(
                                onPressed: () async {
                                  final urlController = _tUrl.text;
                                  final tokenController = _tToken.text;

                                  final https = new StorageItem(
                                      'https', _https.toString());
                                  await StorageService.writeSecureData(https);

                                  final url =
                                      new StorageItem('url', urlController);
                                  await StorageService.writeSecureData(url);

                                  final token =
                                      new StorageItem('token', tokenController);
                                  await StorageService.writeSecureData(token);

                                  setState(() {
                                    ApiConstants.baseUrl = 'http' +
                                        (_https.toString() == 'true'
                                            ? 's'
                                            : '') +
                                        '://' +
                                        urlController.toString() +
                                        '/api/androidAPI/' +
                                        tokenController.toString();
                                  });

                                  Navigator.of(context).pop();
                                },
                                child: Text(
                                  translate('gravar_definicoes'),
                                  style: TextStyle(color:  AppColors.textColorOnDarkBG /*Color(0xFF1d4d73)*/),
                                ),
                                style: TextButton.styleFrom(
                                  elevation: 10,
                                  backgroundColor: AppColors.buttonPrimaryColor/*Colors.white*/,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 10)

                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: <Widget>[
              Container(
                height: double.infinity,
                width: double.infinity,
                decoration: BoxDecoration(
                  border: Border.all(width: 0, color: Color(0x0073AEF5)),
                  gradient: RadialGradient(
                    center: Alignment(-1, -1),
                    colors: AppColors.backgroundGradientColors /*[
                      Color(0xFF1d4d73),
                      Color(0xFF0e1623),
                    ]*/,
                    radius: 1.2,
                  ),
                ),
                child: Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 30.0,
                            ),
                            child: Column(
                              children: [
                                SvgPicture.asset('assets/images/logo_arcen.svg',
                                    width: (MediaQuery.of(context).size.height -
                                            10) /
                                        6,
                                    height:
                                        (MediaQuery.of(context).size.height -
                                                10) /
                                            6,
                                    fit: BoxFit.cover,
                                    color:  AppColors.textColorOnDarkBG),
                                SizedBox(height: 20.0),
                                _buildEmailTF(context),
                                SizedBox(
                                  height: 30.0,
                                ),
                                _buildPasswordTF(),
                                //_buildForgotPasswordBtn(),
                                SizedBox(
                                  height: 15.0,
                                ),
                                _buildRememberMeCheckbox(),
                                _buildLoginBtn(context),
                              ],
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }


  void showDemoActionSheet(
      {required BuildContext context, required Widget child}) {
    showCupertinoModalPopup<String>(
        context: context,
        builder: (BuildContext context) => child).then((String? value) {
      if (value != null) changeLocale(context, value);
    });
  }

}