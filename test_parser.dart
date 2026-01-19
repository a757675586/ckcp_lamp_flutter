
import 'dart:convert';
import 'dart:typed_data';

// Copy of the ProtocolParser logic from lib/core/protocols/ota_protocol.dart
class ProtocolParser {
  static DeviceInfoResponse? parseDeviceInfoResponse(Uint8List rawData) {
    try {
      final text = utf8.decode(rawData);
      print('Parsing text: $text');
      
      if (!text.contains('<09')) {
        print('Error: Does not contain <09');
        return null;
      }
      
      final startIndex = text.indexOf('<09');
      final endIndex = text.indexOf('>', startIndex);
      if (endIndex == -1) {
        print('Error: > not found');
        return null;
      }
      
      final content = text.substring(startIndex + 1, endIndex); 
      // content should be: 091A0556312E323008333030382D434F4D0A32333033430342D303130 (for the user case)
      print('Content: $content');

      if (content.length < 4) return null;
      
      final totalLenHex = content.substring(2, 4); // "1A"
      final totalLen = int.parse(totalLenHex, radix: 16); // 26
      print('Total Len: $totalLen ($totalLenHex)');
      
      // Expected length: 4 (09+1A) + 26*2 = 56 chars
      if (content.length < 4 + totalLen * 2) {
        print('Error: Length mismatch. Expected ${4 + totalLen * 2}, got ${content.length}');
        return null;
      }
      
      int index = 4;
      
      String readNextString() {
        if (index + 2 > content.length) {
            print('Read fail: index+2 > length');
            return '';
        }
        final lenStr = content.substring(index, index + 2);
        final len = int.parse(lenStr, radix: 16);
        index += 2;
        print('Field Len: $len ($lenStr)');

        if (index + len * 2 > content.length) {
            print('Read fail: body > length');
            return '';
        }
        final hex = content.substring(index, index + len * 2);
        index += len * 2;
        final val = _hexToString(hex);
        print('Field Value: $val ($hex)');
        return val;
      }
      
      final hwVersion = readNextString();
      final carModel = readNextString(); 
      final swVersion = readNextString();

      return DeviceInfoResponse(
        hwVersion: hwVersion,
        swVersion: swVersion,
        carModel: carModel, 
        funcCode: 0,
      );
    } catch (e) {
      print('Exception: $e');
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
  
  @override
  String toString() => 'HW: $hwVersion, Model: $carModel, SW: $swVersion';
}

void main() {
  // Test case from user screenshot
  // <091A0556312E323008333030382D434F4D0A32333033430342D303130>
  // Note: I am copying the string I reconstructed. 
  // Middle Column Image: <091A0556312E323008333030382D434F4D0A3233303430342D303130> (This was my correction based on line breaks)
  // Let's try the one from the visual text: "32 33 30 34 30 34 2D 30 31 30" -> 230404-010
  
  final inputString = '<091A0556312E323008333030382D434F4D0A3233303430342D303130>';
  final bytes = Uint8List.fromList(utf8.encode(inputString));
  
  print('Testing: $inputString');
  final result = ProtocolParser.parseDeviceInfoResponse(bytes);
  
  if (result != null) {
      print('SUCCESS: $result');
  } else {
      print('FAILED');
  }
}
