import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import '../themes/colors.dart';
import '../providers/ble_provider.dart';
import '../providers/ota_provider.dart';
import '../widgets/common/glass_card.dart';
import '../../core/services/ble_service.dart';
import '../../ui/widgets/debug_console.dart';
import '../../core/extensions/context_extensions.dart';

/// OTA 升级页面
class OtaPage extends ConsumerWidget {
  const OtaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final otaState = ref.watch(otaControllerProvider);
    final connectionState = ref.watch(bleConnectionStateProvider);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 左侧 - 文件选择
              Expanded(
                child: GlassCard(
                  header: GlassCardHeader(
                    title: context.tr('firmware_file'),
                    icon: '📁',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 文件选择区域
                      _buildFileDropZone(context, ref, otaState),
                      const SizedBox(height: 20),

                      // 文件信息
                      if (otaState.firmware != null) ...[
                        _buildFileInfo(context, otaState),
                        const SizedBox(height: 16),

                        // 清除按钮
                        OutlinedButton.icon(
                          onPressed: () {
                            ref
                                .read(otaControllerProvider.notifier)
                                .clearFirmware();
                          },
                          icon: const Icon(Icons.clear, size: 18),
                          label: Text(context.tr('clear_file')),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),

              // 右侧 - 升级控制
              Expanded(
                child: GlassCard(
                  header: GlassCardHeader(
                    title: context.tr('ota_upgrade'),
                    icon: '🚀',
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // 连接状态检查
                      _buildConnectionStatus(context, connectionState),
                      const SizedBox(height: 20),

                      // 设备信息
                      _buildDeviceInfo(context, ref),
                      const SizedBox(height: 20),

                      // 升级进度
                      if (otaState.isUpgrading) ...[
                        _buildProgressIndicator(context, otaState),
                        const SizedBox(height: 16),
                      ],

                      // 状态信息
                      _buildStatusInfo(context, otaState),
                      const SizedBox(height: 20),

                      // 操作按钮
                      _buildActionButtons(
                          context, ref, otaState, connectionState),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // 底部 - 升级说明
          GlassCard(
            header: GlassCardHeader(
              title: context.tr('upgrade_notes'),
              icon: '📋',
            ),
            child: _buildInstructions(context),
          ),

          const SizedBox(height: 20),
          // Debug Console
          const ClipRRect(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            child: DebugConsole(height: 400),
          ),
        ],
      ),
    );
  }

  Widget _buildFileDropZone(
      BuildContext context, WidgetRef ref, OtaState otaState) {
    return GestureDetector(
      onTap: () => _pickFirmwareFile(ref),
      child: Container(
        height: 160,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: otaState.firmware != null
                ? AppColors.success
                : Theme.of(context).dividerColor,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: otaState.firmware != null
            ? _buildFilePreview(context, otaState)
            : _buildDropPlaceholder(context),
      ),
    );
  }

  Widget _buildDropPlaceholder(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(
            Icons.cloud_upload_outlined,
            size: 32,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          context.tr('ota_step_1'),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          context.tr('supports_bin_format'),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFilePreview(BuildContext context, OtaState otaState) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.success.withOpacity(0.1),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(
            Icons.check_circle,
            size: 28,
            color: AppColors.success,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          otaState.firmwareName ?? context.tr('ota_firmware_name'),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          _formatFileSize(otaState.firmware!.length),
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildFileInfo(BuildContext context, OtaState otaState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(context, context.tr('ota_firmware_name'),
              otaState.firmwareName ?? '-'),
          const Divider(height: 16),
          _buildInfoRow(context, context.tr('ota_file_size'),
              _formatFileSize(otaState.firmware!.length)),
          const Divider(height: 16),
          _buildInfoRow(context, context.tr('ota_frame_count'),
              '${(otaState.firmware!.length / 64).ceil()} ${context.tr('led_unit')}'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
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

  Widget _buildConnectionStatus(
      BuildContext context, AsyncValue<BleConnectionState> connectionState) {
    return connectionState.when(
      data: (state) {
        final isConnected = state == BleConnectionState.connected;
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: (isConnected ? AppColors.success : AppColors.warning)
                .withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: (isConnected ? AppColors.success : AppColors.warning)
                  .withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Icon(
                isConnected
                    ? Icons.bluetooth_connected
                    : Icons.bluetooth_disabled,
                color: isConnected ? AppColors.success : AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected
                          ? context.tr('ota_status_connected')
                          : context.tr('ota_status_disconnected'),
                      style: TextStyle(
                        color:
                            isConnected ? AppColors.success : AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (!isConnected)
                      Text(
                        context.tr('ota_connect_first'),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildDeviceInfo(BuildContext context, WidgetRef ref) {
    final deviceAsync = ref.watch(connectedDeviceProvider);

    return deviceAsync.when(
      data: (device) {
        if (device == null) return const SizedBox.shrink();

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('ota_device_info'),
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(1),
                  1: FixedColumnWidth(32), // Gap
                  2: FlexColumnWidth(1),
                },
                defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                children: [
                  TableRow(
                    children: [
                      _buildParamItem(context, context.tr('ota_hw_version'),
                          device.hwVersion ?? '-'),
                      const SizedBox(),
                      _buildParamItem(context, context.tr('ota_sw_version'),
                          device.swVersion ?? '-'),
                    ],
                  ),
                  const TableRow(children: [
                    SizedBox(height: 12),
                    SizedBox(),
                    SizedBox(height: 12),
                  ]),
                  TableRow(
                    children: [
                      _buildParamItem(context, context.tr('ota_car_model'),
                          device.carModel ?? '-'),
                      const SizedBox(),
                      _buildParamItem(context, context.tr('ota_packet_count'),
                          '${device.otaPacketCount}'),
                    ],
                  ),
                  const TableRow(children: [
                    SizedBox(height: 12),
                    SizedBox(),
                    SizedBox(height: 12),
                  ]),
                  TableRow(
                    children: [
                      _buildParamItem(context, 'MTU', '${device.mtu} Bytes'),
                      const SizedBox(),
                      const SizedBox(), // Empty cell
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }

  Widget _buildParamItem(BuildContext context, String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodySmall?.color,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge?.color,
            fontSize: 12,
            fontFamily: 'Consolas',
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressIndicator(BuildContext context, OtaState otaState) {
    return Column(
      children: [
        // 进度条
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: otaState.progress / 100,
            minHeight: 12,
            backgroundColor: Theme.of(context).cardColor,
            valueColor: const AlwaysStoppedAnimation(AppColors.primary),
          ),
        ),
        const SizedBox(height: 12),

        // 进度文字
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${otaState.progress}%',
              style: const TextStyle(
                color: AppColors.primary,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            // Translate the status which might be an enum key or already translated
            Text(
              context.tr(otaState.status),
              style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusInfo(BuildContext context, OtaState otaState) {
    Color statusColor =
        Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey;
    IconData statusIcon = Icons.info_outline;

    if (otaState.isUpgrading) {
      statusColor = AppColors.info;
      statusIcon = Icons.sync;
    } else if (otaState.error != null) {
      statusColor = AppColors.danger;
      statusIcon = Icons.error_outline;
    } else if (otaState.progress == 100) {
      statusColor = AppColors.success;
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              otaState.error != null
                  ? context.tr(otaState.error!)
                  : context.tr(otaState.status),
              style: TextStyle(color: statusColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    WidgetRef ref,
    OtaState otaState,
    AsyncValue<BleConnectionState> connectionState,
  ) {
    final isConnected = connectionState.whenOrNull(
          data: (state) => state == BleConnectionState.connected,
        ) ??
        false;

    final canUpgrade =
        isConnected && otaState.firmware != null && !otaState.isUpgrading;

    if (otaState.isUpgrading) {
      return OutlinedButton.icon(
        onPressed: () {
          ref.read(otaControllerProvider.notifier).cancelUpgrade();
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.danger,
          side: const BorderSide(color: AppColors.danger),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        icon: const Icon(Icons.stop),
        label: Text(context.tr('ota_cancel')),
      );
    }

    return ElevatedButton.icon(
      onPressed: canUpgrade ? () => _startUpgrade(context, ref) : null,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        disabledBackgroundColor: Theme.of(context).cardColor,
      ),
      icon: const Icon(Icons.rocket_launch),
      label: Text(context.tr('ota_start')),
    );
  }

  Widget _buildInstructions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInstructionItem(
          context,
          '1',
          context.tr('ota_step_1'),
          context.tr('ota_step_1_desc'),
        ),
        const SizedBox(height: 16),
        _buildInstructionItem(
          context,
          '2',
          context.tr('ota_step_2'),
          context.tr('ota_step_2_desc'),
        ),
        const SizedBox(height: 16),
        _buildInstructionItem(
          context,
          '3',
          context.tr('ota_step_3'),
          context.tr('ota_step_3_desc'),
        ),
        const SizedBox(height: 16),
        _buildInstructionItem(
          context,
          '4',
          context.tr('ota_step_4'),
          context.tr('ota_step_4_desc'),
        ),
        const SizedBox(height: 20),

        // 警告提示
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.warning.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.warning.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.warning,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  context.tr('ota_warning'),
                  style: TextStyle(
                    color: AppColors.warning.withOpacity(0.9),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionItem(
      BuildContext context, String step, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              step,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickFirmwareFile(WidgetRef ref) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['bin'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        Uint8List? fileBytes = file.bytes;

        // Windows 平台可能只返回 path，需要手动读取
        if (fileBytes == null && file.path != null) {
          try {
            fileBytes = await File(file.path!).readAsBytes();
          } catch (e) {
            debugPrint('Error reading file: $e');
          }
        }

        if (fileBytes != null) {
          ref.read(otaControllerProvider.notifier).setFirmware(
                fileBytes,
                file.name,
              );
        }
      }
    } catch (e) {
      // 忽略取消选择
    }
  }

  Future<void> _startUpgrade(BuildContext context, WidgetRef ref) async {
    // 显示确认对话框
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(context.tr('ota_confirm_title')),
        content: Text(context.tr('ota_confirm_content')),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(context.tr('action_cancel')),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(context.tr('action_confirm')),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      ref.read(otaControllerProvider.notifier).startUpgrade();
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
  }
}
