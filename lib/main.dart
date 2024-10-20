import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:async';

import 'package:r_backup_tool/ui/main_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);

  // Enable immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MyApp());

  EasyLoading.instance
      .maskType = EasyLoadingMaskType.none;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
