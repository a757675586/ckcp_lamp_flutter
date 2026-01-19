import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../constants/app_info.dart';

class AppUpdateInfo {
  final String version;
  final String content;
  final String downloadUrl;
  final bool force;
  final String releaseDate;
  final String source;

  AppUpdateInfo({
    required this.version,
    required this.content,
    required this.downloadUrl,
    required this.releaseDate,
    this.source = 'Github',
    this.force = false,
  });
}

class AppUpdateService {
  // Singleton pattern
  static final AppUpdateService _instance = AppUpdateService._internal();
  static AppUpdateService get instance => _instance;
  AppUpdateService._internal();

  /// Check for updates
  Future<AppUpdateInfo?> checkUpdate() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock logic: Set true for testing
    const bool hasUpdate = true;

    if (hasUpdate) {
      return AppUpdateInfo(
        version: 'v1.1.0',
        content:
            '# New Features\nNone\n\n# Optimizations & Fixes\n- Code architecture optimization\n- Auto-positioning for new windows\n- Removed real-time memory limit enforcement\n- Fixed various crashes\n- Checksum memory logic fixed',
        // GitHub Release URL
        downloadUrl:
            'https://github.com/a757675586/ckcp_lamp_flutter/releases/download/v1.1.0/installer.exe',
        releaseDate: '2026-01-19',
        source: 'Github',
      );
    }

    return null;
  }

  /// Download the update file
  Future<String> downloadUpdate(String url,
      {required Function(double) onProgress}) async {
    try {
      // Create HttpClient
      final client = HttpClient();
      final request = await client.getUrl(Uri.parse(url));
      final response = await request.close();

      if (response.statusCode != HttpStatus.ok) {
        throw Exception('Download failed with status: ${response.statusCode}');
      }

      final contentLength = response.contentLength;
      final tempDir = await getTemporaryDirectory();
      final fileName =
          url.split('/').last.isEmpty ? 'update.exe' : url.split('/').last;

      final savePath = '${tempDir.path}\\$fileName';
      final file = File(savePath);
      final sink = file.openWrite();

      int receivedBytes = 0;

      // SIMULATION MODE: If url contains "github.com", we simulate progress
      // because the repo doesn't exist yet!
      if (url.contains('github.com') || url.contains('example.com')) {
        await sink.close();
        for (int i = 0; i <= 100; i += 5) {
          await Future.delayed(const Duration(milliseconds: 50));
          onProgress(i / 100.0);
        }
        return savePath;
      }

      await response.listen(
        (chunk) {
          receivedBytes += chunk.length;
          sink.add(chunk);
          if (contentLength > 0) {
            onProgress(receivedBytes / contentLength);
          }
        },
        onDone: () {},
        onError: (e) => throw e,
        cancelOnError: true,
      ).asFuture();

      await sink.flush();
      await sink.close();
      return savePath;
    } catch (e) {
      throw Exception('Update failed: $e');
    }
  }

  /// Open URL in browser
  Future<void> openUrl(String url) async {
    if (Platform.isWindows) {
      await Process.run('explorer', [url]);
    }
  }

  /// Launch the installer
  Future<void> launchInstaller(String filePath) async {
    if (Platform.isWindows) {
      await Process.run('start', ['', filePath], runInShell: true);
    }
  }
}
