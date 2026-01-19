import 'dart:async';

/// 全局日志服务
class LogService {
  LogService._();
  static final LogService instance = LogService._();

  final _logController = StreamController<LogEntry>.broadcast();
  Stream<LogEntry> get logs => _logController.stream;

  final List<LogEntry> _history = [];
  List<LogEntry> get history => List.unmodifiable(_history);

  void add(String tag, String message) {
    final entry = LogEntry(
      timestamp: DateTime.now(),
      tag: tag,
      message: message,
    );
    _history.add(entry);
    if (_history.length > 1000) {
      _history.removeAt(0);
    }
    _logController.add(entry);
    // ignore: avoid_print
    print('[${entry.timeStr}] [$tag] $message');
  }

  void clear() {
    _history.clear();
    add('System', 'Logs cleared');
  }

  void info(String message) => add('Info', message);
  void error(String message) => add('Error', message);
  void ble(String message) => add('BLE', message);
  void ota(String message) => add('OTA', message);
}

class LogEntry {
  final DateTime timestamp;
  final String tag;
  final String message;

  LogEntry({
    required this.timestamp,
    required this.tag,
    required this.message,
  });

  String get timeStr {
    return '${timestamp.hour.toString().padLeft(2, '0')}:'
        '${timestamp.minute.toString().padLeft(2, '0')}:'
        '${timestamp.second.toString().padLeft(2, '0')}.'
        '${timestamp.millisecond.toString().padLeft(3, '0')}';
  }

  String get fullText => '[$timeStr] [$tag] $message';
}
