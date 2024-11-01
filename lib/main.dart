import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:logger/logger.dart';
import 'package:r_backup_tool/ui/main_page.dart';
import 'package:r_backup_tool/utils/native_tool.dart';

final logger = Logger(
  printer: PrettyPrinter(),
  output: ConsoleOutput(),
);

final hasExternalStoragePermission = ValueNotifier(false);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
  ));

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  runApp(const MyApp());

  EasyLoading.instance
    ..maskType = EasyLoadingMaskType.custom
    ..maskColor = Colors.transparent
    ..indicatorType = EasyLoadingIndicatorType.fadingGrid;
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      hasExternalStoragePermission.value = await checkStoragePermission();
      logger.d(
          'hasExternalStoragePermission ${hasExternalStoragePermission.value}');
    });
    return MaterialApp(
      builder: EasyLoading.init(),
      home: MainPage(),
    );
  }
}

class ConsoleOutput extends LogOutput {
  @override
  void output(OutputEvent event) {
    if (!kDebugMode) return;
    for (var line in event.lines) {
      print(line);
    }
  }
}
