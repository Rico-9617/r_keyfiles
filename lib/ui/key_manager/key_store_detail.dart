import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/controller/key_store_detail_controller.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';

class KeyStoreDetail extends StatelessWidget {
  final KdbxFileWrapper keyFile;

  const KeyStoreDetail({
    super.key,
    required this.keyFile,
  });

  @override
  Widget build(BuildContext context) {
    final detailController = KeyStoreDetailController();
    return ValueListenableBuilder(
        valueListenable: keyFile.encrypted,
        builder: (_, encrypted, __) => encrypted
            ? Stack(
                children: [
                  Text('data ${keyFile.title.value} ${keyFile.hashCode}'),
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
                              print(
                                  'testchange parse save $result ${keyFile.encrypted.value}');
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
            : Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              TextInputDialog(
                                onConfirm: (text) async {
                                  if (text.isEmpty) {
                                    EasyLoading.showToast('名称不能为空!');
                                    return false;
                                  }
                                  await detailController.modifyKeyStoreTitle(
                                      keyFile, text);
                                  return true;
                                },
                                title: '设置新名称',
                                content: keyFile.title.value,
                              ).show(context);
                            },
                            child: const Text('修改名称')),
                        OutlinedButton(
                            onPressed: () {
                              PasswordDialog(
                                title: '设置新密码',
                                onConfirm: (p) async {
                                  detailController.modifyKeyFilePassword(
                                      keyFile, p);
                                  return true;
                                },
                              ).show(context);
                            },
                            child: const Text('修改密码')),
                        if (!keyFile.externalStore)
                          OutlinedButton(onPressed: () {}, child: Text('导出')),
                        OutlinedButton(
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (_) => AlertDialog(
                                        content: const Text('是否删除该文件?'),
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
                      ],
                    )
                  ],
                ),
              ));
  }
}
