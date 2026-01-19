class CanLogEntry {
  final int sequence;
  final String id;
  final int dlc;
  final String data;
  final DateTime timestamp;
  final bool isCan; // true = CAN, false = LIN

  const CanLogEntry({
    required this.sequence,
    required this.id,
    required this.dlc,
    required this.data,
    required this.timestamp,
    this.isCan = true, // Default to CAN for now
  });

  /// 格式化为保存文件的一行
  /// 参考格式: 序号,帧ID(Hex),长度,数据(Hex),时间标识,方向,帧类型,帧格式,CAN类型,通道号,设备号
  String toCsvLine() {
    final timeStr =
        (timestamp.millisecondsSinceEpoch / 1000.0).toStringAsFixed(6);

    // 判断标准帧/扩展帧
    String frameFormat = "标准帧";
    try {
      final idVal = int.parse(id, radix: 16);
      if (idVal > 0x7FF) {
        frameFormat = "扩展帧";
      }
    } catch (_) {}

    return '$sequence,0x$id,$dlc,$data,$timeStr,接收,$frameFormat,数据帧,${isCan ? "CAN" : "LIN"},CAN1,0x00000000';
  }
}
