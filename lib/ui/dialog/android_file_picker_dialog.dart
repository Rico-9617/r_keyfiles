import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/android_file_picker_controller.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/widgets/common.dart';
import 'package:r_backup_tool/widgets/scrollable_tab_bar.dart';

class AndroidFilePickerDialog extends StatefulWidget {
  const AndroidFilePickerDialog({
    super.key,
  });

  @override
  State<StatefulWidget> createState() => _AndroidFilePickerState();
}

class _AndroidFilePickerState extends State<StatefulWidget> {
  final _controller = AndroidFilePickerController();

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      _controller.init();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        width: double.infinity,
        height: 650,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              color: AppColors.titleBackground,
              height: 50,
              width: double.infinity,
              child: ValueListenableBuilder(
                  valueListenable: _controller.directories,
                  builder: (_, folders, __) {
                    return ScrollableTabBar(
                      scrollToRight: true,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: folders
                          .map((e) => Text(
                                '${e.path.split(Platform.pathSeparator).last} >  ',
                                style: AppTextStyle.textItemTitle,
                              ))
                          .toList(),
                      onTap: (index) {
                        _controller.goBack(index);
                      },
                    );
                  }),
            ),
            Expanded(
                child: Container(
              color: AppColors.detailBackground,
              child: ListenableBuilder(
                listenable: Listenable.merge(
                    [_controller.directories, _controller.files]),
                builder: (BuildContext context, Widget? child) {
                  final folderFiles = _controller.files.value;
                  final folders = _controller.directories.value;
                  return Column(children: [
                    if (folders.length > 1)
                      buildFolderItem('.. 返回上一级', () {
                        _controller.goBack(_controller.directories.size - 1);
                      }),
                    if (folders.length > 1) divider,
                    Expanded(
                        child: ListView.builder(
                            itemCount: max(0, folderFiles.length * 2 - 1),
                            itemBuilder: (_, index) {
                              final isDivider = index % 2 != 0;
                              final item =
                                  isDivider ? null : folderFiles[(index ~/ 2)];

                              return index % 2 != 0
                                  ? divider
                                  : (FileSystemEntity.isDirectorySync(
                                          item!.path)
                                      ? buildFolderItem(
                                          item.path
                                              .split(Platform.pathSeparator)
                                              .last, () {
                                          _controller
                                              .gotoFolder((item as Directory));
                                        })
                                      : buildFileItem(
                                          item.path
                                              .split(Platform.pathSeparator)
                                              .last, () {
                                          Navigator.of(context)
                                              .pop(item as File);
                                        }));
                            })),
                  ]);
                },
              ),
            ))
          ],
        ),
      ),
    );
  }

  GestureDetector buildFolderItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.folderBackground,
        width: double.infinity,
        height: 45,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
              color: AppColors.textTitle, fontSize: AppTextStyle.text_title),
        ),
      ),
    );
  }

  GestureDetector buildFileItem(String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        color: AppColors.fileBackground,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        height: 40,
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: AppTextStyle.textEntityItemTitle.copyWith(
              color: title.endsWith('.kdbx')
                  ? AppColors.textClick
                  : AppColors.text1),
        ),
      ),
    );
  }
}
