import 'package:flutter/material.dart';
import '../../../core/services/ble_service.dart';
import '../../../core/localization/app_localizations.dart';

class ConnectionStatusBadge extends StatelessWidget {
  final BleConnectionState state;

  const ConnectionStatusBadge({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);
    Color color;
    String text;
    IconData icon;

    switch (state) {
      case BleConnectionState.connected:
        color = Colors.green;
        text = i18n.get('connected');
        icon = Icons.bluetooth_connected;
        break;
      case BleConnectionState.connecting:
        color = Colors.orange;
        text = i18n.get('connecting');
        icon = Icons.bluetooth_searching;
        break;
      case BleConnectionState.disconnected:
      default:
        color = Colors.grey;
        text = i18n.get('disconnected');
        icon = Icons.bluetooth_disabled;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
