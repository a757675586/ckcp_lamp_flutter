import 'dart:convert';
import 'dart:typed_data';

/// OTA 升级协议
/// 参考 WebOTA 项目的 OtaService.js 和 Protocol.js
class OtaProtocol {
  OtaProtocol._();

  /// 生成升级请求帧
  /// 格式: [0xFF, 0xD8, 0x80, filename(32B), fileSize(8B), major(2B), minor(2B), build(2B)]
  /// 注意 OTA 协议是纯二进制的
  static Uint8List generateUpgradeRequestFrame(
    Uint8List fileData, {
    String filename = 'AMBL3.bin',
    int major = 1,
    int minor = 0,
    int build = 0,
  }) {
    final fileSize = fileData.length;

    // 头部
    final frame = <int>[0xFF, 0xD8, 0x80];

    // 文件名 (固定 32 字节)
    final nameBytes = utf8.encode(filename);
    frame.addAll(nameBytes);
    frame.addAll(List.filled(32 - nameBytes.length, 0));

    // 文件大小 (8 bytes, 小端序)
    for (var i = 0; i < 8; i++) {
      frame.add((fileSize >> (i * 8)) & 0xFF);
    }

    // 版本信息 (各 2 bytes, 小端序)
    frame.add(major & 0xFF);
    frame.add((major >> 8) & 0xFF);
    frame.add(minor & 0xFF);
    frame.add((minor >> 8) & 0xFF);
    frame.add(build & 0xFF);
    frame.add((build >> 8) & 0xFF);

    return Uint8List.fromList(frame);
  }

  /// 生成数据帧
  /// 格式: [0xFF, 0xD8, 0x82, offset(4B), length(2B), data...]
  static Uint8List generateDataFrame(
    Uint8List fileData,
    int offset,
    int count,
  ) {
    final frame = <int>[0xFF, 0xD8, 0x82];

    // 偏移 (4 bytes, 小端序)
    frame.add(offset & 0xFF);
    frame.add((offset >> 8) & 0xFF);
    frame.add((offset >> 16) & 0xFF);
    frame.add((offset >> 24) & 0xFF);

    // 长度 (2 bytes, 小端序)
    frame.add(count & 0xFF);
    frame.add((count >> 8) & 0xFF);

    // 数据
    final end = (offset + count).clamp(0, fileData.length);
    frame.addAll(fileData.sublist(offset, end));

    return Uint8List.fromList(frame);
  }

  /// 生成结束帧
  /// 格式: [0xFF, 0xD8, 0x84]
  static Uint8List generateFinishFrame() {
    return Uint8List.fromList([0xFF, 0xD8, 0x84]);
  }
}

/// OTA 数据帧解析器
class OtaParser {
  OtaParser._();

  /// 解析 OTA 升级响应 (二进制格式)
  static UpgradeResponse? parseFrame(Uint8List data) {
    if (data.isEmpty) return null;

    int startIdx = 0;
    if (data[0] == 0xFF) {
      if (data.length < 2) return null;
      startIdx = 1;
    }

    if (data[startIdx] != 0xD9) return null;
    if (data.length < startIdx + 2) return null;

    final subCmd = data[startIdx + 1];
    int result = 0;

    // 根据子命令解析
    if (subCmd == 0x81) {
      // 升级请求响应
      result = data.length > startIdx + 2 ? data[startIdx + 2] : 0;
    } else if (subCmd == 0x83) {
      // 数据帧响应
      // 格式: [FF] D9 83 OFFSET(4B) RESULT
      if (data.length >= startIdx + 7) {
        result = data[startIdx + 6];
      } else if (data.length > startIdx + 2) {
        // 短响应 fallback (参考 WebOTA)
        result = data[startIdx + 2];
      }
    } else if (subCmd == 0x85) {
      // 结束帧响应
      // 格式: [FF] D9 85 OFFSET(4B) RESULT(1B)
      if (data.length >= startIdx + 7) {
        result = data[startIdx + 6];
      } else if (data.length > startIdx + 2) {
        // 短响应 fallback
        result = data[startIdx + 2];
      }
    } else if (subCmd == 0x86) {
      // 升级成功
      // 0x86 没有结果字节，本身就是成功
      result = 1;
    }

    return UpgradeResponse(
      subCmd: subCmd,
      result: result,
      // Spec: 0x00=Success, 0x01=Success(Backup), 0xFF=Fail
      // 0x86 is explicit Success SubCmd
      isSuccess: (result == 0x00 || result == 0x01) || (subCmd == 0x86),
    );
  }
}

/// 升级响应数据类
class UpgradeResponse {
  final int subCmd;
  final int result;
  final bool isSuccess;

  const UpgradeResponse({
    required this.subCmd,
    required this.result,
    required this.isSuccess,
  });

  /// 是否失败
  bool get isFailed => result == 0xFF;

  /// 是否被取消
  bool get isCancelled => subCmd == 0x89;
}
