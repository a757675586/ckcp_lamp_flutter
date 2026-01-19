import 'package:flutter/material.dart';

import '../../themes/colors.dart';
import '../../../core/services/ble_service.dart';
import '../../../core/localization/app_localizations.dart';

/// 设备连接卡片
class DeviceCard extends StatelessWidget {
  final BleDevice? device;
  final BleConnectionState connectionState;
  final String? hwVersion;
  final String? swVersion;
  final String? carModel;
  final VoidCallback? onScanPressed;
  final VoidCallback? onDisconnectPressed;
  final VoidCallback? onFactoryPressed;

  const DeviceCard({
    super.key,
    this.device,
    this.connectionState = BleConnectionState.disconnected,
    this.hwVersion,
    this.swVersion,
    this.carModel,
    this.onScanPressed,
    this.onDisconnectPressed,
    this.onFactoryPressed,
  });

  @override
  Widget build(BuildContext context) {
    final i18n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 设备信息
        Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _getStatusColor(context).withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getStatusIcon(),
                color: _getStatusColor(context),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device?.name ?? i18n.get('no_device_selected'),
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _getStatusText(i18n),
                    style: TextStyle(
                      color: _getStatusColor(context),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // 设备详情 (已连接时显示)
        if (connectionState == BleConnectionState.connected) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                _buildDetailRow(
                    context, i18n.get('hw_version'), hwVersion ?? '-'),
                const Divider(height: 16),
                _buildDetailRow(
                    context, i18n.get('sw_version'), swVersion ?? '-'),
                const Divider(height: 16),
                _buildDetailRow(
                    context, i18n.get('car_model'), carModel ?? '-'),
              ],
            ),
          ),
        ],

        const SizedBox(height: 16),

        // 操作按钮
        if (connectionState == BleConnectionState.disconnected)
          ElevatedButton.icon(
            onPressed: onScanPressed,
            icon: const Icon(Icons.bluetooth_searching, size: 20),
            label: Text(i18n.get('scan_device')),
          )
        else if (connectionState == BleConnectionState.connecting)
          OutlinedButton.icon(
            onPressed: null,
            icon: const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            label: Text(i18n.get('connecting')),
          )
        else ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onDisconnectPressed,
                  icon: const Icon(Icons.link_off, size: 18),
                  label: Text(i18n.get('disconnect')),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style:
              TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Color _getStatusColor(BuildContext context) {
    switch (connectionState) {
      case BleConnectionState.connected:
        return AppColors.success;
      case BleConnectionState.connecting:
        return AppColors.warning;
      case BleConnectionState.disconnected:
        return Theme.of(context).disabledColor;
    }
  }

  IconData _getStatusIcon() {
    switch (connectionState) {
      case BleConnectionState.connected:
        return Icons.bluetooth_connected;
      case BleConnectionState.connecting:
        return Icons.bluetooth_searching;
      case BleConnectionState.disconnected:
        return Icons.bluetooth_disabled;
    }
  }

  String _getStatusText(AppLocalizations i18n) {
    switch (connectionState) {
      case BleConnectionState.connected:
        return i18n.get('connected');
      case BleConnectionState.connecting:
        return i18n.get('connecting');
      case BleConnectionState.disconnected:
        return i18n.get('please_connect');
    }
  }
}
