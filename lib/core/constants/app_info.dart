import 'package:package_info_plus/package_info_plus.dart';
import 'package:flutter/foundation.dart';

class AppInfo {
  AppInfo._();

  static const String appName = 'CKCP LAMP';

  static String _version = 'v1.0.0';
  static String get version => _version;
  static const String author = 'BossJJ';
  static const String buildDate =
      String.fromEnvironment('BUILD_DATE', defaultValue: 'Dev Build');
  static const String framework = 'Flutter 3.27 • Windows';

  static Future<void> init() async {
    try {
      final info = await PackageInfo.fromPlatform();
      debugPrint(
          'PackageInfo: version=${info.version}, buildNumber=${info.buildNumber}');
      _version = 'v${info.version}';
      debugPrint('AppInfo: _version set to $_version');

      // Verification Overlay Logic (Optional for Prod)
      // Checks for version_patch.txt to override version for testing
      /*
      final dir = await getApplicationSupportDirectory();
      final file = File('${dir.path}\\version_patch.txt');
      if (await file.exists()) {
        final content = await file.readAsString();
        if (content.trim().isNotEmpty) {
          _version = content.trim();
        }
      }
      */
    } catch (e) {
      debugPrint('AppInfo Init Error: $e');
    }
  }
}
