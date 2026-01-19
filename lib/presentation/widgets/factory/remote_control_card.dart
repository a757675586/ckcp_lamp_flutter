import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:ckcp_lamp_flutter/core/models/can_log_entry.dart';
import '../../../core/services/ble_service.dart';
import '../../../core/protocols/ckcp_protocol.dart';
import '../../themes/colors.dart';
import '../common/glass_card.dart';
import '../../../core/extensions/context_extensions.dart';

enum RemoteMode { can, lin }

class RemoteControlCard extends StatefulWidget {
  const RemoteControlCard({super.key});

  @override
  State<RemoteControlCard> createState() => _RemoteControlCardState();
}

class _RemoteControlCardState extends State<RemoteControlCard> {
  RemoteMode _mode = RemoteMode.can;
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _logScrollController = ScrollController();
  final ScrollController _staticScrollController = ScrollController();
  bool _isRunning = false;
  bool _isStaticVisible = false;

  // 用于 UI 显示 (限制数量以保证性能)
  final List<CanLogEntry> _logs = [];
  final int _maxUiLogs = 1000;

  // Static View Data
  final Map<String, CanLogEntry> _staticData = {};
  // Map<ID, List<DateTime?>> - Stores timestamp of last change for each byte (index 0-7)
  final Map<String, List<DateTime?>> _byteChangeTimes = {};

  // 用于保存的全量历史 (不限制或限制很大)
  final List<CanLogEntry> _fullHistory = [];

  // Producer-Consumer 队列
  final List<CanLogEntry> _dataQueue = [];
  Timer? _logTimer;
  Timer? _refreshTimer; // For static view animations
  int _sequenceCounter = 1;

  @override
  void initState() {
    super.initState();
    BleService.instance.notifications.listen(_handleBleData);
    _logTimer =
        Timer.periodic(const Duration(milliseconds: 50), _processLogQueue);
    // Refresh static view UI for fading effects
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _logTimer?.cancel();
    _refreshTimer?.cancel();
    _inputController.dispose();
    _logScrollController.dispose();
    _staticScrollController.dispose();
    super.dispose();
  }

  // Producer
  void _handleBleData(Uint8List data) {
    if (!_isRunning) return;

    final parsed = CkcpParser.parseCanFrameStruct(data);
    if (parsed != null) {
      final entry = CanLogEntry(
        sequence: _sequenceCounter++,
        id: parsed.id,
        dlc: parsed.dlc,
        data: parsed.data,
        timestamp: DateTime.now(),
        isCan: _mode == RemoteMode.can,
      );

      _dataQueue.add(entry);
      _updateStaticData(entry);
    }
  }

  void _updateStaticData(CanLogEntry newEntry) {
    final oldEntry = _staticData[newEntry.id];
    _staticData[newEntry.id] = newEntry;

    if (!_byteChangeTimes.containsKey(newEntry.id)) {
      _byteChangeTimes[newEntry.id] = List.filled(8, null); // Max 8 bytes
    }

    final timestamps = _byteChangeTimes[newEntry.id]!;

    // Parse bytes to compare
    final newBytes = _hexToBytes(newEntry.data);
    final oldBytes = oldEntry != null ? _hexToBytes(oldEntry.data) : <int>[];

    for (int i = 0; i < newBytes.length; i++) {
      // If it's a new byte (index >= old length) or value changed
      if (i >= oldBytes.length || newBytes[i] != oldBytes[i]) {
        if (i < timestamps.length) {
          timestamps[i] = DateTime.now();
        }
      }
    }
  }

  List<int> _hexToBytes(String hex) {
    hex = hex.replaceAll(' ', '');
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      if (i + 2 <= hex.length) {
        bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
      }
    }
    return bytes;
  }

  // Consumer
  void _processLogQueue(Timer timer) {
    if (_dataQueue.isEmpty) return;
    if (!mounted) return;

    setState(() {
      final count = _dataQueue.length > 100 ? 100 : _dataQueue.length;
      final batch = _dataQueue.sublist(0, count);

      // 添加到全量历史 (用于保存)
      _fullHistory.addAll(batch);

      // 添加到 UI 列表 (用于显示，有数量限制)
      _logs.addAll(batch);
      if (_logs.length > _maxUiLogs) {
        _logs.removeRange(0, _logs.length - _maxUiLogs);
      }

      _dataQueue.removeRange(0, count);
    });

    // 智能滚动: 只有当在一个接近底部的位置时才自动滚动
    if (_logScrollController.hasClients) {
      final position = _logScrollController.position;
      if (position.pixels >= position.maxScrollExtent - 100) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_logScrollController.hasClients) {
            _logScrollController
                .jumpTo(_logScrollController.position.maxScrollExtent);
          }
        });
      }
    }
  }

  Future<void> _toggleMonitor() async {
    final bleService = BleService.instance;
    if (!bleService.isConnected) {
      _addSystemLog(context.tr('please_connect'));
      return;
    }

    if (_isRunning) {
      await bleService.send(AmbientCommands.stopRemoteMonitor());
      setState(() => _isRunning = false);
      _addSystemLog(context.tr('stopped'));
    } else {
      final param = _inputController.text;
      final Uint8List cmd;

      if (_mode == RemoteMode.can) {
        cmd = AmbientCommands.startCanMonitor(param);
        _addSystemLog(
            "${context.tr('started_can')}${param.isEmpty ? 'All' : param}");
      } else {
        cmd = AmbientCommands.startLinMonitor(param);
        _addSystemLog("${context.tr('started_lin')}$param");
      }

      await bleService.send(cmd);
      setState(() => _isRunning = true);
    }
  }

  void _addSystemLog(String msg) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      behavior: SnackBarBehavior.floating,
      width: 400,
      backgroundColor: const Color(0xFF333333),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      content: Text(
        msg,
        textAlign: TextAlign.center,
        style: const TextStyle(color: Colors.white),
      ),
      duration: const Duration(milliseconds: 1500),
    ));
  }

  Future<void> _showSaveOptions() async {
    if (_fullHistory.isEmpty) {
      _addSystemLog(context.tr('no_data'));
      return;
    }

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E1E),
        title: Text(context.tr('save_log'),
            style: const TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${context.tr('total_records')}${_fullHistory.length}',
                style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(context.tr('select_location'),
                style: const TextStyle(color: Colors.white)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(context.tr('action_cancel'),
                style: const TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _saveLogs(useCustomPath: false);
            },
            child: Text(context.tr('default_location'),
                style: const TextStyle(color: AppColors.accent)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              _saveLogs(useCustomPath: true);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.accent),
            child: Text(context.tr('choose_location'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _saveLogs({required bool useCustomPath}) async {
    try {
      String? filePath;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final defaultFileName = 'CKCP_Log_$timestamp.txt';

      if (useCustomPath) {
        filePath = await FilePicker.platform.saveFile(
          dialogTitle: context.tr('save_log'),
          fileName: defaultFileName,
          type: FileType.custom,
          allowedExtensions: ['txt', 'csv'],
        );
      } else {
        final directory = await getApplicationDocumentsDirectory();
        final logDir = Directory('${directory.path}/CKCP_Logs');
        if (!await logDir.exists()) {
          await logDir.create(recursive: true);
        }
        filePath = '${logDir.path}/$defaultFileName';
      }

      if (filePath == null) return;

      final file = File(filePath);
      final buffer = StringBuffer();

      // 用户要求增加特定头部
      buffer.writeln("USB2CANFD&LIN Display List File");
      buffer.writeln("序号,帧ID(Hex),长度,数据(Hex),时间标识,方向,帧类型,帧格式,CAN类型,通道号,设备号");

      for (final log in _fullHistory) {
        buffer.writeln(log.toCsvLine());
      }

      await file.writeAsString(buffer.toString());
      _addSystemLog('${context.tr('save_success')}$filePath');
    } catch (e) {
      _addSystemLog('${context.tr('save_failed')}$e');
    }
  }

  Widget _buildModeRadio(String label, RemoteMode mode) {
    final isSelected = _mode == mode;
    return GestureDetector(
      onTap: () {
        if (!_isRunning) setState(() => _mode = mode);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.accent.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.accent
                : (Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey)
                    .withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? AppColors.accent
                  : Theme.of(context).textTheme.bodyMedium?.color,
              size: 18,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? AppColors.accent
                    : Theme.of(context).textTheme.bodyMedium?.color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStaticView() {
    if (_staticData.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.dashboard_outlined,
                size: 40, color: Colors.white.withValues(alpha: 0.1)),
            const SizedBox(height: 10),
            Text(context.tr('no_data'),
                style: TextStyle(color: Colors.white.withValues(alpha: 0.2))),
          ],
        ),
      );
    }

    final sortedKeys = _staticData.keys.toList()..sort();

    return Column(
      children: [
        // Static Header
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.1),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
            border: Border(
                bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
          ),
          child: Row(
            children: [
              SizedBox(
                  width: 50,
                  child: Text(context.tr('seq'),
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13))),
              SizedBox(
                  width: 100,
                  child: Text('ID (HEX)',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13))),
              SizedBox(
                  width: 50,
                  child: Text('Len',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13))),
              Expanded(
                  child: Text('Data Payload',
                      style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13))),
            ],
          ),
        ),
        // Static List
        Expanded(
          child: Theme(
            data: Theme.of(context).copyWith(
                scrollbarTheme: ScrollbarThemeData(
              thumbColor:
                  WidgetStateProperty.all(AppColors.accent.withOpacity(0.5)),
              thickness: WidgetStateProperty.all(10),
              radius: const Radius.circular(5),
              minThumbLength: 20,
            )),
            child: Scrollbar(
              controller: _staticScrollController,
              thumbVisibility: true,
              interactive: true,
              thickness: 10,
              radius: const Radius.circular(5),
              child: ListView.builder(
                controller: _staticScrollController,
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  final id = sortedKeys[index];
                  final entry = _staticData[id]!;
                  return _buildStaticRow(entry, index + 1);
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStaticRow(CanLogEntry entry, int index) {
    final bytes = _hexToBytes(entry.data);
    final timestamps = _byteChangeTimes[entry.id] ?? List.filled(8, null);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.05))),
      ),
      child: Row(
        children: [
          // Sequence
          SizedBox(
            width: 50,
            child: Text(
              '$index',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
                  fontFamily: 'Consolas',
                  fontSize: 12),
            ),
          ),
          // ID
          SizedBox(
            width: 100,
            child: Text(
              entry.id,
              style: const TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Consolas',
                  fontSize: 13),
            ),
          ),
          // DLC
          SizedBox(
            width: 50,
            child: Text(
              "${entry.dlc}",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontFamily: 'Consolas',
                  fontSize: 12),
            ),
          ),
          // Data Bytes
          Expanded(
            child: Wrap(
              spacing: 8,
              children: List.generate(bytes.length, (index) {
                return _buildHighlightedByte(bytes[index],
                    timestamps.length > index ? timestamps[index] : null);
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogItem(CanLogEntry entry) {
    final isEven = entry.sequence % 2 == 0;
    final bgColor =
        isEven ? Colors.white.withValues(alpha: 0.03) : Colors.transparent;

    return Container(
      color: bgColor,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
      child: Row(
        children: [
          // 序号
          SizedBox(
            width: 60,
            child: Text(
              '${entry.sequence}',
              style: TextStyle(
                  color: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.color
                      ?.withValues(alpha: 0.7),
                  fontFamily: 'Consolas',
                  fontSize: 12),
            ),
          ),
          // ID
          SizedBox(
            width: 100,
            child: Text(
              entry.id,
              style: TextStyle(
                  color: AppColors.accent,
                  fontWeight: FontWeight.w600,
                  fontFamily: 'Consolas',
                  fontSize: 13),
            ),
          ),
          // DLC
          SizedBox(
            width: 50,
            child: Text(
              "${entry.dlc}",
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontFamily: 'Consolas',
                  fontSize: 12),
            ),
          ),
          // Data
          Expanded(
            child: Text(
              entry.data,
              style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Consolas',
                  fontSize: 13,
                  letterSpacing: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title Row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.settings_remote,
                    color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                context.tr('remote_control'),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _mode == RemoteMode.can
                        ? Colors.orange.withValues(alpha: 0.2)
                        : Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                        color: _mode == RemoteMode.can
                            ? Colors.orange.withValues(alpha: 0.5)
                            : Colors.blue.withValues(alpha: 0.5)),
                  ),
                  child: Text(
                    _mode == RemoteMode.can ? 'CAN' : 'LIN',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: _mode == RemoteMode.can
                            ? Colors.orange
                            : Colors.blue),
                  )),
              const Spacer(),
              if (_isRunning)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: Colors.green.withValues(alpha: 0.5)),
                  ),
                  child: const Row(
                    children: [
                      SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.green)),
                      SizedBox(width: 6),
                      Text("Run",
                          style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Mode Selection
          Row(
            children: [
              _buildModeRadio('CAN bus', RemoteMode.can),
              _buildModeRadio('LIN bus', RemoteMode.lin),
            ],
          ),
          const SizedBox(height: 16),

          // Input and Input Actions
          // Input and Input Actions
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color),
                  decoration: InputDecoration(
                    hintText: _mode == RemoteMode.can
                        ? 'Filter ID (e.g. 100, 200) - Empty for All'
                        : 'LIN ID',
                    hintStyle: TextStyle(
                        color: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.color
                            ?.withValues(alpha: 0.5),
                        fontSize: 13),
                    filled: true,
                    fillColor: Colors.black.withValues(alpha: 0.2),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                          color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppColors.accent),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    prefixIcon: Icon(Icons.filter_alt_outlined,
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                        size: 18),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Start/Stop Button
              SizedBox(
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _toggleMonitor,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _isRunning ? Colors.red.shade400 : AppColors.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    elevation: 4,
                    shadowColor: (_isRunning ? Colors.red : AppColors.accent)
                        .withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  icon: Icon(_isRunning
                      ? Icons.stop_rounded
                      : Icons.play_arrow_rounded),
                  label: Text(_isRunning ? context.tr('stop_monitor') : 'Start',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Log Area Header & Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Data Stream (${_isRunning ? "Live" : "Paused"})',
                  style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 12)),
              Row(
                children: [
                  // Toggle Static View Button
                  TextButton.icon(
                    onPressed: () =>
                        setState(() => _isStaticVisible = !_isStaticVisible),
                    icon: Icon(
                        _isStaticVisible
                            ? Icons.visibility_off
                            : Icons.visibility,
                        size: 16,
                        color:
                            _isStaticVisible ? AppColors.accent : Colors.grey),
                    label: Text(
                      _isStaticVisible ? 'Hide Static' : 'Show Static',
                      style: TextStyle(
                          color:
                              _isStaticVisible ? AppColors.accent : Colors.grey,
                          fontSize: 12),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Prominent Save Button
                  ElevatedButton.icon(
                    onPressed: _showSaveOptions,
                    icon: const Icon(Icons.save_outlined, size: 16),
                    label: Text(context.tr('save_log')),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      minimumSize: const Size(0, 32),
                      elevation: 2,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _logs.clear();
                        _fullHistory.clear();
                        _dataQueue.clear();
                        _staticData.clear();
                        _byteChangeTimes.clear();
                        _sequenceCounter = 1;
                      });
                    },
                    icon: const Icon(Icons.delete_sweep_outlined,
                        size: 24, color: Color(0xFFFF5252)),
                    tooltip: 'Clear All',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Log View (Stream)
          // Log View (Stream)
          Container(
            height: 400,
            decoration: BoxDecoration(
              color: const Color(0xFF0F0F0F),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4)),
              ],
            ),
            child: Column(
              children: [
                _buildLogItemHeader(),
                Expanded(
                  child: _logs.isEmpty
                      ? Center(
                          child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.monitor_heart_outlined,
                                size: 40,
                                color: Colors.white.withValues(alpha: 0.1)),
                            const SizedBox(height: 10),
                            Text('No data captured',
                                style: TextStyle(
                                    color:
                                        Colors.white.withValues(alpha: 0.2))),
                          ],
                        ))
                      : Theme(
                          data: Theme.of(context).copyWith(
                              scrollbarTheme: ScrollbarThemeData(
                            thumbColor: WidgetStateProperty.all(
                                AppColors.accent.withValues(alpha: 0.5)),
                            thickness: WidgetStateProperty.all(10),
                            radius: const Radius.circular(5),
                            minThumbLength: 20,
                          )),
                          child: Scrollbar(
                            controller: _logScrollController,
                            thumbVisibility: true,
                            interactive: true,
                            thickness: 10,
                            radius: const Radius.circular(5),
                            child: ListView.builder(
                              controller: _logScrollController,
                              itemCount: _logs.length,
                              itemBuilder: (context, index) {
                                return _buildLogItem(_logs[index]);
                              },
                            ),
                          ),
                        ),
                ),
                // Footer / Stats
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    borderRadius:
                        const BorderRadius.vertical(bottom: Radius.circular(8)),
                  ),
                  child: Row(
                    children: [
                      Text("Total: ${_fullHistory.length}",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10)),
                      const Spacer(),
                      Text("Showing: ${_logs.length}",
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.4),
                              fontSize: 10)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (_isStaticVisible) ...[
            const SizedBox(height: 20),
            // Static Monitor Section
            Text('Static Monitor',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              height: 250,
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F0F),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: _buildStaticView(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHighlightedByte(int byte, DateTime? lastChange) {
    final isRecentlyChanged = lastChange != null &&
        DateTime.now().difference(lastChange).inMilliseconds < 1000;

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: isRecentlyChanged
            ? Colors.green.withValues(alpha: 0.3)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        byte.toRadixString(16).padLeft(2, '0').toUpperCase(),
        style: TextStyle(
          fontFamily: 'Consolas',
          fontWeight: isRecentlyChanged ? FontWeight.bold : FontWeight.normal,
          color: isRecentlyChanged
              ? Colors.green
              : Theme.of(context).textTheme.bodyMedium?.color,
        ),
      ),
    );
  }

  Widget _buildLogItemHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
        border: Border(
            bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
      ),
      child: Row(
        children: [
          // Sequence
          SizedBox(
            width: 60,
            child: Text('Sequence',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          // ID
          SizedBox(
            width: 100,
            child: Text('ID (HEX)',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          // DLC
          SizedBox(
            width: 50,
            child: Text('Len',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
          // Data
          Expanded(
            child: Text('Data Payload',
                style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
          ),
        ],
      ),
    );
  }
}
