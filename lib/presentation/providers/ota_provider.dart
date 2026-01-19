import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/ota_service.dart';

/// OTA 升级状态
class OtaState {
  final bool isUpgrading;
  final int progress;
  final String status;
  final String? error;
  final Uint8List? firmware;
  final String? firmwareName;

  const OtaState({
    this.isUpgrading = false,
    this.progress = 0,
    this.status = 'ota_ready',
    this.error,
    this.firmware,
    this.firmwareName,
  });

  OtaState copyWith({
    bool? isUpgrading,
    int? progress,
    String? status,
    String? error,
    Uint8List? firmware,
    String? firmwareName,
    bool clearFirmware = false,
  }) {
    return OtaState(
      isUpgrading: isUpgrading ?? this.isUpgrading,
      progress: progress ?? this.progress,
      status: status ?? this.status,
      error: error,
      firmware: clearFirmware ? null : (firmware ?? this.firmware),
      firmwareName: clearFirmware ? null : (firmwareName ?? this.firmwareName),
    );
  }
}

/// OTA 控制器
final otaControllerProvider =
    StateNotifierProvider<OtaController, OtaState>((ref) {
  return OtaController(OtaService.instance);
});

class OtaController extends StateNotifier<OtaState> {
  final OtaService _otaService;

  OtaController(this._otaService) : super(const OtaState()) {
    _otaService.onProgress = (progress) {
      state = state.copyWith(progress: progress);
    };
    _otaService.onStatusChange = (status) {
      state = state.copyWith(status: status);
    };
    _otaService.onComplete = (success, error) {
      state = state.copyWith(
        isUpgrading: false,
        error: error,
        status: success ? 'ota_success' : 'ota_failed',
      );
    };
  }

  /// 设置固件文件
  void setFirmware(Uint8List data, String name) {
    state = state.copyWith(
      firmware: data,
      firmwareName: name,
      error: null,
    );
  }

  /// 清除固件
  void clearFirmware() {
    state = state.copyWith(
      clearFirmware: true,
      progress: 0,
      status: 'ota_ready',
      error: null,
    );
  }

  /// 开始升级
  Future<bool> startUpgrade({
    int major = 1,
    int minor = 0,
    int build = 0,
  }) async {
    if (state.firmware == null) {
      state = state.copyWith(error: 'ota_select_firmware_first');
      return false;
    }

    if (_otaService.isUpgrading) {
      state = state.copyWith(error: 'ota_error_in_progress');
      return false;
    }

    state = state.copyWith(
      isUpgrading: true,
      progress: 0,
      error: null,
      status: 'ota_preparing',
    );

    try {
      return await _otaService.startUpgrade(
        state.firmware!,
        major: major,
        minor: minor,
        build: build,
      );
    } catch (e) {
      state = state.copyWith(
        isUpgrading: false,
        error: e.toString(),
        status: 'ota_failed',
      );
      return false;
    }
  }

  /// 取消升级
  void cancelUpgrade() {
    _otaService.cancelUpgrade();
    state = state.copyWith(
      isUpgrading: false,
      status: 'ota_cancelled',
    );
  }
}
