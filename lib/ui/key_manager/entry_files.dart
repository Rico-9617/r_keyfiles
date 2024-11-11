import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/utils/native_tool.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';

class EntryFiles extends StatelessWidget {
  final KeyEntryDetailController controller;

  const EntryFiles({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            child: const Text('添加'),
            onPressed: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles();
              if (result != null) {
                controller.addBinary(result.files.single.path!);
              }
            },
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              ValueListenableBuilder(
                valueListenable: controller.binaryData,
                builder: (_, binaries, __) {
                  return ListView.builder(
                      itemCount: binaries.length,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      itemBuilder: (_, index) {
                        final item = binaries[index];
                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.only(
                                left: 16,
                                top: 12,
                                bottom: 12,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      child: Text(
                                    item,
                                    style: AppTextStyle.textPrimary,
                                  )),
                                  TextButton(
                                      onPressed: () async {
                                        if (!hasExternalStoragePermission
                                            .value) {
                                          final result =
                                              await requestStoragePermission();
                                          if (result == false) {
                                            Toast.show(
                                                '无外部存储权限，无法导出文件，请前往系统设置授权');
                                            return;
                                          }
                                          LoadingDialog.show();
                                          final saveResult =
                                              await controller.saveFile(item);
                                          LoadingDialog.dismiss();
                                          Toast.show(saveResult);
                                        }
                                      },
                                      child: const Text(
                                        '导出',
                                        style: AppTextStyle.textButtonBlue,
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        showCenterDialog(context,
                                            builder: (_, __, ___, ____) =>
                                                TipsDialog(
                                                    tips: '是否删除该文件?',
                                                    actions: [
                                                      TextButton(
                                                        child: const Text('取消'),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      TextButton(
                                                        child: const Text('确定'),
                                                        onPressed: () async {
                                                          Navigator.of(context)
                                                              .pop();
                                                          controller
                                                              .deleteBinary(
                                                                  item);
                                                        },
                                                      ),
                                                    ]));
                                      },
                                      child: const Text(
                                        '删除',
                                        style: AppTextStyle.textButtonBlue,
                                      )),
                                ],
                              ),
                            ),
                            const Divider(),
                          ],
                        );
                      });
                },
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 20, // Adjust height as needed
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.entryBackground,
                        AppColors.entryBackground.withAlpha(0)
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
                        AppColors.entryBackground,
                        AppColors.entryBackground.withAlpha(0)
                      ],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
