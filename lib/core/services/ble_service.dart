import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:win_ble/win_ble.dart';
import 'package:win_ble/win_file.dart';
import '../constants/ble_uuids.dart';
import '../protocols/ckcp_protocol.dart';
import '../protocols/ota_protocol.dart';
import '../services/log_service.dart';

/// Windows 平台 BLE 服务
/// 使用 win_ble 包进行蓝牙通信
class BleService {
  BleService._();
  static final BleService instance = BleService._();

  // 状态
  bool _isInitialized = false;
  bool _isConnected = false;
  String? _connectedDeviceId;
  String? _connectedDeviceName;

  // 配置参数 (从设备获取)
  int mtu = 100;
  int frameDataCount = 64;
  int otaOffset = 0;

  // 设备信息
  String? hwVersion;
  String? swVersion;
  String? carModel;

  // 模块配置 (工厂模式)
  ModuleConfigResponse? moduleConfig;

  // 流控制器
  final _connectionStateController =
      StreamController<BleConnectionState>.broadcast();
  final _notificationController = StreamController<Uint8List>.broadcast();
  final _scanResultController = StreamController<BleDevice>.broadcast();
  final _logController = StreamController<String>.broadcast();
  final _infoUpdateController = StreamController<void>.broadcast();

  // 响应队列 (用于等待特定响应)
  final List<Uint8List> _responseQueue = [];

  // 订阅
  StreamSubscription? _scanSubscription;
  StreamSubscription? _connectionSubscription;
  StreamSubscription? _characteristicSubscription;

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnected => _isConnected;
  String? get connectedDeviceId => _connectedDeviceId;
  String? get connectedDeviceName => _connectedDeviceName;

  Stream<BleConnectionState> get connectionState =>
      _connectionStateController.stream;
  Stream<Uint8List> get notifications => _notificationController.stream;
  Stream<BleDevice> get scanResults => _scanResultController.stream;
  Stream<String> get logs => _logController.stream;
  Stream<void> get infoUpdates => _infoUpdateController.stream;

  /// 初始化 BLE
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // 获取 BLE Server 路径
      final serverPath = await WinServer.path();

      await WinBle.initialize(
        serverPath: serverPath,
        enableLog: true,
      );

      _isInitialized = true;
      _log('BLE initialized successfully');
    } catch (e) {
      _log('BLE initialization failed: $e');
      rethrow;
    }
  }

  /// 检查蓝牙是否可用
  Future<bool> isAvailable() async {
    try {
      final state = await WinBle.bleState.first;
      return state == BleState.On;
    } catch (e) {
      return false;
    }
  }

  /// 开始扫描设备
  Future<void> startScan(
      {Duration timeout = const Duration(seconds: 10)}) async {
    if (!_isInitialized) {
      throw Exception('BLE 未初始化');
    }

    _log('Start scanning...');

    // 取消之前的扫描订阅
    _scanSubscription?.cancel();

    // 监听扫描结果
    _scanSubscription = WinBle.scanStream.listen((device) {
      // 过滤设备名称
      final deviceName = device.name;
      if (deviceName.isNotEmpty && BleUuids.isValidDeviceName(deviceName)) {
        _scanResultController.add(BleDevice(
          id: device.address,
          name: deviceName,
          rssi: int.tryParse(device.rssi.toString()) ?? -100,
        ));
      }
    });

    WinBle.startScanning();

    // 超时后停止扫描
    Future.delayed(timeout, () {
      stopScan();
    });
  }

  /// 停止扫描
  Future<void> stopScan() async {
    WinBle.stopScanning();
    _scanSubscription?.cancel();
    _scanSubscription = null;
    _log('Scan stopped');
  }

  /// 连接设备
  Future<bool> connect(String deviceId, {String? deviceName}) async {
    if (!_isInitialized) {
      throw Exception('BLE 未初始化');
    }

    if (_isConnected) {
      await disconnect();
    } else {
      try {
        await WinBle.disconnect(deviceId);
        await Future.delayed(const Duration(milliseconds: 200));
      } catch (_) {}
    }

    _log('Connecting to: $deviceId');
    _connectionStateController.add(BleConnectionState.connecting);

    try {
      // 监听连接状态
      _connectionSubscription?.cancel();
      _connectionSubscription =
          WinBle.connectionStreamOf(deviceId).listen((connected) {
        if (!connected && _isConnected) {
          _log('Device disconnected detected, cleaning up state');
          _handleDisconnect();
        } else if (connected && !_isConnected) {
          _isConnected = true;
        }
      });

      await WinBle.connect(deviceId);
      _connectedDeviceId = deviceId;
      _connectedDeviceName = deviceName;
      _isConnected = true;

      await Future.delayed(const Duration(milliseconds: 500));

      final services = await WinBle.discoverServices(deviceId);
      final hasService = services.any(
        (s) => s.toLowerCase() == BleUuids.serviceUuid.toLowerCase(),
      );

      if (!hasService) {
        _log('Target service not found');
        await disconnect();
        return false;
      }

      await _subscribeNotifications(deviceId);
      await _requestDeviceInfo();

      _connectionStateController.add(BleConnectionState.connected);
      _log('Device connected');
      return true;
    } catch (e) {
      _log('Connection failed: $e');
      _connectionStateController.add(BleConnectionState.disconnected);
      _isConnected = false;
      return false;
    }
  }

  /// 断开连接
  Future<void> disconnect() async {
    final deviceId = _connectedDeviceId;
    if (deviceId != null) {
      try {
        _characteristicSubscription?.cancel();
        _characteristicSubscription = null;
        _connectionSubscription?.cancel();
        _connectionSubscription = null;

        await WinBle.disconnect(deviceId);
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        _log('Disconnect error: $e');
      }
    }
    _handleDisconnect();
  }

  /// 发送数据
  Future<void> send(Uint8List data) async {
    if (!_isConnected || _connectedDeviceId == null) {
      throw Exception('设备未连接');
    }

    _log('Send: ${CkcpProtocol.toHexString(data)}');

    await WinBle.write(
      address: _connectedDeviceId!,
      service: BleUuids.serviceUuid,
      characteristic: BleUuids.writeCharUuid,
      data: data,
      writeWithResponse: true,
    );
  }

  /// 等待特定响应 (仅检查 subCmd)
  Future<UpgradeResponse?> waitForResponse(
    int expectedSubCmd, {
    Duration timeout = const Duration(milliseconds: 500),
  }) async {
    final completer = Completer<UpgradeResponse?>();

    // 先检查已有队列
    for (final response in _responseQueue) {
      final parsed = OtaParser.parseFrame(response);
      if (parsed != null && parsed.subCmd == expectedSubCmd) {
        _responseQueue.remove(response);
        return parsed;
      }
    }

    // 等待新响应
    StreamSubscription? subscription;
    Timer? timer;

    subscription = notifications.listen((data) {
      final parsed = OtaParser.parseFrame(data);
      if (parsed != null && parsed.subCmd == expectedSubCmd) {
        timer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete(parsed);
        }
      }
    });

    timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// 等待数据帧 ACK (验证 subCmd 和 offset)
  /// 确保 ACK 对应的是我们刚发送的帧，而不是之前的帧
  Future<UpgradeResponse?> waitForDataFrameAck(
    int expectedOffset, {
    Duration timeout = const Duration(seconds: 1),
  }) async {
    final completer = Completer<UpgradeResponse?>();
    final expectedSubCmd = 0x83; // upgradeDataFrameAck

    // 解析 offset 辅助函数
    int parseOffset(Uint8List data) {
      if (data.length < 7) return -1;
      final startIdx = data[0] == 0xFF ? 1 : 0;
      if (data.length < startIdx + 6) return -1;
      return data[startIdx + 2] |
          (data[startIdx + 3] << 8) |
          (data[startIdx + 4] << 16) |
          (data[startIdx + 5] << 24);
    }

    // 先检查已有队列
    for (int i = 0; i < _responseQueue.length; i++) {
      final response = _responseQueue[i];
      final parsed = OtaParser.parseFrame(response);
      if (parsed != null && parsed.subCmd == expectedSubCmd) {
        final offset = parseOffset(response);
        if (offset == expectedOffset) {
          _responseQueue.removeAt(i);
          return parsed;
        }
      }
    }

    // 等待新响应
    StreamSubscription? subscription;
    Timer? timer;

    subscription = notifications.listen((data) {
      final parsed = OtaParser.parseFrame(data);
      if (parsed != null && parsed.subCmd == expectedSubCmd) {
        final offset = parseOffset(data);
        if (offset == expectedOffset) {
          timer?.cancel();
          subscription?.cancel();
          if (!completer.isCompleted) {
            completer.complete(parsed);
          }
        }
      }
    });

    timer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete(null);
      }
    });

    return completer.future;
  }

  /// 清空响应队列
  void clearResponseQueue() {
    _responseQueue.clear();
  }

  // ========== 私有方法 ==========

  /// 订阅通知
  Future<void> _subscribeNotifications(String deviceId) async {
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _rxBuffer.clear();

    // 带重试的订阅逻辑
    int retries = 3;
    Exception? lastError;

    while (retries > 0) {
      try {
        await WinBle.subscribeToCharacteristic(
          address: deviceId,
          serviceId: BleUuids.serviceUuid,
          characteristicId: BleUuids.notifyCharUuid,
        );
        _log('Subscribed to notifications');
        lastError = null;
        break;
      } catch (e) {
        lastError = e is Exception ? e : Exception(e.toString());
        retries--;
        _log('Subscribe failed, retrying ($retries left)... Error: $e');

        try {
          await WinBle.unSubscribeFromCharacteristic(
            address: deviceId,
            serviceId: BleUuids.serviceUuid,
            characteristicId: BleUuids.notifyCharUuid,
          );
        } catch (_) {}

        if (retries > 0) {
          await Future.delayed(const Duration(milliseconds: 500));
        }
      }
    }

    if (lastError != null) {
      throw lastError;
    }

    _characteristicSubscription =
        WinBle.characteristicValueStream.listen((event) {
      String? eventAddress;
      List<int>? eventValue;

      try {
        eventAddress = event.address;
        eventValue = event.value;
      } catch (e) {
        if (event is Map) {
          eventAddress = event['address']?.toString();
          final valueData = event['value'];
          if (valueData is List) {
            eventValue = List<int>.from(valueData);
          }
        }
      }

      if (eventAddress == deviceId && eventValue != null) {
        final bytes = Uint8List.fromList(eventValue);
        // OTA帧在 _processBuffer 中会输出格式化日志
        _handleNotification(bytes);
      }
    });

    _log('Notification characteristic subscribed');
  }

  // 接收缓冲区
  final List<int> _rxBuffer = [];

  /// 处理通知数据
  void _handleNotification(Uint8List data) {
    _rxBuffer.addAll(data);
    _processBuffer();
  }

  /// 处理缓冲区数据
  void _processBuffer() {
    if (_rxBuffer.length > 2048) {
      _rxBuffer.clear();
      return;
    }

    // 1. 优先处理二进制 OTA 响应 (0xFF 0xD9) 和 远程控制响应 (0xFF 0xDB)
    int binaryStartIdx = -1;
    bool isOtaFrame = false;
    bool isRemoteFrame = false;

    for (int i = 0; i < _rxBuffer.length - 1; i++) {
      // OTA 响应
      if (_rxBuffer[i] == 0xFF && _rxBuffer[i + 1] == 0xD9) {
        binaryStartIdx = i;
        isOtaFrame = true;
        break;
      }
      if (_rxBuffer[i] == 0xD9 && (i == 0 || _rxBuffer[i - 1] != 0xFF)) {
        binaryStartIdx = i;
        isOtaFrame = true;
        break;
      }

      // 远程控制响应 (CAN/LIN 监控数据)
      if (_rxBuffer[i] == 0xFF && _rxBuffer[i + 1] == 0xDB) {
        binaryStartIdx = i;
        isRemoteFrame = true;
        break;
      }
    }

    if (binaryStartIdx != -1) {
      if (binaryStartIdx > 0) {
        _rxBuffer.removeRange(0, binaryStartIdx);
      }

      if (isOtaFrame) {
        // 处理 OTA 帧
        int minLen = (_rxBuffer[0] == 0xFF) ? 4 : 3;
        if (_rxBuffer.length >= minLen) {
          // ... (OTA parsing logic, kept generic essentially)
          final binaryData = Uint8List.fromList(_rxBuffer);
          // Try parsing as OTA
          final response = OtaParser.parseFrame(binaryData);
          if (response != null && response.subCmd != 0) {
            // Valid OTA frame
            _log('Received(HEX): ${CkcpProtocol.toHexString(binaryData)}');
            // ... offset parsing ...
            int offset = -1;
            if (binaryData.length >= 7) {
              final startIdx = binaryData[0] == 0xFF ? 1 : 0;
              if (binaryData.length >= startIdx + 6) {
                offset = binaryData[startIdx + 2] |
                    (binaryData[startIdx + 3] << 8) |
                    (binaryData[startIdx + 4] << 16) |
                    (binaryData[startIdx + 5] << 24);
              }
            }
            _log(
                'OTA Response: subCmd=0x${response.subCmd.toRadixString(16)}, offset=$offset, result=${response.result}');
            _notificationController.add(binaryData);
            _responseQueue.add(binaryData);
            _rxBuffer.clear();
            return;
          }
        }
      } else if (isRemoteFrame) {
        // 处理远程控制帧 (Fixed length 15 bytes: FF DB DLC ID(4) DATA(8))
        if (_rxBuffer.length >= 15) {
          final frameData = Uint8List.fromList(_rxBuffer.sublist(0, 15));
          _notificationController.add(frameData);
          _rxBuffer.removeRange(0, 15);
          if (_rxBuffer.isNotEmpty) {
            Future.microtask(_processBuffer);
          }
          return;
        } else {
          // 等待更多数据
          return;
        }
      }
    }

    // 2. 搜索文本帧 <...>
    int startIdx = -1;
    for (int i = 0; i < _rxBuffer.length; i++) {
      if (_rxBuffer[i] == 0x3C) {
        // '<'
        startIdx = i;
        break;
      }
    }

    if (startIdx == -1) {
      if (_rxBuffer.length > 1024) _rxBuffer.clear();
      return;
    }

    int endIdx = -1;
    for (int i = startIdx + 1; i < _rxBuffer.length; i++) {
      if (_rxBuffer[i] == 0x3E) {
        // '>'
        endIdx = i;
        break;
      }
    }

    if (endIdx != -1) {
      final frameBytes = _rxBuffer.sublist(startIdx, endIdx + 1);
      final rawHex = CkcpProtocol.toHexString(Uint8List.fromList(frameBytes));
      _log('Extracted frame: $rawHex');

      try {
        final frameStr = utf8.decode(frameBytes, allowMalformed: true);
        _log('Decoded frame: $frameStr');
        final frameUint8 = Uint8List.fromList(frameBytes);

        // 解析设备信息
        final deviceInfo = CkcpParser.parseDeviceInfoResponse(frameUint8);
        if (deviceInfo != null) {
          hwVersion = deviceInfo.hwVersion;
          swVersion = deviceInfo.swVersion;
          carModel = deviceInfo.carModel;
          _log('✅ Parsed: HW=$hwVersion, SW=$swVersion, Car=$carModel');
          _infoUpdateController.add(null);
        } else if (frameStr.contains('09') || frameStr.contains('<09')) {
          // 09响应解析失败时
          _log('⚠️ 09 Response detected but parse failed! Raw: $rawHex');
        }

        // 解析配置
        final config = CkcpParser.parseConfigResponse(frameUint8);
        if (config != null) {
          mtu = config.mtu;
          frameDataCount = config.frameDataCount;
          otaOffset = config.otaOffset;
          _log('✅ Config Updated: MTU=$mtu, Offset=$otaOffset');
          _infoUpdateController.add(null);
        }

        // 解析模块配置
        final modConfig = CkcpParser.parseModuleConfigResponse(frameUint8);
        if (modConfig != null) {
          moduleConfig = modConfig;
          _log('✅ Module Config Updated: LED=${modConfig.ledCounts}');
          _infoUpdateController.add(null);
        }

        _notificationController.add(frameUint8);
      } catch (e) {
        _log('Frame parse failed: $e');
      }

      _rxBuffer.removeRange(0, endIdx + 1);
      if (_rxBuffer.isNotEmpty) {
        Future.microtask(_processBuffer);
      }
    }
  }

  /// 请求设备信息
  Future<void> _requestDeviceInfo() async {
    try {
      _log('Auto-querying device info...');
      await send(AmbientCommands.queryConfig());
      await Future.delayed(const Duration(milliseconds: 300));
      await send(AmbientCommands.queryVersion());
    } catch (e) {
      _log('Request device info failed: $e');
    }
  }

  /// 查询模块配置 (用于工厂模式)
  Future<void> queryModuleConfig() async {
    if (!_isConnected) return;
    try {
      _log('Querying module config...');
      await send(AmbientCommands.queryModuleInfo());
    } catch (e) {
      _log('Query module config failed: $e');
    }
  }

  /// 处理断开连接
  void _handleDisconnect() {
    _isConnected = false;
    _connectedDeviceId = null;
    _connectedDeviceName = null;
    hwVersion = null;
    swVersion = null;
    carModel = null;
    moduleConfig = null;
    mtu = 100;
    frameDataCount = 64;
    otaOffset = 0;
    _responseQueue.clear();
    _rxBuffer.clear();
    _connectionSubscription?.cancel();
    _connectionSubscription = null;
    _characteristicSubscription?.cancel();
    _characteristicSubscription = null;
    _connectionStateController.add(BleConnectionState.disconnected);
    _log('Device disconnected');
  }

  void _log(String message) {
    LogService.instance.ble(message);

    final timestamp = DateTime.now().toString().substring(11, 19);
    final logMessage = '[$timestamp] [BLE] $message';
    _logController.add(logMessage);
    // Print handled by LogService
  }

  void dispose() {
    _scanSubscription?.cancel();
    _connectionSubscription?.cancel();
    _characteristicSubscription?.cancel();
    _connectionStateController.close();
    _notificationController.close();
    _scanResultController.close();
    _logController.close();
    WinBle.dispose();
  }
}

enum BleConnectionState {
  disconnected,
  connecting,
  connected,
}

class BleDevice {
  final String id;
  final String name;
  final int rssi;

  const BleDevice({
    required this.id,
    required this.name,
    required this.rssi,
  });
}
