import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/remote/server/web_server.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';

class Remote extends StatelessWidget {
  final serverState = ValueNotifier(0);
  final webServer = WebServer();

  Remote({super.key});

  @override
  Widget build(BuildContext context) {
    Future startServer() async {
      final webServerResult = await webServer.startServer();
      if (webServerResult) {
        serverState.value = 2;
      } else {
        serverState.value = -1;
      }
    }

    back() {
      if (webServer.server != null) {
        showCenterDialog(context,
            builder: (_, __, ___, ____) => TipsDialog(
                  tips: '退出将中止远程服务！',
                  actions: [
                    TextButton(
                      child: const Text(
                        '取消',
                        style: AppTextStyle.textButtonBlue,
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text(
                        '退出',
                        style: AppTextStyle.textButtonBlue,
                      ),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        webServer.stopServer();
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                ));
      } else {
        Navigator.of(context).pop();
      }
    }

    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) {
          if (didPop) return;
          back();
        },
        child: Scaffold(
          backgroundColor: AppColors.detailBackground,
          body: Column(
            children: [
              Container(
                color: AppColors.titleBackground,
                padding:
                    EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                constraints: BoxConstraints(
                    minHeight: 40 + MediaQuery.of(context).padding.top),
                alignment: Alignment.centerLeft,
                child: Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          back();
                        },
                        icon: const Icon(
                          Icons.close,
                          color: AppColors.textTitle,
                        )),
                    const Expanded(
                      child: Text(
                        '远程访问',
                        style: AppTextStyle.textItemTitle,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              ValueListenableBuilder(
                  valueListenable: serverState,
                  builder: (_, state, __) {
                    logger.e('statechange $state ${StackTrace.current}');
                    return state == 0
                        ? Column(
                            children: [
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Text(
                                  '请将两台设备连接至同一 wifi 网络，或启用热点互连，然后点击启动',
                                  //，在另一台设备浏览器中输入以下地址，或扫码访问
                                  style: AppTextStyle.textPrimary,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TextButton(
                                child: const Text(
                                  '启动',
                                  style: TextStyle(
                                      color: AppColors.textClick, fontSize: 16),
                                ),
                                onPressed: () {
                                  serverState.value = 1;
                                  startServer();
                                },
                              )
                            ],
                          )
                        : state == 1
                            ? const Center(child: CircularProgressIndicator())
                            : state == -1
                                ? TextButton(
                                    child: const Text(
                                      '启动失败，请检查连接后点此重试！',
                                      style: TextStyle(
                                          color: Colors.redAccent,
                                          fontSize: 12),
                                    ),
                                    onPressed: () {
                                      serverState.value = 1;
                                      startServer();
                                    },
                                  )
                                : Column(
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 16.0),
                                        child: Text(
                                          '服务已启动，请在另一台设备浏览器中输入以下地址，或扫码访问',
                                          style: AppTextStyle.textPrimary,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Text(
                                        webServer.serverAddress,
                                        style: AppTextStyle.textPrimary
                                            .copyWith(fontSize: 16),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      QrImageView(
                                        data: webServer.serverAddress,
                                        version: QrVersions.auto,
                                        size: 200,
                                      )
                                    ],
                                  );
                  })
            ],
          ),
        ));
  }
}
