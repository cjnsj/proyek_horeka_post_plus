import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceInfoHelper {
  static Future<Map<String, String>> getDeviceInfo() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
    String deviceId = "unknown_id";
    String deviceName = "unknown_device";

    try {
      if (kIsWeb) {
        // Web Platform
        final prefs = await SharedPreferences.getInstance();
        const String webDeviceIdKey = 'web_device_id';

        String? id = prefs.getString(webDeviceIdKey);
        if (id == null) {
          id = const Uuid().v4();
          await prefs.setString(webDeviceIdKey, id);
        }
        deviceId = id;

        WebBrowserInfo webInfo = await deviceInfo.webBrowserInfo;
        deviceName = webInfo.browserName.toString().split('.').last;
      } else if (Platform.isAndroid) {
        // Android Platform
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        deviceId = androidInfo.id;
        deviceName = '${androidInfo.brand} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        // iOS Platform
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        deviceId = iosInfo.identifierForVendor ?? 'ios_id_unknown';
        deviceName = iosInfo.name;
      }
    } catch (e) {
      print("Failed to get device info: $e");
    }

    return {'id': deviceId, 'name': deviceName};
  }
}
