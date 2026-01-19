import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/services/log_service.dart';

class DebugConsole extends StatefulWidget {
  final double height;
  const DebugConsole({super.key, this.height = 200});

  @override
  State<DebugConsole> createState() => _DebugConsoleState();
}

class _DebugConsoleState extends State<DebugConsole> {
  final ScrollController _scrollController = ScrollController();
  bool _autoScroll = true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      decoration: BoxDecoration(
        color: Colors.black87,
        border: Border(top: BorderSide(color: Colors.grey.shade800)),
      ),
      child: Column(
        children: [
          _buildToolbar(),
          Expanded(
            child: StreamBuilder<LogEntry>(
              stream: LogService.instance.logs,
              builder: (context, snapshot) {
                // Trigger scroll on new data if auto-scroll is enabled
                if (snapshot.hasData && _autoScroll) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (_scrollController.hasClients) {
                      _scrollController.jumpTo(
                        _scrollController.position.maxScrollExtent,
                      );
                    }
                  });
                }

                // Always rebuild the list from history
                final logs = LogService.instance.history;

                return ListView.builder(
                  controller: _scrollController,
                  itemCount: logs.length,
                  padding: const EdgeInsets.all(8),
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return SelectableText.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: '[${log.timeStr}] ',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          TextSpan(
                            text: '[${log.tag}] ',
                            style: TextStyle(
                              color: _getTagColor(log.tag),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          TextSpan(
                            text: log.message,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ],
                      ),
                      style: const TextStyle(
                        fontFamily: 'Consolas',
                        fontSize: 12,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 32,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      color: Colors.grey.shade900,
      child: Row(
        children: [
          const Text(
            'DEBUG CONSOLE',
            style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          IconButton(
            icon: Icon(
              _autoScroll ? Icons.vertical_align_bottom : Icons.pause,
              size: 16,
              color: _autoScroll ? Colors.green : Colors.grey,
            ),
            tooltip: 'Auto Scroll',
            onPressed: () => setState(() => _autoScroll = !_autoScroll),
          ),
          IconButton(
            icon: const Icon(Icons.copy, size: 16, color: Colors.white70),
            tooltip: 'Copy All',
            onPressed: () {
              final text =
                  LogService.instance.history.map((e) => e.fullText).join('\n');
              Clipboard.setData(ClipboardData(text: text));
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 16, color: Colors.white70),
            tooltip: 'Clear',
            onPressed: () => LogService.instance.clear(),
          ),
        ],
      ),
    );
  }

  Color _getTagColor(String tag) {
    switch (tag.toUpperCase()) {
      case 'ERROR':
        return Colors.redAccent;
      case 'BLE':
        return Colors.blueAccent;
      case 'OTA':
        return Colors.orangeAccent;
      case 'INFO':
        return Colors.greenAccent;
      default:
        return Colors.cyanAccent;
    }
  }
}
