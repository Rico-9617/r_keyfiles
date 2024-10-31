import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';

class EntryDetailDialog extends StatelessWidget {
  final KdbxFileWrapper keyFile;
  final KdbxEntryWrapper entry;
  final String heroTag;

  const EntryDetailDialog(
      {super.key,
      required this.keyFile,
      required this.entry,
      required this.heroTag});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Container(
        color: AppColors.entryBackground,
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).padding.top,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              height: 40,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  ValueListenableBuilder(
                      valueListenable: entry.title,
                      builder: (_, title, __) {
                        return Text(
                          title?.getText() ?? 'unnamed',
                          style: AppTextStyle.textEntityTitle,
                        );
                      }),
                  const Spacer(),
                  if (!keyFile.externalStore.value ||
                      hasExternalStoragePermission.value)
                    TextButton(
                      child: const Text('修改名称'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  if (!keyFile.externalStore.value ||
                      hasExternalStoragePermission.value)
                    TextButton(
                      child: const Text('删除'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                ],
              ),
            ),
            const Text(
              '用户名',
              style: AppTextStyle.textEntityItemTitle,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '密码',
              style: AppTextStyle.textEntityItemTitle,
            ),
            const SizedBox(
              height: 4,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              'URL',
              style: AppTextStyle.textEntityItemTitle,
            ),
            const SizedBox(
              height: 4,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '备注',
              style: AppTextStyle.textEntityItemTitle,
            ),
            const SizedBox(
              height: 4,
            ),
            SizedBox(
              height: MediaQuery.of(context).padding.bottom,
            ),
          ],
        ),
      ),
    );
  }
}
