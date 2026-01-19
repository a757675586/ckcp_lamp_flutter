import 'dart:typed_data';

/// 十六进制工具类
class HexUtils {
  HexUtils._();

  /// 将字节数组转换为十六进制字符串
  /// @param data 字节数组
  /// @param separator 分隔符 (默认空格)
  static String bytesToHex(Uint8List data, {String separator = ' '}) {
    return data
        .map((b) => b.toRadixString(16).padLeft(2, '0').toUpperCase())
        .join(separator);
  }

  /// 将十六进制字符串转换为字节数组
  /// @param hex 十六进制字符串 (支持空格、< > 分隔)
  static Uint8List hexToBytes(String hex) {
    hex = hex
        .replaceAll(' ', '')
        .replaceAll('<', '')
        .replaceAll('>', '')
        .toUpperCase();
    
    if (hex.length % 2 != 0) {
      hex = '0$hex';
    }
    
    final bytes = <int>[];
    for (var i = 0; i < hex.length; i += 2) {
      bytes.add(int.parse(hex.substring(i, i + 2), radix: 16));
    }
    return Uint8List.fromList(bytes);
  }

  /// 格式化为带尖括号的十六进制字符串
  /// 例如: <D8 0A 80 ...>
  static String formatAsFrame(Uint8List data) {
    return '<${bytesToHex(data)}>';
  }

  /// 将整数转换为指定长度的小端序字节数组
  static Uint8List intToLittleEndian(int value, int length) {
    final bytes = <int>[];
    for (var i = 0; i < length; i++) {
      bytes.add((value >> (i * 8)) & 0xFF);
    }
    return Uint8List.fromList(bytes);
  }

  /// 将小端序字节数组转换为整数
  static int littleEndianToInt(Uint8List bytes, int offset, int length) {
    int value = 0;
    for (var i = 0; i < length && offset + i < bytes.length; i++) {
      value |= bytes[offset + i] << (i * 8);
    }
    return value;
  }
}
