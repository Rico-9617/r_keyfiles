import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_windowmanager_plus/flutter_windowmanager_plus.dart';
import 'package:logger/logger.dart';
import 'package:r_backup_tool/styles.dart';
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
    statusBarBrightness: Brightness.light,
    statusBarIconBrightness: Brightness.light,
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
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await FlutterWindowManagerPlus.addFlags(
          FlutterWindowManagerPlus.FLAG_SECURE);
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      hasExternalStoragePermission.value = await checkStoragePermission();
      logger.d(
          'hasExternalStoragePermission ${hasExternalStoragePermission.value}');
    });
    return MaterialApp(
        navigatorObservers: [MainNavigatorObserver()],
        builder: (context, child) {
          return Material(
            child: Stack(
              children: [
                if (child != null) child,
                Toast.instance,
              ],
            ),
          );
        },
        home: LoadingDialog(child: MainPage()));
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

class MainNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);
    if (route.settings == _LoadingDialogState._instance?._routeSettings) {
      _LoadingDialogState._instance?._route = route;
    }
  }

  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class MainOverlay extends StatefulWidget {
  final Widget? child;

  const MainOverlay({super.key, this.child});

  @override
  State<MainOverlay> createState() => _MainOverlayState();
}

class _MainOverlayState extends State<MainOverlay> {
  @override
  Widget build(BuildContext context) {
    return Material(
      child: Stack(
        children: [
          if (widget.child != null) widget.child!,
          Toast.instance,
        ],
      ),
    );
  }
}

class LoadingDialog extends StatefulWidget {
  final Widget child;

  const LoadingDialog({super.key, required this.child});

  static void show() {
    _LoadingDialogState._instance?._show();
  }

  static void dismiss() {
    _LoadingDialogState._instance?._dismiss();
  }

  @override
  State<LoadingDialog> createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  static _LoadingDialogState? _instance;

  _LoadingDialogState() {
    _instance = this;
  }

  BuildContext? _context;

  bool _isShowing = false;

  final _routeSettings = const RouteSettings();

  Route? _route;

  void _show() {
    if (_context == null || _isShowing) return;
    _isShowing = true;
    showDialog(
        context: _context!,
        barrierColor: Colors.transparent,
        routeSettings: _routeSettings,
        builder: (context) {
          return PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, _) {
              if (didPop) return;
            },
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }).then((_) {
      _route = null;
      _isShowing = false;
    });
  }

  void _dismiss() {
    if (_context == null || !_isShowing) return;
    final navigator = Navigator.of(_context!);
    dismiss() async {
      while (_isShowing && _route == null) {
        await Future.delayed(const Duration(milliseconds: 20));
      }
      navigator.removeRoute(_route!);
      _isShowing = false;
    }

    dismiss();
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return widget.child;
  }
}

class Toast extends StatefulWidget {
  static final _key = GlobalKey<_ToastState>();

  const Toast._({super.key});

  static Toast? _instance;

  static Toast get instance {
    _instance ??= Toast._(key: _key);
    return _instance!;
  }

  static show(String? text) {
    if (text == null || text.isEmpty || _key.currentState == null) return;
    _key.currentState!._show(text);
  }

  @override
  State<Toast> createState() => _ToastState();
}

class _ToastState extends State<Toast> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  final toastText = ValueNotifier<String?>(null);

  @override
  void initState() {
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 200))
      ..addStatusListener((status) {
        if (status.isDismissed) {
          toastText.value = null;
        }
      });
    super.initState();
  }

  void _show(String? text) {
    final currentText = text;
    dismiss() async {
      await Future.delayed(const Duration(milliseconds: 3000));
      if (toastText.value != null && toastText.value != currentText) return;
      _animationController.reverse();
    }

    update() async {
      if (toastText.value != null) {
        await Future.delayed(const Duration(milliseconds: 1000));
      }
      toastText.value = text;
      _animationController.forward();
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
          final show = toastText != null && toastText.isNotEmpty;
          return show
              ? AnimatedBuilder(
                  animation: _animationController,
                  builder: (_, child) {
                    return Opacity(
                      opacity: _animationController.value,
                      child: child,
                    );
                  },
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      margin:
                          EdgeInsets.only(left: 16, right: 16, bottom: bottom),
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(color: Colors.black87),
                      child: Text(
                        toastText,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppTextStyle.text_normal),
                      ),
                    ),
                  ),
                )
              : const SizedBox();
        });
  }
}
