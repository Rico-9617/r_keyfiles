import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_file_controller.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/widgets/buttons.dart';
import 'package:r_backup_tool/widgets/content_scaffold.dart';
import 'package:r_backup_tool/widgets/scrollable_tab_bar.dart';

import 'key_store_detail.dart';

class KeyManagerTabPage extends StatefulWidget {
  const KeyManagerTabPage({super.key});

  @override
  State<KeyManagerTabPage> createState() => _KeyManagerTabPageState();
}

class _KeyManagerTabPageState extends State<KeyManagerTabPage>
    with SingleTickerProviderStateMixin {
  final keyFileController = KeyFileController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await KeyStoreRepo.instance.loadSavedFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentScaffold(child: (statusBarHeight, _) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: statusBarHeight),
            constraints: BoxConstraints(minHeight: statusBarHeight + 50),
            color: Colors.cyan,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClickableWidget(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        onTap: () async {},
                        child: const Text(
                          "新建",
                          style: AppTextStyle.textWhite,
                        )),
                    ClickableWidget(
                        height: 50,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        onTap: () async {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();

                          if (result != null) {
                            final file = File(result.files.single.path!);
                            if (!(await file.exists()) || !mounted) return;
                            PasswordDialog(
                              onConfirm: (p) async {
                                EasyLoading.show();
                                final result = await keyFileController
                                    .parseKdbxFile(file, p, externalFile: true)
                                    .handleError((e) {
                                  EasyLoading.showToast(e.toString());
                                }).single;
                                if (result) {
                                  EasyLoading.dismiss();
                                }
                                return result;
                              },
                            ).show(context);
                          } else {
                            EasyLoading.showToast('文件解析失败！');
                          }
                        },
                        child: const Text(
                          "打开",
                          style: AppTextStyle.textWhite,
                        ))
                  ],
                ),
                ValueListenableBuilder(
                    valueListenable: KeyStoreRepo.instance.savedKeyFiles,
                    builder: (_, files, __) {
                      return files.isEmpty
                          ? const SizedBox()
                          : SizedBox(
                              width: double.infinity,
                              child: ScrollableTabBar(
                                  children: files
                                      .map((e) => GestureDetector(
                                            onTap: () {
                                              KeyStoreRepo.instance.currentFile
                                                  .value = e;
                                            },
                                            child: ValueListenableBuilder(
                                              builder: (_, file, __) {
                                                return Container(
                                                  height: 41,
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  color: file == e
                                                      ? AppColors
                                                          .detailBackground
                                                      : Colors.transparent,
                                                  child: ValueListenableBuilder(
                                                    builder: (_, title, __) {
                                                      return Text(
                                                        title,
                                                        style: file == e
                                                            ? AppTextStyle
                                                                .textPrimary
                                                                .copyWith(
                                                                    fontSize:
                                                                        16)
                                                            : const TextStyle(
                                                                color: Colors
                                                                    .black54),
                                                      );
                                                    },
                                                    valueListenable: e.title,
                                                  ),
                                                );
                                              },
                                              valueListenable: KeyStoreRepo
                                                  .instance.currentFile,
                                            ),
                                          ))
                                      .toList()),
                            );
                    }),
              ],
            ),
          ),
          Expanded(
              child: Container(
            width: double.infinity,
            color: AppColors.detailBackground,
            child: ValueListenableBuilder(
              builder: (_, file, __) {
                return file == null
                    ? const SizedBox()
                    : KeyStoreDetail(
                        keyFile: file,
                      );
              },
              valueListenable: KeyStoreRepo.instance.currentFile,
            ),
          ))
        ],
      );
    });
  }
}
