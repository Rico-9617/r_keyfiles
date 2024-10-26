import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/ui/main_page.dart';

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

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      home: Directionality(
        textDirection: TextDirection.ltr,
        child: Stack(
          children: [
            Positioned.fill(child: Navigator(
              onGenerateRoute: (settings) {
                return MaterialPageRoute(builder: (_) {
                  return switch (settings.name) {
                    '/' => MainPage(),
                    _ => const SizedBox.shrink(),
                  };
                });
              },
            ))
          ],
        ),
      ),
    );
  }
}
