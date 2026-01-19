# OTA 升级 Bug 修复报告

**日期**: 2026-01-17  
**版本**: v1.0  
**状态**: ✅ 已解决

---

## 📋 问题概述

Flutter Windows 应用的 OTA 固件升级功能持续失败，设备返回错误码 `0x64 (100)`，而使用相同固件文件的 WebOTA 示例程序可以成功升级。

---

## 🔍 诊断过程

### 1. 建立调试基础设施

首先创建了调试工具以便进行日志对比分析：

- **LogService**: 集中式日志服务，统一管理 BLE/OTA 日志
- **DebugConsole**: 实时日志显示组件，集成到 OTA 页面
- **日志格式统一**: 将 Flutter 日志格式改为与 WebOTA 一致（无空格HEX、解析结果输出）

### 2. 日志格式对比

**WebOTA 格式**:
```
[09:42:48] 发送: FFD8829CFD1000F401...
[09:42:48] 收到(HEX): FFD9839CFD100000
[09:42:48] 升级响应: subCmd=0x83, offset=1113500, result=0
```

**Flutter 修改后格式** (保持一致便于对比):
```
[10:07:41] 发送: FFD8829CFD1000F401...
[10:07:41] 收到(HEX): FFD9839CFD100000
[10:07:41] 升级响应: subCmd=0x83, offset=1113500, result=0
```

---

## 🐛 发现的 Bug 及修复

### Bug 1: Finish ACK 解析位置错误

**问题**: `OtaParser.parseFrame` 解析 Finish ACK (0x85) 时，从错误的位置读取 result 字节。

**原因**: 
```dart
// 错误代码
result = data[startIdx + 2];  // 读取的是 offset 的第一个字节！
```

对于 `FF D9 85 FF FF FF FF 64`:
- 错误读取: `startIdx + 2` = `FF` (offset 的一部分)
- 正确读取: `startIdx + 6` = `64` (真正的 result)

**修复**:
```dart
// ota_protocol.dart
} else if (subCmd == 0x85) {
  // 格式: [FF] D9 85 OFFSET(4B) RESULT(1B)
  if (data.length >= startIdx + 7) {
    result = data[startIdx + 6];  // 正确位置
  } else if (data.length > startIdx + 2) {
    result = data[startIdx + 2];  // 短响应 fallback
  }
}
```

---

### Bug 2: Finish ACK Result 未验证

**问题**: `OtaService` 只检查 `endAck != null`，没有验证 `endAck.isSuccess`。

**原因**: 设备返回 `result=0x64` 表示失败，但 App 误报"升级成功"。

**修复**:
```dart
// ota_service.dart
if (endAck == null) {
  throw Exception('未收到升级完成确认');
}

// 新增: 检查结果
_log('收到结束确认: subCmd=0x${endAck.subCmd.toRadixString(16)}, result=0x${endAck.result.toRadixString(16)}, isSuccess=${endAck.isSuccess}');

if (!endAck.isSuccess) {
  throw Exception('设备报告升级失败，错误码: 0x${endAck.result.toRadixString(16)} (${endAck.result})');
}
```

---

### Bug 3: ACK Offset 未验证 (关键问题)

**问题**: `waitForResponse` 只验证 `subCmd == 0x83`，不验证 ACK 的 offset 是否匹配发送的帧。

**症状**: 日志显示连续两个"收到"，没有中间的"发送"：
```
[10:07:41.836] 收到(HEX): FFD983... offset=1117000
[10:07:41.892] 收到(HEX): FFD983... offset=1117500
```

**原因**: 
1. 发送 Frame A (offset=1000)
2. 收到旧的 ACK (offset=500) ← 被误认为是 Frame A 的确认！
3. 立即发送 Frame B (offset=1500)
4. Frame A 的真正 ACK 到达时，Frame B 已经发送了

**修复**: 新增 `waitForDataFrameAck` 方法，同时验证 subCmd 和 offset：

```dart
// ble_service.dart
Future<UpgradeResponse?> waitForDataFrameAck(
  int expectedOffset, {
  Duration timeout = const Duration(seconds: 1),
}) async {
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

  // 匹配 subCmd AND offset
  if (parsed.subCmd == expectedSubCmd && parseOffset(data) == expectedOffset) {
    // 确认成功
  }
}
```

**OtaService 调用更新**:
```dart
// 使用 offset 验证确保是当前帧的 ACK
final frameAck = await _bleService.waitForDataFrameAck(
  offset,  // 传入当前帧的 offset
  timeout: const Duration(seconds: 1),
);
```

---

### Bug 4: OtaState.copyWith 无法清除固件

**问题**: `clearFirmware()` 调用后，固件文件没有被清除，无法更换文件。

**原因**: `copyWith` 使用 `??` 运算符，传入 `null` 时保留旧值：
```dart
firmware: firmware ?? this.firmware,  // null 被忽略！
```

**修复**: 添加 `clearFirmware` 标志：
```dart
OtaState copyWith({
  // ...
  bool clearFirmware = false,
}) {
  return OtaState(
    firmware: clearFirmware ? null : (firmware ?? this.firmware),
    firmwareName: clearFirmware ? null : (firmwareName ?? this.firmwareName),
  );
}

void clearFirmware() {
  state = state.copyWith(clearFirmware: true);  // 使用标志清除
}
```

---

## 📊 时序对比总结

### 修复前 (失败)
```
发送 Frame (offset=1114500)
发送 Finish Frame          ← 没等到 ACK 就发了！
收到 ACK (offset=1114000)  ← 旧帧的 ACK，已经太晚
收到 ACK (offset=1114500)  ← 正确的 ACK，但 Finish 已发送
收到 Finish ACK = 0x64     ← 设备校验失败！
```

### 修复后 (成功)
```
发送 Frame (offset=1114500)
收到 ACK (offset=1114500)  ← 等到正确 offset 的 ACK
发送 Finish Frame          ← 所有数据确认完毕后发送
收到 Finish ACK = 0x00     ← 成功！
```

---

## 📁 修改的文件

| 文件 | 修改内容 |
|------|---------|
| `lib/core/protocols/ota_protocol.dart` | 修复 0x85 result 解析位置 |
| `lib/core/services/ota_service.dart` | 验证 endAck.isSuccess, 使用 waitForDataFrameAck |
| `lib/core/services/ble_service.dart` | 新增 waitForDataFrameAck 方法 |
| `lib/core/protocols/ckcp_protocol.dart` | toHexString 去除空格 |
| `lib/presentation/providers/ota_provider.dart` | copyWith 添加 clearFirmware 标志 |
| `lib/core/services/log_service.dart` | 新增集中日志服务 |
| `lib/ui/widgets/debug_console.dart` | 新增调试控制台组件 |

---

## 💡 经验教训

1. **BLE 通信是异步的**: ACK 可能乱序到达，必须通过 offset 等字段验证对应关系
2. **日志对比是关键**: 将失败实现的日志格式与成功实现对齐，便于逐字节对比
3. **解析偏移要精确**: 二进制协议的字段位置必须严格匹配规范
4. **验证返回值**: 不能只检查"有响应"，还要检查"响应内容正确"
5. **Dart null 处理**: `copyWith` 模式需要特殊处理"显式设置为 null"的情况

---

## ✅ 验证结果

- OTA 升级成功，设备返回 `result=0x00`
- 日志显示正确的 发送→接收→发送→接收 序列
- 文件清除和更换功能正常
