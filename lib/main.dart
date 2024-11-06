import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      builder: (context, widget) {
        logger.d('testpopmain mainbuilder $widget ');
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, _) {
            logger.d('testpopmain $didPop');
          },
          child: Stack(
            children: [
              Material(child: widget!),
              LoadingDialog.instance,
              Toast.instance,
            ],
          ),
        );
      },
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

class LoadingDialog extends StatelessWidget {
  LoadingDialog._();

  final isShowing = ValueNotifier(false);

  static LoadingDialog? _instance;

  static LoadingDialog get instance {
    _instance ??= LoadingDialog._();
    return _instance!;
  }

  static void show() {
    instance.isShowing.value = true;
  }

  static void dismiss() {
    instance.isShowing.value = false;
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isShowing,
        builder: (context, isShowing, child) {
          return isShowing
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  child: Container(
                    color: Colors.transparent,
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
                )
              : const SizedBox();
        });
  }
}

class Toast extends StatelessWidget {
  Toast._();

  final toastText = ValueNotifier<String?>(null);

  static Toast? _instance;

  static Toast get instance {
    _instance ??= Toast._();
    return _instance!;
  }

  static show(String? text) {
    if (text == null || text.isEmpty) return;
    final currentText = text;
    dismiss() async {
      await Future.delayed(const Duration(milliseconds: 3000));
      if (instance.toastText.value != null &&
          instance.toastText.value != currentText) return;
      instance.toastText.value = null;
    }

    update() async {
      if (instance.toastText.value != null) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      instance.toastText.value = text;
      dismiss();
    }

    update();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: toastText,
        builder: (_, toastText, __) {
          final bottom = MediaQuery.of(context).padding.bottom + 150;
          return toastText == null || toastText.isEmpty
              ? const SizedBox()
              : Align(
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    margin:
                        EdgeInsets.only(left: 16, right: 16, bottom: bottom),
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(color: Colors.black87),
                    child: Text(
                      toastText,
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
        });
  }
}
