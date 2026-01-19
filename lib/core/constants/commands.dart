/// CKCP 协议命令常量
/// 参考 WebOTA 项目的 AmbientProtocol.js
class CkcpCommand {
  CkcpCommand._();

  // ========== 氛围灯控制命令 ==========

  /// 单色模式颜色设置 - 格式: <0103RRGGBB>
  static const int singleColor = 0x01;

  /// 区域亮度开关 - 格式: <020101> 启用 / <020100> 统一
  static const int zoneBrightnessSwitch = 0x02;

  /// 亮度调节 - 格式: <0302ZONEVAL>
  static const int brightness = 0x03;

  /// 开关控制 - 格式: <040101> On / <040100> Off / <040102> Follow
  static const int lightSwitch = 0x04;

  /// 动态/静态模式 - 格式: <050101> 动态 / <050100> 静态
  static const int dynamicMode = 0x05;

  /// 多色主题预设 - 格式: <0601XX> Index: 1-10
  static const int multiTheme = 0x06;

  /// 同步模式 - 格式: <070101> 同步 / <070100> 独立
  static const int syncMode = 0x07;

  /// DIY 通道颜色 - 格式: <08 LEN CH NUM COLORS>
  static const int diyChannel = 0x08;

  /// 律动主题选择 - 格式: <24010X> (X: 1-8)
  static const int rhythmTheme = 0x24;

  // 注意: WebOTA 中未发现 0x0A 速度命令，0x0A 为 VIN 注册命令
  // static const int rhythmSpeed = 0x0A;

  // ========== LED 配置命令 (0x0D - 0x13) ==========

  /// 主驾 LED 数量配置
  static const int ledConfigMainDriver = 0x0D;

  /// 副驾 LED 数量配置
  static const int ledConfigCoPilot = 0x0E;

  /// 左前门 LED 数量配置
  static const int ledConfigLeftFront = 0x0F;

  /// 右前门 LED 数量配置
  static const int ledConfigRightFront = 0x10;

  /// 左后门 LED 数量配置
  static const int ledConfigLeftRear = 0x11;

  /// 右后门 LED 数量配置
  static const int ledConfigRightRear = 0x12;

  // ========== 方向配置命令 (0x14+) ==========

  /// 流水灯方向配置
  static const int ledDirection = 0x14;

  // ========== 附加功能 (0x1C - 0x21) ==========

  /// 迎宾灯
  static const int attachWelcome = 0x1C;

  /// 车门联动
  static const int attachDoor = 0x1D;

  /// 车速响应
  static const int attachSpeed = 0x1E;

  /// 转向联动
  static const int attachTurn = 0x1F;

  /// 空调联动
  static const int attachAC = 0x20;

  /// 仪表联动
  static const int attachDashboard = 0x21;

  // ========== 系统命令 ==========

  /// 律动灵敏度
  static const int dynamicSensitivity = 0x1B;

  /// 律动音源
  static const int dynamicSource = 0x1A;

  /// VIN 码注册
  static const int registerVin = 0x70;

  /// 车型编号设置
  static const int setCarCode = 0x71;

  /// 功能编号设置
  static const int setFuncCode = 0x72;

  /// 远程控制 (CAN/LIN)
  static const int remoteControl = 0x80;

  // ========== 查询命令 ==========

  /// 查询命令
  static const int query = 0xFC;

  /// 查询版本 - 格式: <FC0101>
  static const int queryVersion = 0x01;

  /// 查询模块信息 - 格式: <FC0102>
  static const int queryModuleInfo = 0x02;

  /// 查询配置 (MTU/OTA) - 格式: <FC0103>
  static const int queryConfig = 0x03;

  /// 模块信息响应
  static const int moduleInfo = 0xFD;

  /// 工厂模式 - 格式: <FE0101> 进入 / <FE0100> 退出
  static const int factoryMode = 0xFE;

  /// 恢复出厂设置 - 格式: <FF0101>
  static const int factoryReset = 0xFF;

  // ========== OTA 升级命令 ==========

  /// OTA 升级主命令
  static const int upgrade = 0xD8;

  /// 升级子命令
  static const int upgradeRequest = 0x80;
  static const int upgradeAck = 0x81;
  static const int upgradeDataFrame = 0x82;
  static const int upgradeDataFrameAck = 0x83;
  static const int upgradeDataEnd = 0x84;
  static const int upgradeDataEndAck = 0x85;
  static const int upgradeCancel = 0x89;
}

/// 亮度区域常量
class Zone {
  Zone._();

  static const int total = 0x04; // 统一亮度
  static const int zone1 = 0x01; // 区域1 (左前)
  static const int zone2 = 0x02; // 区域2 (右前)
  static const int zone3 = 0x03; // 区域3 (后排)
}

/// 开关状态常量
class SwitchState {
  SwitchState._();

  static const int off = 0x00; // 关闭
  static const int on = 0x01; // 打开
  static const int followCar = 0x02; // 跟随车灯
}

/// DIY 通道常量
class Channel {
  Channel._();

  static const int ch1 = 0x01; // 通道1
  static const int ch2 = 0x02; // 通道2
  static const int ch3 = 0x03; // 通道3
  static const int all = 0x04; // 全部通道 (同步模式)
}

/// LED 区域配置
class LedZone {
  final int countCommand;
  final int directionCommand;
  final String nameKey;
  final String name;

  const LedZone({
    required this.countCommand,
    required this.directionCommand,
    required this.nameKey,
    required this.name,
  });

  /// 所有 LED 区域配置
  static const List<LedZone> allZones = [
    LedZone(
      countCommand: 0x0D,
      directionCommand: 0x14,
      nameKey: 'led_main_driver',
      name: '主驾',
    ),
    LedZone(
      countCommand: 0x0E,
      directionCommand: 0x15,
      nameKey: 'led_co_pilot',
      name: '副驾',
    ),
    LedZone(
      countCommand: 0x0F,
      directionCommand: 0x16,
      nameKey: 'led_left_front',
      name: '左前门',
    ),
    LedZone(
      countCommand: 0x10,
      directionCommand: 0x17,
      nameKey: 'led_right_front',
      name: '右前门',
    ),
    LedZone(
      countCommand: 0x11,
      directionCommand: 0x18,
      nameKey: 'led_left_rear',
      name: '左后门',
    ),
    LedZone(
      countCommand: 0x12,
      directionCommand: 0x19,
      nameKey: 'led_right_rear',
      name: '右后门',
    ),
  ];
}
