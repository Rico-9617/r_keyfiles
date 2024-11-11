import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:r_backup_tool/controller/key_store_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/ui/key_manager/group_detail.dart';
import 'package:r_backup_tool/utils/native_tool.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';

class KeyStoreDetail extends StatefulWidget {
  final KdbxFileWrapper keyFile;
  final KeyStoreDetailController detailController;

  const KeyStoreDetail({
    super.key,
    required this.keyFile,
  }) : detailController = const KeyStoreDetailController();

  @override
  State<KeyStoreDetail> createState() => _KeyStoreDetailState();
}

class _KeyStoreDetailState extends State<KeyStoreDetail> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: widget.keyFile.encrypted,
        builder: (_, encrypted, __) => encrypted
            ? Stack(
                children: [
                  Center(
                    child: OutlinedButton(
                        onPressed: () {
                          PasswordDialog(
                            onConfirm: (p) async {
                              LoadingDialog.show();
                              final result = await widget.detailController
                                  .decodeSavedFile(widget.keyFile, p)
                                  .handleError((e) async {
                                if (e is PathNotFoundException) {
                                  Toast.show('文件不存在！');
                                  await widget.detailController
                                      .deleteKeyStore(widget.keyFile);
                                  if (mounted) {
                                    Navigator.pop(context);
                                  }
                                } else {
                                  Toast.show(e.toString());
                                }
                              }).single;

                              LoadingDialog.dismiss();
                              return result;
                            },
                          ).show(context);
                        },
                        child: const Text(
                          '解锁',
                          style: AppTextStyle.textPrimary,
                        )),
                  )
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ValueListenableBuilder(
                      valueListenable: widget.keyFile.externalStore,
                      builder: (_, isExternal, child) {
                        return ValueListenableBuilder(
                          builder: (_, hasStoragePermission, __) {
                            return Wrap(spacing: 8, runSpacing: 4, children: [
                              if (isExternal && !hasStoragePermission)
                                TextButton(
                                    onPressed: () {
                                      PasswordDialog(
                                        onConfirm: (p) async {
                                          LoadingDialog.show();
                                          final result = await widget
                                              .detailController
                                              .importExternalKeyStore(
                                                  widget.keyFile, p);
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            Toast.show(result);
                                          }
                                          LoadingDialog.dismiss();
                                          return result == null;
                                        },
                                      ).show(context);
                                    },
                                    child: const Text(
                                      '导入以编辑',
                                      style: AppTextStyle.textButtonBlue,
                                    )),
                              if (isExternal && !hasStoragePermission)
                                TextButton(
                                    onPressed: () async {
                                      final result =
                                          await requestStoragePermission();
                                      if (result == false) {
                                        Toast.show('授权失败，请前往系统设置授权');
                                      }
                                    },
                                    child: const Text(
                                      '授权以编辑',
                                      style: AppTextStyle.textButtonBlue,
                                    )),
                              if (!isExternal || hasStoragePermission)
                                TextButton(
                                    onPressed: () {
                                      PasswordDialog(
                                        requireConfirm: true,
                                        title: '设置新密码',
                                        onConfirm: (p) async {
                                          LoadingDialog.show();
                                          final result = await widget
                                              .detailController
                                              .modifyKeyFilePassword(
                                                  widget.keyFile, p);
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            Toast.show(result);
                                          }
                                          LoadingDialog.dismiss();
                                          return result == null;
                                        },
                                      ).show(context);
                                    },
                                    child: const Text(
                                      '修改密码',
                                      style: AppTextStyle.textButtonBlue,
                                    )),
                              if (!isExternal)
                                TextButton(
                                    onPressed: () async {
                                      if (!hasStoragePermission) {
                                        final result =
                                            await requestStoragePermission();
                                        if (result == false) {
                                          Toast.show(
                                              '无外部存储权限，无法导出文件，请前往系统设置授权');
                                          return;
                                        }
                                      }
                                      try {
                                        final outputDir = Directory(p.join(
                                            await getDocumentDirectory(),
                                            'key_backup'));
                                        if (!await outputDir.exists()) {
                                          await outputDir.create();
                                        }
                                        final outputFile = File(p.join(
                                            outputDir.path,
                                            '${widget.keyFile.title}.kdbx'));
                                        await outputFile.writeAsBytes(
                                            await widget.keyFile.kdbxFile!
                                                .save(),
                                            flush: true);
                                      } catch (e) {
                                        logger.e(e);
                                      }
                                    },
                                    child: const Text(
                                      '导出',
                                      style: AppTextStyle.textButtonBlue,
                                    )),
                              child!,
                            ]);
                          },
                          valueListenable: hasExternalStoragePermission,
                        );
                      },
                      child: TextButton(
                          onPressed: () {
                            showCenterDialog(context,
                                builder: (_, __, ___, ____) =>
                                    TipsDialog(tips: '是否删除该文件?', actions: [
                                      TextButton(
                                        child: const Text('取消'),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text('确定'),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          LoadingDialog.show();
                                          await widget.detailController
                                              .deleteKeyStore(widget.keyFile);
                                          LoadingDialog.dismiss();
                                        },
                                      ),
                                    ]));
                          },
                          child: const Text(
                            '删除',
                            style: AppTextStyle.textButtonBlue,
                          )),
                    ),
                  ),
                  Expanded(
                    child: GroupDetail(
                      group: widget.keyFile.rootGroup!,
                      keyFile: widget.keyFile,
                      individual: false,
                    ),
                  ),
                ],
              ));
  }
}
