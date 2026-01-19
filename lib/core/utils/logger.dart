import 'package:logger/logger.dart' as log;

/// 全局日志工具
class AppLogger {
  AppLogger._();
  
  static final _logger = log.Logger(
    printer: log.PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  /// 调试日志
  static void d(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// 信息日志
  static void i(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.i(message, error: error, stackTrace: stackTrace);
  }

  /// 警告日志
  static void w(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.w(message, error: error, stackTrace: stackTrace);
  }

  /// 错误日志
  static void e(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  /// BLE 相关日志
  static void ble(String message) {
    _logger.i('[BLE] $message');
  }

  /// OTA 相关日志
  static void ota(String message) {
    _logger.i('[OTA] $message');
  }

  /// 协议相关日志
  static void protocol(String message) {
    _logger.d('[Protocol] $message');
  }
}
