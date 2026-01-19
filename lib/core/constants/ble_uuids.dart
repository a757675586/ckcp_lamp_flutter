/// BLE UUID 常量定义
/// 参考 WebOTA 项目的 BleService.js
class BleUuids {
  BleUuids._();

  /// 主服务 UUID
  static const String serviceUuid = '0000ffe0-0000-1000-8000-00805f9b34fb';

  /// 写入特征 UUID (Write Without Response)
  static const String writeCharUuid = '0000ff03-0000-1000-8000-00805f9b34fb';

  /// 通知特征 UUID (Notify)
  static const String notifyCharUuid = '0000ffe1-0000-1000-8000-00805f9b34fb';

  /// 设备名称过滤前缀 (符合这些前缀的设备会优先显示)
  static const List<String> deviceNamePrefixes = [
    'CKCP',
    'CK-',
    'LAMP',
    'Ambient',
    'BLE',
    'HC-',
  ];

  /// 检查设备名称是否匹配 (放宽条件: 接受所有有名称的设备)
  static bool isValidDeviceName(String? name) {
    if (name == null || name.isEmpty) return false;
    // 接受所有非空名称的设备
    return true;
  }

  /// 检查设备名称是否为优先设备
  static bool isPriorityDevice(String? name) {
    if (name == null || name.isEmpty) return false;
    return deviceNamePrefixes.any(
      (prefix) => name.toUpperCase().contains(prefix.toUpperCase()),
    );
  }
}
