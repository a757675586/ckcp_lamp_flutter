import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:win_ble/win_ble.dart' hide BleDevice;
import '../../../core/services/ble_service.dart';

/// BLE 服务提供者
final bleServiceProvider = Provider<BleService>((ref) {
  return BleService.instance;
});

/// BLE 初始化状态
final bleInitializedProvider = FutureProvider<bool>((ref) async {
  final bleService = ref.watch(bleServiceProvider);
  await bleService.initialize();
  await bleService.initialize();
  return bleService.isInitialized;
});

/// BLE 适配器状态 (蓝牙开关)
final bleStateProvider = StreamProvider<BleState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.bleState;
});

/// BLE 连接状态
final bleConnectionStateProvider = StreamProvider<BleConnectionState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.connectionState;
});

/// 扫描结果
final bleScanResultsProvider = StreamProvider<BleDevice>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.scanResults;
});

/// 已连接设备信息
final connectedDeviceProvider = StreamProvider<ConnectedDeviceInfo?>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  final controller = StreamController<ConnectedDeviceInfo?>();

  // 辅助函数：发出当前状态
  void emitCurrentState() {
    if (!bleService.isConnected) {
      if (!controller.isClosed) controller.add(null);
      return;
    }

    if (!controller.isClosed) {
      controller.add(ConnectedDeviceInfo(
        id: bleService.connectedDeviceId ?? '',
        name: bleService.connectedDeviceName ?? '未知设备',
        hwVersion: bleService.hwVersion,
        swVersion: bleService.swVersion,
        carModel: bleService.carModel,
        mtu: bleService.mtu,
        otaPacketCount: bleService.frameDataCount,
      ));
    }
  }

  // 监听连接状态
  final sub1 = bleService.connectionState.listen((_) => emitCurrentState());
  // 监听信息更新
  final sub2 = bleService.infoUpdates.listen((_) => emitCurrentState());

  // 发送初始状态
  emitCurrentState();

  // 清理
  ref.onDispose(() {
    sub1.cancel();
    sub2.cancel();
    controller.close();
  });

  return controller.stream;
});

/// 日志流
final bleLogsProvider = StreamProvider<String>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return bleService.logs;
});

/// BLE 控制器
final bleControllerProvider =
    StateNotifierProvider<BleController, BleControllerState>((ref) {
  final bleService = ref.watch(bleServiceProvider);
  return BleController(bleService);
});

/// 已连接设备信息
class ConnectedDeviceInfo {
  final String id;
  final String name;
  final String? hwVersion;
  final String? swVersion;
  final String? carModel;
  final int mtu;
  final int otaPacketCount;

  ConnectedDeviceInfo({
    required this.id,
    required this.name,
    this.hwVersion,
    this.swVersion,
    this.carModel,
    this.mtu = 100,
    this.otaPacketCount = 64,
  });
}

/// BLE 控制器状态
class BleControllerState {
  final bool isScanning;
  final List<BleDevice> scannedDevices;
  final String? error;

  BleControllerState({
    this.isScanning = false,
    this.scannedDevices = const [],
    this.error,
  });

  BleControllerState copyWith({
    bool? isScanning,
    List<BleDevice>? scannedDevices,
    String? error,
  }) {
    return BleControllerState(
      isScanning: isScanning ?? this.isScanning,
      scannedDevices: scannedDevices ?? this.scannedDevices,
      error: error,
    );
  }
}

/// BLE 控制器
class BleController extends StateNotifier<BleControllerState> {
  final BleService _bleService;
  StreamSubscription? _scanSubscription;

  BleController(this._bleService) : super(BleControllerState());

  /// 开始扫描
  Future<void> startScan() async {
    if (state.isScanning) return;

    state = state.copyWith(
      isScanning: true,
      scannedDevices: [],
      error: null,
    );

    try {
      _scanSubscription = _bleService.scanResults.listen((device) {
        // 避免重复添加
        final exists = state.scannedDevices.any((d) => d.id == device.id);
        if (!exists) {
          state = state.copyWith(
            scannedDevices: [...state.scannedDevices, device],
          );
        }
      });

      await _bleService.startScan(timeout: const Duration(seconds: 10));

      // 10秒后停止
      Future.delayed(const Duration(seconds: 10), () {
        stopScan();
      });
    } catch (e) {
      state = state.copyWith(
        isScanning: false,
        error: e.toString(),
      );
    }
  }

  /// 停止扫描
  Future<void> stopScan() async {
    _scanSubscription?.cancel();
    _scanSubscription = null;
    await _bleService.stopScan();
    state = state.copyWith(isScanning: false);
  }

  /// 连接设备
  Future<bool> connect(BleDevice device) async {
    await stopScan();

    try {
      return await _bleService.connect(device.id, deviceName: device.name);
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    await _bleService.disconnect();
  }

  @override
  void dispose() {
    _scanSubscription?.cancel();
    super.dispose();
  }
}
