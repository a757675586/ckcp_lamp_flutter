import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import '../constants/app_info.dart';

class AppUpdateInfo {
  final String version;
  final String content;
  final String downloadUrl;
  final bool force;
  final String releaseDate;
  final String source;
  final bool hasUpdate; // New field

  AppUpdateInfo({
    required this.version,
    required this.content,
    required this.downloadUrl,
    required this.releaseDate,
    this.source = 'Github Releases',
    this.force = false,
    this.hasUpdate = false, // Default false
  });
}

class AppUpdateService {
  static final AppUpdateService _instance = AppUpdateService._internal();
  static AppUpdateService get instance => _instance;
  AppUpdateService._internal();

  /// Check for updates from GitHub Releases API
  Future<AppUpdateInfo?> checkUpdate() async {
    final client = HttpClient();
    try {
      final url =
          'https://api.github.com/repos/a757675586/ckcp_lamp_flutter/releases/latest';

      final request = await client.getUrl(Uri.parse(url));
      request.headers.add('User-Agent', 'CKCP-LAMP-App');

      final response = await request.close();
      if (response.statusCode != HttpStatus.ok) return null;

      final responseBody = await response.transform(utf8.decoder).join();
      final Map<String, dynamic> data = jsonDecode(responseBody);

      final String tagName = data['tag_name'] ?? '';
      final String body = data['body'] ?? '';
      final String publishedAt = data['published_at'] ?? '';
      final String releaseDate =
          publishedAt.length >= 10 ? publishedAt.substring(0, 10) : publishedAt;

      // Prioritize ZIP, then EXE
      String downloadUrl = '';
      final List<dynamic> assets = data['assets'] ?? [];
      for (var asset in assets) {
        final name = asset['name'].toString().toLowerCase();
        if (name.endsWith('.zip') || name.endsWith('.exe')) {
          downloadUrl = asset['browser_download_url'];
          // Prefer zip if multiple found? Let's just take first match or prefer zip.
          if (name.endsWith('.zip')) break;
        }
      }

      if (downloadUrl.isEmpty && assets.isNotEmpty) {
        downloadUrl = assets[0]['browser_download_url'];
      }

      if (tagName.isEmpty) return null;

      final currentVersion = AppInfo.version.replaceAll('v', '');
      final latestVersion = tagName.replaceAll('v', '');

      final isNewer = _isNewer(currentVersion, latestVersion);

      // Return info regardless of isNewer, so UI can show "Latest: vX.X.X"
      return AppUpdateInfo(
        version: tagName,
        content: body,
        downloadUrl: downloadUrl,
        releaseDate: releaseDate,
        source: 'Github Releases',
        hasUpdate: isNewer,
      );
    } catch (e) {
      debugPrint('Error checking update: $e');
      return null;
    } finally {
      client.close(); // Always close HttpClient
    }
  }

  bool _isNewer(String current, String latest) {
    List<String> curParts = current.split('.');
    List<String> latParts = latest.split('.');
    for (int i = 0; i < 3; i++) {
      int cur = i < curParts.length ? int.tryParse(curParts[i]) ?? 0 : 0;
      int lat = i < latParts.length ? int.tryParse(latParts[i]) ?? 0 : 0;
      if (lat > cur) return true;
      if (lat < cur) return false;
    }
    return false;
  }

  Future<String> downloadUpdate(String url,
      {required Function(double) onProgress}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final uri = Uri.parse(url);
      final filename =
          uri.pathSegments.isNotEmpty ? uri.pathSegments.last : 'update.pkg';
      final savePath = path.join(tempDir.path, filename);

      final client = HttpClient();
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode != HttpStatus.ok)
        throw Exception('HTTP ${response.statusCode}');

      final contentLength = response.contentLength;
      final file = File(savePath);
      final sink = file.openWrite();

      int receivedBytes = 0;
      await response.listen((chunk) {
        receivedBytes += chunk.length;
        sink.add(chunk);
        if (contentLength > 0) onProgress(receivedBytes / contentLength);
      }).asFuture();

      await sink.close();

      return savePath;
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  Future<void> launchInstaller(String filePath) async {
    if (Platform.isWindows) {
      final ext = path.extension(filePath).toLowerCase();

      if (ext == '.zip') {
        await _installZip(filePath);
      } else {
        // Assume .exe installer
        await Process.start(filePath, [], mode: ProcessStartMode.detached);
        exit(0);
      }
    }
  }

  Future<void> _installZip(String zipPath) async {
    final tempDir = await getTemporaryDirectory();
    final unzipDir = path.join(tempDir.path, 'update_unzip');

    // Clean unzip dir
    final dir = Directory(unzipDir);
    if (await dir.exists()) await dir.delete(recursive: true);
    await dir.create();

    // 1. Unzip using PowerShell
    // Expand-Archive -Path "zipPath" -DestinationPath "unzipDir" -Force
    final unzipResult = await Process.run('powershell', [
      '-Command',
      'Expand-Archive -Path "$zipPath" -DestinationPath "$unzipDir" -Force'
    ]);

    if (unzipResult.exitCode != 0) {
      throw Exception('Unzip failed: ${unzipResult.stderr}');
    }

    // 2. Create Batch Script to Move Files and Restart
    final scriptPath = path.join(tempDir.path, 'install_update.bat');
    final appDir = path.dirname(Platform.resolvedExecutable);
    final appName = path.basename(Platform.resolvedExecutable);

    // Check if unzip has a subfolder (common in zip) or flat
    // We'll use XCOPY /S

    final scriptContent = '''
@echo off
echo Installing Update...
timeout /t 2 /nobreak >nul
xcopy "$unzipDir\\*" "$appDir\\" /Y /S /E
start "" "$appDir\\$appName"
exit
''';

    await File(scriptPath).writeAsString(scriptContent);

    // 3. Run Batch
    await Process.start(scriptPath, [], mode: ProcessStartMode.detached);
    exit(0);
  }

  Future<void> openUrl(String url) async {
    if (Platform.isWindows) {
      await Process.run('explorer', [url]);
    }
  }
}
