import 'dart:core';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_file_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/repo/key_store_repo.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/android_file_picker_dialog.dart';
import 'package:r_backup_tool/ui/dialog/dialogs.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/widgets/content_scaffold.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';
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
            color: AppColors.titleBackground,
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextButton(
                        onPressed: () async {
                          showCenterDialog(context,
                              builder: (_, __, ___, ____) {
                            return TextInputDialog(
                                title: '输入文件名',
                                onConfirm: (text) async {
                                  Navigator.pop(context);
                                  PasswordDialog(
                                    useGenerator: true,
                                    onConfirm: (p) async {
                                      LoadingDialog.show();
                                      final result = await keyFileController
                                          .createNewKeyFile(text, p);
                                      LoadingDialog.dismiss();
                                      if (result != null) {
                                        Toast.show(result);
                                      }
                                      return result == null;
                                    },
                                  ).show(context);
                                  return false;
                                });
                          });
                        },
                        child: const Text(
                          "新建",
                          style: AppTextStyle.textWhite,
                        )),
                    TextButton(
                        onPressed: () async {
                          if (!hasExternalStoragePermission.value) {
                            showStoragePermissionDialog(context);
                            return;
                          }
                          final file = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (_) => const AndroidFilePickerDialog());
                          if (file != null) {
                            if (!mounted) return;
                            PasswordDialog(
                              onConfirm: (p) async {
                                LoadingDialog.show();
                                await keyFileController
                                    .openKdbxFile(file, p, externalFile: true)
                                    .handleError((e) {
                                  Toast.show(e.toString());
                                }).single;
                                LoadingDialog.dismiss();
                                return true;
                              },
                            ).show(context);
                          }
                        },
                        child: const Text(
                          "打开",
                          style: AppTextStyle.textWhite,
                        )),
                    TextButton(
                        onPressed: () async {
                          File? file;
                          if (hasExternalStoragePermission.value) {
                            file = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                builder: (_) =>
                                    const AndroidFilePickerDialog());
                          } else {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles();
                            if (result != null) {
                              file = File(result.files.single.path!);
                            }
                          }
                          if (file == null || !mounted) return;
                          PasswordDialog(
                            onConfirm: (p) async {
                              LoadingDialog.show();
                              await keyFileController
                                  .openKdbxFile(file!, p, import: true)
                                  .handleError((e) {
                                Toast.show(e.toString());
                              }).single;
                              LoadingDialog.dismiss();
                              return true;
                            },
                          ).show(context);
                        },
                        child: const Text(
                          "导入",
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
                                                final selected = file == e;
                                                return Container(
                                                  height: 41,
                                                  alignment: Alignment.center,
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 12),
                                                  color: selected
                                                      ? AppColors
                                                          .detailBackground
                                                      : Colors.transparent,
                                                  child: ValueListenableBuilder(
                                                    builder: (_, title, __) {
                                                      return AnimatedDefaultTextStyle(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    150),
                                                        style: TextStyle(
                                                            color: selected
                                                                ? AppColors
                                                                    .text0
                                                                : AppColors
                                                                    .textTitle
                                                                    .withAlpha(
                                                                        150),
                                                            fontSize: selected
                                                                ? 16
                                                                : 12),
                                                        child: Text(title),
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
