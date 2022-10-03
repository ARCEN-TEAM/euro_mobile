import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter/material.dart';

class StorageService  {

  static final _secureStorage = const FlutterSecureStorage();

  static Future<void> writeSecureData(StorageItem newItem) async {
    await _secureStorage.write(
        key: newItem.key, value: newItem.value, aOptions: _getAndroidOptions());
  }

  static Future<String?> readSecureData(String key) async {
    var readData ;
    bool exists = await containsKeyInSecureData(key);
    if(exists){
      readData = await _secureStorage.read(key: key, aOptions: _getAndroidOptions());
    }else{
      readData = '';
    }

    return readData;
  }

  static Future<void> deleteSecureData(StorageItem item) async {
    await _secureStorage.delete(key: item.key, aOptions: _getAndroidOptions());
  }

  static Future<bool> containsKeyInSecureData(String key) async {
    var containsKey = await _secureStorage.containsKey(key: key, aOptions: _getAndroidOptions());
    return containsKey;
  }

  static Future<List<StorageItem>> readAllSecureData() async {
    var allData = await _secureStorage.readAll(aOptions: _getAndroidOptions());
    List<StorageItem> list =
    allData.entries.map((e) => StorageItem(e.key, e.value)).toList();
    return list;
  }

  static Future<void> deleteAllSecureData() async {
    await _secureStorage.deleteAll(aOptions: _getAndroidOptions());
  }

}

AndroidOptions _getAndroidOptions() => const AndroidOptions(
  encryptedSharedPreferences: true,
);

class StorageItem {
  StorageItem(this.key, this.value);

  final String key;
  final String value;
}

class ApiConstants {

  static String baseUrl = 'https://unibetaodev.secil.pt/api/androidAPI/a02ee9a04a5f28fcb043';
  //static String baseUrl = 'http' + (StorageService.Https ? 's' : '') + '://' + StorageService.baseUrl + '/api/androidAPI/' + StorageService.tokenUrl;
  //static String baseUrl = 'http://192.168.13.191:80/api/androidAPI';
  //static String baseUrl = 'https://unibetaodev.secil.pt/api/androidAPI';
  static String usersEndpoint = '/user';
  static String plantEndpoint = '/plant';
  static String testEndpoint = '/test';
  static String invoiceEndpoint = '/invoice';
  static Map<String, String> headers = {"Content-Type": "application/json", "Location": "https://unibetao.secil.pt"};
  //static Color mainColor = Color(0xFF73AEF5);
  static Color mainColor = Color(0xFF1d4d73);
  static String UserLogged = '';
  static String psw = '';
  static String ApiKey = '';
  static List<String> UserPlants = [];
  static List<String> FilterDates = ['1 D','1 S', '1 M', '3 M', '6 M', '1 A'];
}

class AppColors{
  static Color backgroundBlue = Color(0xFF0f1925);
  static Color primaryBlue= Color(0xFF1d4d73);
  static Color textBoxShadowBlue= Color(0xFF3ab1ff).withOpacity(0.7);
  static Color transparent= Color(0x00000000);


  static List<Color> backgroundGradientColors = [
                                        const Color(0xFF1d4d73),
                                        const Color(0xFF0f1925),
                                      ];
  static List<Color> chartGradientColors = [
                                        const Color(0xFF1d4d73),
                                        const Color(0xFF0f1925),
                                      ];
  static List<Color> chartGradientColorsSecondary = [
                                        const Color(0xff1d7321),
                                        const Color(0xFF0f1925),
                                      ];
  static Color selectedItemBackground = Colors.grey.withOpacity(0.1);
  static Color selectedItemTextShadowColor= Color(0xFF3ab1ff).withOpacity(0.5);
  static Color chartLineColorPrimary=  Color(0xFF3ab1ff) ;
  static Color chartLineColorSecondary= Color(0xFF31B03F);
  static Color buttonSecondaryColor= Color(0xFF3ab1ff);
  static Color selectedItemTextColor= Color(0xFF40a1f0);
  static Color cardBackgroundColor= Color(0xFF172842);


  static Color buttonPrimaryColor= Color(0xFF3a9bea);


  static Color navbarUnselectedItemColor= Color(0xFF7b93af);

  static Color textColorLightBG= Color(0xFF1d4d73);
  static Color textColorOnDarkBG= Colors.white;

}

class GlobalFunctions{
  static void showToast(BuildContext context, String texto) {

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.showSnackBar(
      SnackBar(
        content: Text(texto),
        action: SnackBarAction(
          label: 'OK', onPressed: scaffold.hideCurrentSnackBar,textColor: Colors.black,),
      ),
    );
  }
  static void removeToast(BuildContext context) {

    final scaffold = ScaffoldMessenger.of(context);
    scaffold.clearSnackBars();

  }
}