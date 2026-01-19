import 'dart:async';
import 'dart:typed_data';
import '../protocols/ota_protocol.dart';
import '../constants/commands.dart';
import 'ble_service.dart';
import '../services/log_service.dart';

/// OTA 升级服务
/// 参考 WebOTA 项目的 OtaService.js
class OtaService {
  OtaService._();
  static final OtaService instance = OtaService._();

  final BleService _bleService = BleService.instance;

  bool _isUpgrading = false;
  bool _isCancelled = false;

  // 回调
  void Function(int progress)? onProgress;
  void Function(String status)? onStatusChange;
  void Function(bool success, String? error)? onComplete;

  // 日志
  final _logController = StreamController<String>.broadcast();
  Stream<String> get logs => _logController.stream;

  bool get isUpgrading => _isUpgrading;

  /// 开始固件升级
  /// @param fileData - 固件文件数据
  /// @param version - 版本信息
  Future<bool> startUpgrade(
    Uint8List fileData, {
    int major = 1,
    int minor = 0,
    int build = 0,
  }) async {
    if (_isUpgrading) {
      throw Exception('ota_error_in_progress');
    }

    if (!_bleService.isConnected) {
      throw Exception('ota_error_not_connected');
    }

    _isUpgrading = true;
    _isCancelled = false;
    _updateStatus('ota_preparing');

    try {
      final fileSize = fileData.length;
      final frameDataCount = _bleService.frameDataCount;
      final mtu = _bleService.mtu;
      final totalFrames = (fileSize / frameDataCount).ceil();

      _log('======== OTA Upgrade Parameters ========');
      _log('File Size: $fileSize bytes');
      _log('MTU: $mtu');
      _log('Frame Data Size: $frameDataCount bytes');
      _log('Estimated Frames: $totalFrames');
      _log('========================================');

      // 清空响应队列
      _bleService.clearResponseQueue();

      // 1. 发送升级请求帧
      _updateStatus('ota_step_request');
      final requestFrame = OtaProtocol.generateUpgradeRequestFrame(
        fileData,
        major: major,
        minor: minor,
        build: build,
      );
      await _bleService.send(requestFrame);

      // 2. Wait for confirmation
      _log('Waiting for device confirmation...');
      final ack = await _bleService.waitForResponse(
        CkcpCommand.upgradeAck,
        timeout: const Duration(seconds: 3),
      );
      if (ack == null) {
        throw Exception('ota_error_no_ack');
      }
      _log('Received confirmation response');

      // 3. 分帧发送数据
      int offset = 0;
      int lastProgress = 0;

      while (offset < fileSize && !_isCancelled) {
        final count = (offset + frameDataCount > fileSize)
            ? fileSize - offset
            : frameDataCount;

        // 发送数据帧 (带重试)
        final success = await _sendFrameWithRetry(fileData, offset, count, 3);
        if (!success) {
          throw Exception('ota_error_frame_failed');
        }

        offset += count;

        // 更新进度
        final progress = (offset * 100 / fileSize).round();
        if (progress != lastProgress) {
          lastProgress = progress;
          _updateProgress(progress);
        }
      }

      if (_isCancelled) {
        throw Exception('ota_error_cancelled');
      }

      // 4. Send finish frame
      // Important: Wait for a while to ensure device processes the last data frame
      // WebOTA has natural delay due to JS async, Flutter needs explicit wait
      _log('Waiting for device to process last data frame...');
      await Future.delayed(const Duration(milliseconds: 500));

      _updateStatus('ota_step_finishing');
      final finishFrame = OtaProtocol.generateFinishFrame();
      await _bleService.send(finishFrame);

      // 5. 等待结束确认
      final endAck = await _bleService.waitForResponse(
        CkcpCommand.upgradeDataEndAck,
        timeout: const Duration(seconds: 10),
      );
      if (endAck == null) {
        throw Exception('ota_error_no_finish_ack');
      }

      // Check finish confirmation result
      _log(
          'Received finish confirmation: subCmd=0x${endAck.subCmd.toRadixString(16)}, result=0x${endAck.result.toRadixString(16)}, isSuccess=${endAck.isSuccess}');

      if (!endAck.isSuccess) {
        throw Exception('ota_error_device_rejected');
      }

      _updateStatus('ota_success');
      _log('Firmware upgrade completed');
      _isUpgrading = false;

      onComplete?.call(true, null);
      return true;
    } catch (e) {
      _log('Upgrade failed: $e');
      _updateStatus('ota_failed');
      _isUpgrading = false;
      onComplete?.call(false, e.toString());
      rethrow;
    }
  }

  /// 发送单个数据帧 (带重试)
  Future<bool> _sendFrameWithRetry(
    Uint8List fileData,
    int offset,
    int count,
    int maxRetries,
  ) async {
    for (var retry = 0; retry < maxRetries; retry++) {
      final dataFrame = OtaProtocol.generateDataFrame(fileData, offset, count);
      await _bleService.send(dataFrame);

      // 等待帧确认 - 使用 offset 验证确保是当前帧的 ACK
      final frameAck = await _bleService.waitForDataFrameAck(
        offset,
        timeout: const Duration(seconds: 1),
      );

      if (frameAck != null) {
        // 检查是否取消
        if (frameAck.isCancelled) {
          _log('Device cancelled upgrade');
          return false;
        }

        // result == 0x00 或 0x01 表示成功
        if (frameAck.isSuccess) {
          return true;
        }

        // result == 0xFF 表示失败
        if (frameAck.isFailed) {
          _log(
              'Device rejected frame: ${frameAck.result}, retry ${retry + 1}/$maxRetries');
          // 不立即返回 false，而是继续循环进行重试
          await Future.delayed(const Duration(milliseconds: 100));
          continue;
        }

        // 其他情况视为成功 (防守性编程)
        return true;
      }

      _log(
          'Frame ack timeout, retry ${retry + 1}/$maxRetries, offset: $offset');
      await Future.delayed(const Duration(milliseconds: 100));
    }

    return false;
  }

  /// 取消升级
  void cancelUpgrade() {
    _isCancelled = true;
    _isUpgrading = false;
    _updateStatus('ota_cancelled');
  }

  /// 更新进度
  void _updateProgress(int progress) {
    onProgress?.call(progress);
  }

  /// 更新状态
  void _updateStatus(String status) {
    _log(status);
    onStatusChange?.call(status);
  }

  /// 日志
  void _log(String message) {
    LogService.instance.ota(message);

    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] [OTA] $message';
    _logController.add(logMessage);
  }

  void dispose() {
    _logController.close();
  }
}
