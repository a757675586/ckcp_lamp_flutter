// Test script to analyze exact protocol behavior
// Run with: dart run debug_protocol.dart

import 'dart:convert';

void main() {
  // The actual data frame the device sends (this is the STRING content inside the frame)
  // Format: <091A0556312E3208333030382D434F4D0A3233303430342D303130>
  // This is the TEXT as received over BLE after TextDecoder/utf8.decode
  
  final text = "<091A0556312E3208333030382D434F4D0A3233303430342D303130>";
  
  print('=== Input Text ===');
  print('Text: "$text"');
  print('Text Length: ${text.length}');
  
  // Check for <09
  print('\n=== Pattern Check ===');
  print('Contains <09: ${text.contains('<09')}');
  print('Starts with <09: ${text.startsWith('<09')}');
  
  // WebOTA-style parsing
  print('\n=== WebOTA-Style Parsing ===');
  if (text.startsWith('<09')) {
    // Remove < and >
    final inner = text.substring(1, text.length - 1);
    print('Inner content: "$inner"');
    print('Inner length: ${inner.length} chars');
    
    // Parse CMD
    final cmd = inner.substring(0, 2);
    print('CMD: $cmd');
    
    // Parse length (in bytes, but represented as 2 hex chars)
    final lenHex = inner.substring(2, 4);
    final dataLen = int.parse(lenHex, radix: 16);
    print('Data Length hex: $lenHex = $dataLen bytes');
    print('Expected inner content length: ${4 + dataLen * 2} (CMD + LEN + DATA*2)');
    print('Actual inner content length: ${inner.length}');
    
    // Parse HW version
    int idx = 4;
    final hwLenHex = inner.substring(idx, idx + 2);
    final hwLen = int.parse(hwLenHex, radix: 16);
    idx += 2;
    print('\nHW Length hex: $hwLenHex = $hwLen bytes');
    
    final hwHex = inner.substring(idx, idx + hwLen * 2);
    final hwVersion = hexToString(hwHex);
    idx += hwLen * 2;
    print('HW Hex: $hwHex');
    print('HW Version: "$hwVersion"');
    
    // Parse Model
    final modelLenHex = inner.substring(idx, idx + 2);
    final modelLen = int.parse(modelLenHex, radix: 16);
    idx += 2;
    print('\nModel Length hex: $modelLenHex = $modelLen bytes');
    
    final modelHex = inner.substring(idx, idx + modelLen * 2);
    final carModel = hexToString(modelHex);
    idx += modelLen * 2;
    print('Model Hex: $modelHex');
    print('Car Model: "$carModel"');
    
    // Parse SW version
    final swLenHex = inner.substring(idx, idx + 2);
    final swLen = int.parse(swLenHex, radix: 16);
    idx += 2;
    print('\nSW Length hex: $swLenHex = $swLen bytes');
    
    final swHex = inner.substring(idx, idx + swLen * 2);
    final swVersion = hexToString(swHex);
    print('SW Hex: $swHex');
    print('SW Version: "$swVersion"');
    
    print('\n=== FINAL RESULT ===');
    print('Hardware Version: $hwVersion');
    print('Car Model: $carModel');
    print('Software Version: $swVersion');
  } else {
    print('ERROR: Text does not start with <09');
  }
}

String hexToString(String hex) {
  final buffer = StringBuffer();
  for (var i = 0; i < hex.length; i += 2) {
    final charCode = int.parse(hex.substring(i, i + 2), radix: 16);
    if (charCode != 0) {
      buffer.writeCharCode(charCode);
    }
  }
  return buffer.toString();
}
