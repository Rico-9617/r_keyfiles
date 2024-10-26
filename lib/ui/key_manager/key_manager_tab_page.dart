import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/widgets/buttons.dart';
import 'package:r_backup_tool/widgets/content_scaffold.dart';
import 'package:r_backup_tool/widgets/scrollable_tab_bar.dart';

class KeyManagerTabPage extends StatefulWidget {
  const KeyManagerTabPage({super.key});

  @override
  State<KeyManagerTabPage> createState() => _KeyManagerTabPageState();
}

class _KeyManagerTabPageState extends State<KeyManagerTabPage>
    with SingleTickerProviderStateMixin {
  final keyStoreRepo = KeyStoreRepo();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await compute(keyStoreRepo.loadSavedFiles(), null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentScaffold(child: (statusBarHeight, _) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: statusBarHeight),
            height: statusBarHeight + 50,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClickableWidget(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () async {},
                    child: const Text(
                      "新建",
                      style: AppTextStyle.textButtonNormal,
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
                            final result = await keyStoreRepo
                                .parseKdbxFile(file, p)
                                .handleError((e) {
                              EasyLoading.showToast(e.toString());
                            }).single;
                            if (result) {
                              EasyLoading.dismiss();
                            }
                            print('restparse result $result');
                            return result;
                          },
                        ).show(context);
                      } else {
                        EasyLoading.showToast('文件解析失败！');
                      }
                    },
                    child: const Text(
                      "打开",
                      style: AppTextStyle.textButtonNormal,
                    ))
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: keyStoreRepo.savedKeyFiles,
              builder: (_, files, __) {
                return files.isEmpty
                    ? const SizedBox()
                    : Container(
                        color: Colors.white70,
                        height: 40,
                        child: ScrollableTabBar(
                            children: files
                                .map((e) => GestureDetector(
                                      onTap: () {
                                        keyStoreRepo.currentFile.value = e;
                                      },
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 12),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 4),
                                        child: ValueListenableBuilder(
                                          builder: (_, file, __) {
                                            return ValueListenableBuilder(
                                              builder: (_, title, __) {
                                                return Text(
                                                  title,
                                                  style: file == e
                                                      ? AppTextStyle.textPrimary
                                                      : AppTextStyle
                                                          .textDisable,
                                                );
                                              },
                                              valueListenable: e.title,
                                            );
                                          },
                                          valueListenable:
                                              keyStoreRepo.currentFile,
                                        ),
                                      ),
                                    ))
                                .toList()));
              }),
          Expanded(
              child: Container(
            width: double.infinity,
            color: Colors.cyanAccent,
            child: ValueListenableBuilder(
              builder: (_, file, __) {
                print('testchange page ${file?.title}');
                return file == null
                    ? const SizedBox()
                    : Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          ValueListenableBuilder(
                            builder: (_, title, __) {
                              return Text(
                                title,
                                style: AppTextStyle.textPrimary,
                              );
                            },
                            valueListenable: file.title,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                file.title.value = 'changed title hahaha';
                              },
                              child: const Text('change')),
                        ],
                      );
              },
              valueListenable: keyStoreRepo.currentFile,
            ),
          ))
        ],
      );
    });
  }

  void _loop(List<KdbxEntry> entries) {
    for (final entry in entries) {
      print('entry label: ${entry.label}');
      print('entry customData: ${entry.customData}');
      for (final se in entry.stringEntries) {
        print('entry string: ${se.key}  = ${se.value}');
      }
      for (final ce in entry.customData.entries) {
        print('entry custom entry: ${ce.key}  = ${ce.value}');
      }
    }
  }
}
