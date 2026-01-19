import 'dart:convert';
import 'dart:typed_data';
import '../constants/commands.dart';

/// CKCP 协议核心封装
/// 参考 WebOTA 项目的 AmbientProtocol.js
///
/// 命令格式: <CMD LEN DATA...> (文本格式)
/// - < > 为起止符 (ASCII)
/// - CMD: 命令字节 (hex 文本)
/// - LEN: 数据长度 (hex 文本)
/// - DATA: 数据内容 (hex 文本)
class CkcpProtocol {
  CkcpProtocol._();

  /// 将数值转换为两位十六进制字符串
  static String toHex(int value) {
    return (value & 0xFF).toRadixString(16).padLeft(2, '0').toUpperCase();
  }

  /// 构建协议帧 - 返回文本格式字符串
  /// 格式: <CMD LEN DATA...>
  static String buildFrameText(int cmd, List<int> data) {
    final buffer = StringBuffer();
    buffer.write('<');
    buffer.write(toHex(cmd));
    buffer.write(toHex(data.length));
    for (final byte in data) {
      buffer.write(toHex(byte));
    }
    buffer.write('>');
    return buffer.toString();
  }

  /// 构建协议帧 - 返回 ASCII 编码的字节数组
  static Uint8List buildFrame(int cmd, List<int> data) {
    final text = buildFrameText(cmd, data);
    return Uint8List.fromList(utf8.encode(text));
  }

  /// 从文本命令转换为字节数组
  static Uint8List textToBytes(String cmdText) {
    return Uint8List.fromList(utf8.encode(cmdText));
  }

  /// 转换为十六进制字符串 (调试用，WebOTA格式无空格)
  static String toHexString(Uint8List data) {
    return data
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join();
  }

  /// 从十六进制字符串解析
  static Uint8List fromHexString(String hex) {
    hex = hex.replaceAll(' ', '').replaceAll('<', '').replaceAll('>', '');
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }
}

/// 氛围灯命令生成器
/// 所有方法返回 ASCII 编码的命令字节数组
class AmbientCommands {
  AmbientCommands._();

  // ========== 颜色控制 ==========

  /// 生成单色模式颜色命令
  /// 格式: <0103RRGGBB>
  static Uint8List singleColor(int r, int g, int b) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.singleColor,
      [r & 0xFF, g & 0xFF, b & 0xFF],
    );
  }

  /// 从十六进制颜色生成单色命令
  static Uint8List singleColorHex(String hexColor) {
    hexColor = hexColor.replaceAll('#', '');
    final r = int.parse(hexColor.substring(0, 2), radix: 16);
    final g = int.parse(hexColor.substring(2, 4), radix: 16);
    final b = int.parse(hexColor.substring(4, 6), radix: 16);
    return singleColor(r, g, b);
  }

  // ========== 亮度控制 ==========

  /// 生成区域亮度开关命令
  /// 格式: <020101> 启用区域模式 / <020100> 统一模式
  static Uint8List zoneBrightnessSwitch(bool enabled) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.zoneBrightnessSwitch,
      [enabled ? 0x01 : 0x00],
    );
  }

  /// 生成亮度调节命令
  /// 格式: <0302ZONEVAL>
  /// @param zone - Zone.total, Zone.zone1, Zone.zone2, Zone.zone3
  /// @param value - 亮度值 (0-10)
  static Uint8List brightness(int zone, int value) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.brightness,
      [zone, value.clamp(0, 10)],
    );
  }

  // ========== 开关控制 ==========

  /// 生成开关控制命令
  /// 格式: <04010X>
  /// @param state - SwitchState.off / on / followCar
  static Uint8List lightSwitch(int state) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.lightSwitch,
      [state],
    );
  }

  // ========== 模式控制 ==========

  /// 生成动态/静态模式命令
  /// 格式: <050101> 动态 / <050100> 静态
  static Uint8List dynamicMode(bool isDynamic) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.dynamicMode,
      [isDynamic ? 0x01 : 0x00],
    );
  }

  /// 生成多色主题预设命令
  /// 格式: <0601XX> Index: 1-10
  static Uint8List multiTheme(int themeIndex) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.multiTheme,
      [themeIndex.clamp(1, 10)],
    );
  }

  /// 生成同步模式命令
  /// 格式: <070101> 同步 / <070100> 独立
  static Uint8List syncMode(bool isSync) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.syncMode,
      [isSync ? 0x01 : 0x00],
    );
  }

  // ========== DIY 通道 ==========

  /// 生成 DIY 通道颜色命令
  /// 格式: <08 LEN CH NUM COLORS>
  /// @param channel - Channel.ch1 / ch2 / ch3 / all
  /// @param colors - RGB 颜色数组 [[r,g,b], [r,g,b], ...]
  static Uint8List diyChannel(int channel, List<List<int>> colors) {
    final colorCount = colors.length.clamp(0, 10);
    final data = <int>[channel, colorCount];
    for (var i = 0; i < colorCount; i++) {
      data.add(colors[i][0] & 0xFF); // R
      data.add(colors[i][1] & 0xFF); // G
      data.add(colors[i][2] & 0xFF); // B
    }
    return CkcpProtocol.buildFrame(CkcpCommand.diyChannel, data);
  }

  // ========== 律动模式 ==========

  /// 生成律动主题选择命令
  /// 格式: <24010X> X: 1-8
  static Uint8List rhythmTheme(int themeIndex) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.rhythmTheme,
      [themeIndex.clamp(1, 8)],
    );
  }

  /// 生成律动灵敏度命令
  /// 格式: <1B010X> X: 1-5
  static Uint8List dynamicSensitivity(int level) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.dynamicSensitivity,
      [level.clamp(1, 5)],
    );
  }

  /// 生成律动音源配置命令
  /// @param original - true 原车音源, false 麦克风
  static Uint8List dynamicSource(bool original) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.dynamicSource,
      [original ? 0x01 : 0x00],
    );
  }

  // ========== LED 配置 ==========

  /// 生成 LED 数量配置命令
  static Uint8List ledCount(int zone, int count) {
    return CkcpProtocol.buildFrame(zone, [count.clamp(0, 255)]);
  }

  /// 生成 LED 方向配置命令
  /// @param leftToRight - true 从左到右, false 从右到左
  static Uint8List ledDirection(int zone, bool leftToRight) {
    return CkcpProtocol.buildFrame(zone, [leftToRight ? 0x00 : 0x01]);
  }

  // ========== 附加功能 ==========

  /// 生成附加功能开关命令
  static Uint8List attachment(int func, bool enabled) {
    return CkcpProtocol.buildFrame(func, [enabled ? 0x01 : 0x00]);
  }

  // ========== 查询命令 ==========

  /// 生成查询模块版本命令
  /// 格式: <FC0101>
  static Uint8List queryVersion() {
    return CkcpProtocol.buildFrame(
      CkcpCommand.query,
      [CkcpCommand.queryVersion],
    );
  }

  /// 生成查询模块信息命令
  /// 格式: <FC0102>
  static Uint8List queryModuleInfo() {
    return CkcpProtocol.buildFrame(
      CkcpCommand.query,
      [CkcpCommand.queryModuleInfo],
    );
  }

  /// 生成查询配置命令 (MTU/OTA)
  /// 格式: <FC0103>
  static Uint8List queryConfig() {
    return CkcpProtocol.buildFrame(
      CkcpCommand.query,
      [CkcpCommand.queryConfig],
    );
  }

  // ========== 工厂模式 ==========

  /// 生成进入/退出工厂模式命令
  /// 格式: <FE0101> 进入 / <FE0100> 退出
  static Uint8List factoryMode(bool enter) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.factoryMode,
      [enter ? 0x01 : 0x00],
    );
  }

  /// 生成恢复出厂设置命令
  /// 格式: <FF0101>
  static Uint8List factoryReset() {
    return CkcpProtocol.buildFrame(
      CkcpCommand.factoryReset,
      [0x01],
    );
  }

  // ========== VIN 注册 ==========

  /// 生成 VIN 码注册命令
  /// 格式: <0A1211{VIN_HEX}>
  static Uint8List registerVin(String vin) {
    // VIN 的 ASCII 值作为数据
    final data = <int>[0x12, 0x11]; // 固定前缀
    data.addAll(vin.toUpperCase().codeUnits);
    return CkcpProtocol.buildFrame(CkcpCommand.registerVin, data);
  }

  /// 生成车型编号设置命令
  static Uint8List setCarCode(int code) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.setCarCode,
      [code.clamp(0, 255)],
    );
  }

  /// 生成功能编号设置命令
  static Uint8List setFuncCode(int code) {
    return CkcpProtocol.buildFrame(
      CkcpCommand.setFuncCode,
      [code.clamp(0, 255)],
    );
  }

  /// 生成启动 CAN 监控命令
  /// [0xFF, 0xDA, enabled(1), op(0/1/2), idFrom(4), idTo(4), maxFrames(2)]
  /// param: "100" (single), "100,200" (range), empty (all)
  static Uint8List startCanMonitor(String param) {
    int idFrom = 0xFFFFFFFF;
    int idTo = 0xFFFFFFFF;
    int operation = 2; // 0=set, 1=append, 2=default(all)
    int maxFrames = 100;

    if (param.isNotEmpty) {
      if (param.contains(',') || param.contains('-')) {
        // Range: 100,200 or 100-200
        final parts = param.replaceAll('-', ',').split(',');
        if (parts.length >= 2) {
          idFrom = int.tryParse(parts[0].trim(), radix: 16) ?? 0;
          idTo = int.tryParse(parts[1].trim(), radix: 16) ?? 0;
          operation = 1; // append/range
        }
      } else {
        // Single ID
        idFrom = int.tryParse(param.trim(), radix: 16) ?? 0;
        idTo = idFrom;
        operation = 0; // set
      }
    }

    final data = ByteData(14);
    data.setUint8(0, 0xFF);
    data.setUint8(1, 0xDA);
    data.setUint8(2, 1); // enabled
    data.setUint8(3, operation);
    data.setUint32(4, idFrom, Endian.little);
    data.setUint32(8, idTo, Endian.little);
    data.setUint16(12, maxFrames, Endian.little);

    return data.buffer.asUint8List();
  }

  /// 生成启动 LIN 监控命令
  /// <23 LEN DATA...>
  /// param: "1, 2, 3" (comma separated 0-255)
  static Uint8List startLinMonitor(String param) {
    final parts = param
        .replaceAll('，', ',')
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .toList();

    if (parts.length > 6) return Uint8List(0); // Max 6

    final data = <int>[];
    for (final p in parts) {
      final val = int.tryParse(p.trim()) ?? 0;
      data.add(val.clamp(0, 255));
    }

    // CMD 0x23, LEN=count, DATA...
    return CkcpProtocol.buildFrame(0x23, data);
  }

  /// 生成停止远程监控命令
  /// [0xFF, 0xDC]
  static Uint8List stopRemoteMonitor() {
    return Uint8List.fromList([0xFF, 0xDC]);
  }
}

/// CKCP 协议解析器
class CkcpParser {
  CkcpParser._();

  /// 解析 CAN 帧响应
  /// [0xFF, 0xDB, DLC, ID(4), DATA(8)]
  static String? parseCanFrame(Uint8List data) {
    if (data.length < 15) return null;
    if (data[0] != 0xFF || data[1] != 0xDB) return null;

    final dlc = data[2];
    final idView = ByteData.sublistView(data, 3, 7);
    final id = idView.getUint32(0, Endian.little);

    final payload = data.sublist(7, 7 + dlc); // Uses actual DLC length
    final hexData = payload
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');

    return '${id.toRadixString(16).padLeft(8, '0').toUpperCase()}-> ${dlc.toString().padLeft(2, '0')} $hexData';
  }

  /// 解析 CAN 帧为结构化数据 (ID, DLC, DATA)
  static ({String id, int dlc, String data})? parseCanFrameStruct(
      Uint8List data) {
    if (data.length < 15) return null;
    if (data[0] != 0xFF || data[1] != 0xDB) return null;

    final dlc = data[2];
    final idView = ByteData.sublistView(data, 3, 7);
    final id = idView
        .getUint32(0, Endian.little)
        .toRadixString(16)
        .padLeft(8, '0')
        .toUpperCase();

    final payload = data.sublist(7, 7 + dlc);
    final hexData = payload
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(' ');

    return (id: id, dlc: dlc, data: hexData);
  }

  /// 解析设备信息响应 (文本格式 <CMD LEN DATA...>)
  /// 格式: <09 LEN HW_LEN HW_DATA... MODEL_LEN MODEL_DATA... SW_LEN SW_DATA...>
  static DeviceInfoResponse? parseDeviceInfoResponse(Uint8List rawData) {
    try {
      final text = utf8.decode(rawData, allowMalformed: true);
      return parseDeviceInfoResponseFromText(text);
    } catch (e) {
      return null;
    }
  }

  /// 从文本解析设备信息 (支持标准Hex模式和Raw倒退模式)
  static DeviceInfoResponse? parseDeviceInfoResponseFromText(String text) {
    // 1. 标准 Hex 模式尝试
    try {
      if (!text.contains('<09')) return null;

      final startIndex = text.indexOf('<09');
      final endIndex = text.indexOf('>', startIndex);
      if (endIndex == -1) return null;

      final content = text.substring(startIndex + 1, endIndex);
      if (content.length < 4) return null;

      int index = 4; // Skip CMD(2) + LEN(2)

      // 辅助函数：读取长度和 Hex 字符串
      String readNextStringHex() {
        if (index + 2 > content.length) return '';
        final len = int.parse(content.substring(index, index + 2), radix: 16);
        index += 2;
        int end = index + len * 2;
        if (end > content.length) end = content.length; // 截断

        final hex = content.substring(index, end);
        index = end;
        return _hexToString(hex);
      }

      final hw = readNextStringHex();
      final model = readNextStringHex();
      final sw = readNextStringHex();

      if (hw.isNotEmpty || model.isNotEmpty || sw.isNotEmpty) {
        // 移除严格验证，只要解析出任何数据就返回
        return DeviceInfoResponse(
          hwVersion: hw.isEmpty ? 'Unknown' : hw,
          swVersion: sw.isEmpty ? 'Unknown' : sw,
          carModel: model.isEmpty ? 'Unknown' : model,
          funcCode: 0,
        );
      }
    } catch (e) {
      // Hex 解析失败
    }

    // 2. Raw ASCII 模式尝试
    try {
      final startIndex = text.indexOf('<09');
      final endIndex = text.indexOf('>', startIndex);
      if (endIndex == -1) return null;

      final content = text.substring(startIndex + 1, endIndex);
      if (content.length < 4) return null;

      int index = 4; // Skip CMD(2) + LEN(2)

      String readNextStringRaw() {
        if (index + 2 > content.length) return '';
        final len = int.parse(content.substring(index, index + 2), radix: 16);
        index += 2;
        int end = index + len; // Raw模式长度就是字符数
        if (end > content.length) end = content.length;

        final str = content.substring(index, end);
        index = end;
        return str;
      }

      final hwRaw = readNextStringRaw();
      final modelRaw = readNextStringRaw();
      final swRaw = readNextStringRaw();

      if (hwRaw.isNotEmpty || modelRaw.isNotEmpty || swRaw.isNotEmpty) {
        return DeviceInfoResponse(
          hwVersion: hwRaw.isEmpty ? 'Unknown' : hwRaw,
          swVersion: swRaw.isEmpty ? 'Unknown' : swRaw,
          carModel: modelRaw.isEmpty ? 'Unknown' : modelRaw,
          funcCode: 0,
        );
      }
    } catch (e) {
      // Raw 解析也失败
    }

    return null;
  }

  /// 解析配置响应 (文本格式)
  /// 格式: <2504MMMMOOOO>
  static ConfigResponse? parseConfigResponse(Uint8List rawData) {
    try {
      final text = utf8.decode(rawData);
      if (!text.startsWith('<25')) return null;

      final content = text.substring(1, text.length - 1);
      final len = int.parse(content.substring(2, 4), radix: 16);
      if (len != 4) return null;

      final mtuHex = content.substring(4, 8);
      final offsetHex = content.substring(8, 12);

      return ConfigResponse(
        mtu: int.parse(mtuHex, radix: 16),
        frameDataCount:
            int.parse(offsetHex, radix: 16), // Use otaOffset as frame size
        otaOffset: int.parse(offsetHex, radix: 16),
      );
    } catch (e) {
      return null;
    }
  }

  /// 解析模块配置响应 (CMD 0xFD)
  /// 格式: <FD14 [主驾数量][主驾方向][副驾数量][副驾方向]...[音源][灵敏度][迎宾][车门][车速][转向][空调][碰撞]>
  static ModuleConfigResponse? parseModuleConfigResponse(Uint8List rawData) {
    try {
      final text = utf8.decode(rawData, allowMalformed: true);

      // 支持大小写 FD/fd
      int startIndex = text.indexOf('<FD');
      if (startIndex == -1) startIndex = text.indexOf('<fd');
      if (startIndex == -1) return null;

      final endIndex = text.indexOf('>', startIndex);
      if (endIndex == -1) return null;

      final content = text.substring(startIndex + 1, endIndex);
      final rawContent = content;

      if (content.length < 4) return null;
      final len = int.parse(content.substring(2, 4), radix: 16);

      final expectedLength = 4 + len * 2;
      if (content.length < expectedLength) {
        return null;
      }

      int idx = 4;

      List<int> ledCounts = [];
      List<bool> ledDirections = [];

      for (int i = 0; i < 6; i++) {
        if (idx + 4 > content.length) break;

        final count = int.parse(content.substring(idx, idx + 2), radix: 16);
        ledCounts.add(count);
        idx += 2;

        final dir = int.parse(content.substring(idx, idx + 2), radix: 16);
        ledDirections.add(dir == 0);
        idx += 2;
      }

      while (ledCounts.length < 6) ledCounts.add(20);
      while (ledDirections.length < 6) ledDirections.add(true);

      bool isOriginalSource = false;
      int sensitivity = 3;

      if (idx + 4 <= content.length) {
        isOriginalSource =
            int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        sensitivity =
            int.parse(content.substring(idx, idx + 2), radix: 16).clamp(1, 5);
        idx += 2;
      }

      bool welcomeLight = false;
      bool doorLink = false;
      bool speedResponse = false;
      bool turnLink = false;
      bool acLink = false;
      bool crashWarning = false;

      if (idx + 12 <= content.length) {
        welcomeLight =
            int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        doorLink = int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        speedResponse =
            int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        turnLink = int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        acLink = int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
        crashWarning =
            int.parse(content.substring(idx, idx + 2), radix: 16) != 0;
        idx += 2;
      }

      return ModuleConfigResponse(
        ledCounts: ledCounts,
        ledDirections: ledDirections,
        welcomeLight: welcomeLight,
        doorLink: doorLink,
        speedResponse: speedResponse,
        turnLink: turnLink,
        acLink: acLink,
        crashWarning: crashWarning,
        isOriginalSource: isOriginalSource,
        sensitivity: sensitivity,
        rawData: rawContent,
      );
    } catch (e) {
      return null;
    }
  }

  static String _hexToString(String hex) {
    final buffer = StringBuffer();
    for (var i = 0; i < hex.length; i += 2) {
      final charCode = int.parse(hex.substring(i, i + 2), radix: 16);
      if (charCode != 0) {
        buffer.writeCharCode(charCode);
      }
    }
    return buffer.toString();
  }
}

/// 设备信息响应数据类
class DeviceInfoResponse {
  final String hwVersion;
  final String swVersion;
  final String carModel;
  final int funcCode;

  const DeviceInfoResponse({
    required this.hwVersion,
    required this.swVersion,
    required this.carModel,
    required this.funcCode,
  });
}

/// 配置响应数据类
class ConfigResponse {
  final int mtu;
  final int frameDataCount;
  final int otaOffset;

  const ConfigResponse({
    required this.mtu,
    required this.frameDataCount,
    required this.otaOffset,
  });
}

/// 模块配置响应数据类 (CMD 0xFD)
class ModuleConfigResponse {
  final List<int> ledCounts;
  final List<bool> ledDirections;
  final bool welcomeLight;
  final bool doorLink;
  final bool speedResponse;
  final bool turnLink;
  final bool acLink;
  final bool crashWarning;
  final bool isOriginalSource;
  final int sensitivity;
  final String rawData;

  const ModuleConfigResponse({
    required this.ledCounts,
    required this.ledDirections,
    required this.welcomeLight,
    required this.doorLink,
    required this.speedResponse,
    required this.turnLink,
    required this.acLink,
    required this.crashWarning,
    required this.isOriginalSource,
    required this.sensitivity,
    required this.rawData,
  });

  factory ModuleConfigResponse.defaults() {
    return ModuleConfigResponse(
      ledCounts: [20, 20, 15, 15, 12, 12],
      ledDirections: [true, true, true, true, true, true],
      welcomeLight: false,
      doorLink: false,
      speedResponse: false,
      turnLink: false,
      acLink: false,
      crashWarning: false,
      isOriginalSource: false,
      sensitivity: 2,
      rawData: '',
    );
  }
}
