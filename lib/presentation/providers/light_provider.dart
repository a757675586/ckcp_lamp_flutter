import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/ble_service.dart';
import '../../../core/protocols/ckcp_protocol.dart';
import '../../../core/constants/commands.dart';

/// 灯光状态
class LightState {
  final bool isOn;
  final int switchState; // 0=关闭, 1=打开, 2=跟随
  final Color currentColor;
  final int totalBrightness;
  final int zone1Brightness;
  final int zone2Brightness;
  final int zone3Brightness;
  final bool isZoneMode;
  final int currentMode; // 0=单色, 1=多色, 2=律动
  final bool isDynamic;
  final bool isSyncMode;
  final int selectedTheme;
  final int rhythmTheme;
  final int rhythmSpeed;
  final int sensitivity;
  final bool isOriginalSource;

  const LightState({
    this.isOn = true,
    this.switchState = 1,
    this.currentColor = Colors.red,
    this.totalBrightness = 5,
    this.zone1Brightness = 5,
    this.zone2Brightness = 5,
    this.zone3Brightness = 5,
    this.isZoneMode = false,
    this.currentMode = 0,
    this.isDynamic = false,
    this.isSyncMode = true,
    this.selectedTheme = 1,
    this.rhythmTheme = 1,
    this.rhythmSpeed = 5,
    this.sensitivity = 2,
    this.isOriginalSource = false,
  });

  LightState copyWith({
    bool? isOn,
    int? switchState,
    Color? currentColor,
    int? totalBrightness,
    int? zone1Brightness,
    int? zone2Brightness,
    int? zone3Brightness,
    bool? isZoneMode,
    int? currentMode,
    bool? isDynamic,
    bool? isSyncMode,
    int? selectedTheme,
    int? rhythmTheme,
    int? rhythmSpeed,
    int? sensitivity,
    bool? isOriginalSource,
  }) {
    return LightState(
      isOn: isOn ?? this.isOn,
      switchState: switchState ?? this.switchState,
      currentColor: currentColor ?? this.currentColor,
      totalBrightness: totalBrightness ?? this.totalBrightness,
      zone1Brightness: zone1Brightness ?? this.zone1Brightness,
      zone2Brightness: zone2Brightness ?? this.zone2Brightness,
      zone3Brightness: zone3Brightness ?? this.zone3Brightness,
      isZoneMode: isZoneMode ?? this.isZoneMode,
      currentMode: currentMode ?? this.currentMode,
      isDynamic: isDynamic ?? this.isDynamic,
      isSyncMode: isSyncMode ?? this.isSyncMode,
      selectedTheme: selectedTheme ?? this.selectedTheme,
      rhythmTheme: rhythmTheme ?? this.rhythmTheme,
      rhythmSpeed: rhythmSpeed ?? this.rhythmSpeed,
      sensitivity: sensitivity ?? this.sensitivity,
      isOriginalSource: isOriginalSource ?? this.isOriginalSource,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'isOn': isOn,
      'switchState': switchState,
      'currentColor': currentColor.value,
      'totalBrightness': totalBrightness,
      'zone1Brightness': zone1Brightness,
      'zone2Brightness': zone2Brightness,
      'zone3Brightness': zone3Brightness,
      'isZoneMode': isZoneMode,
      'currentMode': currentMode,
      'isDynamic': isDynamic,
      'isSyncMode': isSyncMode,
      'selectedTheme': selectedTheme,
      'rhythmTheme': rhythmTheme,
      'rhythmSpeed': rhythmSpeed,
      'sensitivity': sensitivity,
      'isOriginalSource': isOriginalSource,
    };
  }

  factory LightState.fromJson(Map<String, dynamic> json) {
    return LightState(
      isOn: json['isOn'] ?? true,
      switchState: json['switchState'] ?? 1,
      currentColor: Color(json['currentColor'] ?? Colors.red.value),
      totalBrightness: json['totalBrightness'] ?? 5,
      zone1Brightness: json['zone1Brightness'] ?? 5,
      zone2Brightness: json['zone2Brightness'] ?? 5,
      zone3Brightness: json['zone3Brightness'] ?? 5,
      isZoneMode: json['isZoneMode'] ?? false,
      currentMode: json['currentMode'] ?? 0,
      isDynamic: json['isDynamic'] ?? false,
      isSyncMode: json['isSyncMode'] ?? true,
      selectedTheme: json['selectedTheme'] ?? 1,
      rhythmTheme: json['rhythmTheme'] ?? 1,
      rhythmSpeed: json['rhythmSpeed'] ?? 5,
      sensitivity: json['sensitivity'] ?? 2,
      isOriginalSource: json['isOriginalSource'] ?? false,
    );
  }
}

/// 灯光控制器
final lightControllerProvider =
    StateNotifierProvider<LightController, LightState>((ref) {
  return LightController(BleService.instance);
});

class LightController extends StateNotifier<LightState> {
  final BleService _bleService;
  static const String _storageKey = 'light_state_v1';

  LightController(this._bleService) : super(const LightState()) {
    _init();
  }

  Future<void> _init() async {
    await _loadState();

    // 监听连接状态，连接成功时同步状态
    _bleService.connectionState.listen((state) {
      if (state == BleConnectionState.connected) {
        // 延迟一点确保连接稳定
        Future.delayed(const Duration(milliseconds: 500), () {
          syncToDevice();
        });
      }
    });
  }

  /// 加载状态
  Future<void> _loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString(_storageKey);
      if (jsonStr != null) {
        final Map<String, dynamic> json =
            Map<String, dynamic>.from(const JsonDecoder().convert(jsonStr));
        state = LightState.fromJson(json);
      }
    } catch (e) {
      print('加载状态失败: $e');
    }
  }

  /// 保存状态
  Future<void> _saveState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = const JsonEncoder().convert(state.toJson());
      await prefs.setString(_storageKey, jsonStr);
    } catch (e) {
      print('保存状态失败: $e');
    }
  }

  /// 同步所有状态到设备
  Future<void> syncToDevice() async {
    if (!_bleService.isConnected) return;
    print('开始同步状态到设备...');

    try {
      // 1. 开关状态
      await _send(AmbientCommands.lightSwitch(state.switchState));
      await Future.delayed(const Duration(milliseconds: 50));

      // 2. 亮度设置
      await _send(AmbientCommands.zoneBrightnessSwitch(state.isZoneMode));
      await Future.delayed(const Duration(milliseconds: 50));

      if (state.isZoneMode) {
        await _send(
            AmbientCommands.brightness(Zone.zone1, state.zone1Brightness));
        await _send(
            AmbientCommands.brightness(Zone.zone2, state.zone2Brightness));
        await _send(
            AmbientCommands.brightness(Zone.zone3, state.zone3Brightness));
      } else {
        await _send(
            AmbientCommands.brightness(Zone.total, state.totalBrightness));
      }
      await Future.delayed(const Duration(milliseconds: 50));

      // 3. 模式设置 (会触发对应模式的详细设置)
      await switchMode(state.currentMode);
    } catch (e) {
      print('同步状态失败: $e');
    }
  }

  /// 设置开关状态
  Future<void> setSwitchState(int switchState) async {
    state = state.copyWith(
      switchState: switchState,
      isOn: switchState != SwitchState.off,
    );
    _saveState();
    await _send(AmbientCommands.lightSwitch(switchState));
  }

  /// 设置颜色
  Future<void> setColor(Color color) async {
    state = state.copyWith(currentColor: color);
    _saveState(); // 实时保存可能太频繁，但考虑到用户操作频率不高，先这样
    await _send(AmbientCommands.singleColor(
      color.red,
      color.green,
      color.blue,
    ));
  }

  /// 设置区域模式
  Future<void> setZoneMode(bool isZoneMode) async {
    state = state.copyWith(isZoneMode: isZoneMode);
    _saveState();

    // 发送开关指令
    await _send(AmbientCommands.zoneBrightnessSwitch(isZoneMode));

    // 需求: 切换时把当前的亮度只发送一次
    // 解决方案: 增加指令间隔，防止设备端接收缓冲区溢出或处理不及时
    if (isZoneMode) {
      await Future.delayed(const Duration(milliseconds: 50));
      await _send(
          AmbientCommands.brightness(Zone.zone1, state.zone1Brightness));

      await Future.delayed(const Duration(milliseconds: 50));
      await _send(
          AmbientCommands.brightness(Zone.zone2, state.zone2Brightness));

      await Future.delayed(const Duration(milliseconds: 50));
      await _send(
          AmbientCommands.brightness(Zone.zone3, state.zone3Brightness));
    } else {
      await Future.delayed(const Duration(milliseconds: 50));
      await _send(
          AmbientCommands.brightness(Zone.total, state.totalBrightness));
    }
  }

  /// 设置总亮度
  Future<void> setTotalBrightness(int value) async {
    state = state.copyWith(totalBrightness: value);
    _saveState();
    await _send(AmbientCommands.brightness(Zone.total, value));
  }

  /// 设置区域亮度
  Future<void> setZoneBrightness(int zone, int value) async {
    switch (zone) {
      case Zone.zone1:
        state = state.copyWith(zone1Brightness: value);
        break;
      case Zone.zone2:
        state = state.copyWith(zone2Brightness: value);
        break;
      case Zone.zone3:
        state = state.copyWith(zone3Brightness: value);
        break;
    }
    _saveState();
    await _send(AmbientCommands.brightness(zone, value));
  }

  /// 切换模式 (核心逻辑)
  Future<void> switchMode(int mode) async {
    state = state.copyWith(currentMode: mode);
    _saveState();

    if (!_bleService.isConnected) return;

    try {
      switch (mode) {
        case 0: // 单色模式
          await setColor(state.currentColor);
          break;

        case 1: // 多色模式
          // 1. 发送动态/静态开关
          await _send(AmbientCommands.dynamicMode(state.isDynamic));
          await Future.delayed(const Duration(milliseconds: 50));

          // 2. 发送同步/独立开关
          await _send(AmbientCommands.syncMode(state.isSyncMode));
          await Future.delayed(const Duration(milliseconds: 50));

          // 3. 发送选中的多色主题
          await _send(AmbientCommands.multiTheme(state.selectedTheme));
          break;

        case 2: // 律动模式
          final effectId = state.rhythmTheme > 0 ? state.rhythmTheme : 1;
          await _send(AmbientCommands.rhythmTheme(effectId));
          break;
      }
    } catch (e) {
      print('切换模式指令发送失败: $e');
    }
  }

  /// 设置动态模式
  Future<void> setDynamicMode(bool isDynamic) async {
    state = state.copyWith(isDynamic: isDynamic);
    _saveState();

    await _send(AmbientCommands.dynamicMode(isDynamic));

    // 需求: 切换动态模式时，把预设方案发送一次
    // 如果是动态模式，发送当前的主题
    // 如果是静态模式，其实也是同一个主题命令，只是设备表现不同?
    // 通常静态模式下也需要颜色的。这里假定 MultiTheme 命令在静态下也有效
    await Future.delayed(const Duration(milliseconds: 50));
    await _send(AmbientCommands.multiTheme(state.selectedTheme));
  }

  /// 设置同步模式
  Future<void> setSyncMode(bool isSyncMode) async {
    state = state.copyWith(isSyncMode: isSyncMode);
    _saveState();
    await _send(AmbientCommands.syncMode(isSyncMode));
  }

  /// 选择多色主题
  Future<void> selectMultiTheme(int themeIndex) async {
    state = state.copyWith(selectedTheme: themeIndex);
    _saveState();
    await _send(AmbientCommands.multiTheme(themeIndex));
  }

  /// 选择律动主题
  Future<void> selectRhythmTheme(int themeIndex) async {
    state = state.copyWith(rhythmTheme: themeIndex);
    _saveState();
    await _send(AmbientCommands.rhythmTheme(themeIndex));
  }

  /// 设置灵敏度
  Future<void> setSensitivity(int level) async {
    state = state.copyWith(sensitivity: level);
    _saveState();
    await _send(AmbientCommands.dynamicSensitivity(level));
  }

  /// 设置音源
  Future<void> setAudioSource(bool original) async {
    state = state.copyWith(isOriginalSource: original);
    _saveState();
    await _send(AmbientCommands.dynamicSource(original));
  }

  /// 设置 DIY 通道颜色
  Future<void> setDiyChannelColors(int channel, List<Color> colors) async {
    // DIY 颜色通常不保存到全局状态，或者需要单独结构
    final colorList = colors.map((c) => [c.red, c.green, c.blue]).toList();
    await _send(AmbientCommands.diyChannel(channel, colorList));
  }

  /// 发送命令
  Future<void> _send(Uint8List data) async {
    if (_bleService.isConnected) {
      try {
        await _bleService.send(data);
      } catch (e) {
        // 忽略发送错误
      }
    }
  }
}
