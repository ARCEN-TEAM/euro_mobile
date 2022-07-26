import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/login_screen.dart';
import 'classes/constants.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  //SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);

  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    statusBarColor: Colors.transparent, // transparent status bar
  ));

  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en_US',
      supportedLocales: ['en_US', 'es']);

  runApp(LocalizedApp(delegate, MyApp()));
}

class MyApp extends StatelessWidget {


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    final rememb = new StorageItem('rememberME', 'true');
    StorageService.writeSecureData(rememb);

    final login = new StorageItem('login', 'GESTORTESTE');
    StorageService.writeSecureData(login);

    final senha = new StorageItem('senha', 'Arcen+1234');
    StorageService.writeSecureData(senha);

    final https = new StorageItem('https', 'true');
    StorageService.writeSecureData(https);

    final url = new StorageItem('url', 'unibetaodev.secil.pt');
    StorageService.writeSecureData(url);

    final token = new StorageItem('token', 'a02ee9a04a5f28fcb043');
    StorageService.writeSecureData(token);

    var localizationDelegate = LocalizedApp.of(context).delegate;

    return LocalizationProvider(
      state: LocalizationProvider.of(context).state,
      child: MaterialApp(
        title: 'EURO Mobile',
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          localizationDelegate
        ],
        supportedLocales: localizationDelegate.supportedLocales,
        locale: localizationDelegate.currentLocale,
        debugShowCheckedModeBanner: false,
        home: LoginScreen(),

        theme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          primaryColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,
          appBarTheme: AppBarTheme(
            color: Colors.transparent,
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.light,
            //TODO color: Theme.of(context).colorScheme.{COLORHERE}
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          useMaterial3: true,

        ),
        darkTheme: ThemeData(
          scaffoldBackgroundColor: Colors.transparent,
          dividerColor: Colors.transparent,
          highlightColor: Colors.transparent,
          hoverColor: Colors.transparent,
          splashColor: Colors.transparent,
          splashFactory: NoSplash.splashFactory,

          appBarTheme: AppBarTheme(
            color: Colors.transparent,
            iconTheme: IconThemeData(
              color: AppColors.textColorOnDarkBG
            )
          ),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,

            //TODO color: Theme.of(context).colorScheme.{COLORHERE}
          ),
          textTheme: GoogleFonts.poppinsTextTheme(
            Theme.of(context).textTheme,
          ),
          useMaterial3: true,

        ),
      ),
    );
  }
}
