import 'package:url_launcher/url_launcher.dart';

class Utils {

  static Future<void> launchCaller(String prefix, String value) async {
    String url = "$prefix:$value";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      throw 'Could not to this.';
    }
  }
}