import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:path/path.dart' as p;
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_store_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/ui/key_manager/entry_detail_dialog.dart';
import 'package:r_backup_tool/utils/native_tool.dart';

class KeyStoreDetail extends StatelessWidget {
  final KdbxFileWrapper keyFile;
  final KeyStoreDetailController detailController;

  const KeyStoreDetail({
    super.key,
    required this.keyFile,
  }) : detailController = const KeyStoreDetailController();

  @override
  Widget build(BuildContext context) {
    logger.d('build key detail ${detailController.hashCode}');
    return ValueListenableBuilder(
        valueListenable: keyFile.encrypted,
        builder: (_, encrypted, __) => encrypted
            ? Stack(
                children: [
                  Center(
                    child: OutlinedButton(
                        onPressed: () {
                          PasswordDialog(
                            onConfirm: (p) async {
                              EasyLoading.show();
                              final result = await detailController
                                  .decodeSavedFile(keyFile, p)
                                  .handleError((e) {
                                EasyLoading.showToast(e.toString());
                              }).single;
                              if (result) {
                                EasyLoading.dismiss();
                              }
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
                      valueListenable: keyFile.externalStore,
                      builder: (_, isExternal, child) {
                        return ValueListenableBuilder(
                          builder: (_, hasStoragePermission, __) {
                            return Wrap(spacing: 8, runSpacing: 4, children: [
                              if (isExternal && !hasStoragePermission)
                                OutlinedButton(
                                    onPressed: () {
                                      PasswordDialog(
                                        onConfirm: (p) async {
                                          EasyLoading.show();
                                          final result = await detailController
                                              .importExternalKeyStore(
                                                  keyFile, p);
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            EasyLoading.showToast(result);
                                          } else {
                                            EasyLoading.dismiss();
                                          }
                                          return result == null;
                                        },
                                      ).show(context);
                                    },
                                    child: const Text('导入以编辑')),
                              if (isExternal && !hasStoragePermission)
                                OutlinedButton(
                                    onPressed: () async {
                                      final result =
                                          await requestStoragePermission();
                                      if (result == false) {
                                        EasyLoading.showToast('授权失败，请前往系统设置授权');
                                      }
                                    },
                                    child: const Text('授权以编辑')),
                              if (!isExternal || hasStoragePermission)
                                OutlinedButton(
                                    onPressed: () {
                                      TextInputDialog.show(
                                          context,
                                          (_) => TextInputDialog(
                                                onConfirm: (text) async {
                                                  if (text.isEmpty) {
                                                    EasyLoading.showToast(
                                                        '名称不能为空!');
                                                    return false;
                                                  }
                                                  EasyLoading.show();
                                                  final result =
                                                      await detailController
                                                          .modifyKeyStoreTitle(
                                                              keyFile, text);
                                                  if (result != null &&
                                                      result.isNotEmpty) {
                                                    EasyLoading.showToast(
                                                        result);
                                                  } else {
                                                    EasyLoading.dismiss();
                                                  }
                                                  return result == null;
                                                },
                                                title: '设置新名称',
                                                content: keyFile.title.value,
                                              ));
                                    },
                                    child: const Text('修改名称')),
                              if (!isExternal || hasStoragePermission)
                                OutlinedButton(
                                    onPressed: () {
                                      PasswordDialog(
                                        requireConfirm: true,
                                        title: '设置新密码',
                                        onConfirm: (p) async {
                                          EasyLoading.show();
                                          final result = await detailController
                                              .modifyKeyFilePassword(
                                                  keyFile, p);
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            EasyLoading.showToast(result);
                                          } else {
                                            EasyLoading.dismiss();
                                          }
                                          return result == null;
                                        },
                                      ).show(context);
                                    },
                                    child: const Text('修改密码')),
                              if (!isExternal)
                                OutlinedButton(
                                    onPressed: () async {
                                      if (!hasStoragePermission) {
                                        final result =
                                            await requestStoragePermission();
                                        if (result == false) {
                                          EasyLoading.showToast(
                                              '无外部存储权限，无法导出文件，请前往系统设置授权');
                                          return;
                                        }
                                      }
                                      logger.d(await getDocumentDirectory());
                                      try {
                                        final outputDir = Directory(p.join(
                                            await getDocumentDirectory(),
                                            'key_backup'));
                                        if (!await outputDir.exists()) {
                                          await outputDir.create();
                                        }
                                        final outputFile = File(p.join(
                                            outputDir.path,
                                            '${keyFile.title}.kdbx'));
                                        await outputFile.writeAsBytes(
                                            await keyFile.kdbxFile!.save());
                                      } catch (e) {
                                        logger.e(e);
                                      }
                                    },
                                    child: const Text('导出')),
                              child!,
                              if (!isExternal || hasStoragePermission)
                                OutlinedButton(
                                    onPressed: () {},
                                    child: const Text('添加密钥')),
                            ]);
                          },
                          valueListenable: hasExternalStoragePermission,
                        );
                      },
                      child: OutlinedButton(
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: const Text('是否删除该文件?'),
                                      actions: [
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
                                            EasyLoading.show();
                                            await detailController
                                                .deleteKeyStore(keyFile);
                                            EasyLoading.dismiss();
                                          },
                                        ),
                                      ],
                                    ));
                          },
                          child: const Text('删除')),
                    ),
                  ),
                  Expanded(
                    child: Stack(
                      children: [
                        ValueListenableBuilder(
                            valueListenable: keyFile.entities,
                            builder: (_, entities, __) {
                              return ListView.builder(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10),
                                itemCount: entities.length,
                                itemBuilder: (context, index) {
                                  final item = entities[index];
                                  final heroTag = 'key_title_$index';
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) {
                                        return EntryDetailDialog(
                                            keyFile: keyFile,
                                            entry: item,
                                            heroTag: heroTag);
                                      }));
                                      // showDialog(
                                      //     context: context,
                                      //     useSafeArea: false,
                                      //     builder: (context) =>
                                      //         Dialog.fullscreen(
                                      //           backgroundColor:
                                      //               Colors.transparent,
                                      //           child: EntryDetailDialog(
                                      //               keyFile: keyFile,
                                      //               entry: item,
                                      //               heroTag: heroTag),
                                      //         ));
                                    },
                                    child: Hero(
                                      tag: 'heroTag',
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 4),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        height: 50,
                                        alignment: Alignment.centerLeft,
                                        decoration: const BoxDecoration(
                                          color: AppColors.entryBackground,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(0.0, 1.0),
                                                spreadRadius: 1,
                                                blurRadius: 2)
                                          ],
                                        ),
                                        child: ValueListenableBuilder(
                                            valueListenable: item.title,
                                            builder: (_, title, __) {
                                              return Text(
                                                title?.getText() ?? 'unnamed',
                                                style: AppTextStyle
                                                    .textEntityTitle,
                                              );
                                            }),
                                      ),
                                    ),
                                  );
                                },
                              );
                            }),
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20, // Adjust height as needed
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.detailBackground,
                                  AppColors.detailBackground.withAlpha(0)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 20, // Adjust height as needed
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.detailBackground,
                                  AppColors.detailBackground.withAlpha(0)
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                ],
              ));
  }
}
