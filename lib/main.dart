import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';

import 'core/constants/app_info.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppInfo.init();

  runApp(
    const ProviderScope(
      child: CkcpLampApp(),
    ),
  );
}
