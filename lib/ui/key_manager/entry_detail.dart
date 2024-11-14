import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/ui/key_manager/entry_base_info.dart';
import 'package:r_backup_tool/utils/tools.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';

import 'entry_files.dart';
import 'entry_other_info.dart';

class EntryDetail extends StatefulWidget {
  final KdbxFileWrapper keyFile;
  final KdbxEntryWrapper entry;
  final String heroTag;

  const EntryDetail(
      {super.key,
      required this.keyFile,
      required this.entry,
      required this.heroTag});

  @override
  State<EntryDetail> createState() => _EntryDetailState();
}

class _EntryDetailState extends State<EntryDetail> {
  late KeyEntryDetailController _entryDetailController;
  final _tab = ValueNotifier(0);

  @override
  void initState() {
    _entryDetailController =
        KeyEntryDetailController(keyFile: widget.keyFile, entry: widget.entry);
    super.initState();
  }

  @override
  void dispose() {
    _entryDetailController.dispose();
    super.dispose();
  }

  Future<bool> save() async {
    LoadingDialog.show();
    final result = await _entryDetailController.saveChanges();
    LoadingDialog.dismiss();
    if (result != null && result.isNotEmpty) {
      Toast.show(result);
    }

    return result == null;
  }

  onClickBack() {
    hideKeyboard(context);
    if (widget.entry.modified.value) {
      showCenterDialog(context,
          builder: (_, __, ___, ____) => TipsDialog(
                tips: '内容有变更，是否保存?',
                actions: [
                  TextButton(
                    child: const Text(
                      '忽略',
                      style: AppTextStyle.textButtonBlue,
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      _entryDetailController.recover();
                      Navigator.of(context).pop(false);
                    },
                  ),
                  TextButton(
                    child: const Text(
                      '保存',
                      style: AppTextStyle.textButtonBlue,
                    ),
                    onPressed: () async {
                      Navigator.of(context).pop();
                      if (await save() && mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                  ),
                ],
              ));
    } else {
      Navigator.of(context).pop(!widget.entry.newEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onClickBack();
      },
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Hero(
          tag: widget.heroTag,
          child: Container(
            decoration: const BoxDecoration(
                color: AppColors.entryBackground,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 1.0),
                      spreadRadius: 2,
                      blurRadius: 1)
                ]),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  color: AppColors.entryItemBackground,
                  padding:
                      EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                  constraints: BoxConstraints(
                      minHeight: 40 + MediaQuery.of(context).padding.top),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            onClickBack();
                          },
                          icon: const Icon(
                            Icons.close,
                            color: AppColors.textTitle,
                          )),
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: widget.entry.title,
                            builder: (_, title, __) {
                              return Text(
                                title?.getText() ?? 'unnamed',
                                style: AppTextStyle.textItemTitle,
                              );
                            }),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 4,
                    children: [
                      if (!widget.keyFile.externalStore.value ||
                          hasExternalStoragePermission.value)
                        TextButton(
                          child: const Text('修改名称',
                              style: AppTextStyle.textButtonBlue),
                          onPressed: () {
                            hideKeyboard(context);
                            showCenterDialog(context,
                                builder: (_, __, ___, ____) => TextInputDialog(
                                      onConfirm: (text) async {
                                        LoadingDialog.show();
                                        final result = _entryDetailController
                                            .modifyEntryName(text);
                                        LoadingDialog.dismiss();
                                        if (result != null &&
                                            result.isNotEmpty) {
                                          Toast.show(result);
                                        }
                                        return result == null;
                                      },
                                      title: '设置新名称',
                                      content:
                                          widget.entry.title.value?.getText() ??
                                              '',
                                    ));
                          },
                        ),
                      if (!widget.keyFile.externalStore.value ||
                          hasExternalStoragePermission.value)
                        TextButton(
                          child: const Text('删除',
                              style: AppTextStyle.textButtonBlue),
                          onPressed: () {
                            hideKeyboard(context);
                            showCenterDialog(context,
                                builder: (_, __, ___, ____) =>
                                    TipsDialog(tips: '是否删除该密钥?', actions: [
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
                                          '确定',
                                          style: AppTextStyle.textButtonBlue,
                                        ),
                                        onPressed: () async {
                                          Navigator.of(context).pop();
                                          LoadingDialog.show();
                                          final result =
                                              await _entryDetailController
                                                  .deleteEntry();
                                          LoadingDialog.dismiss();
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            Toast.show(result);
                                          } else {
                                            if (mounted) {
                                              Navigator.of(context).pop();
                                            }
                                          }
                                        },
                                      ),
                                    ]));
                          },
                        ),
                      ValueListenableBuilder(
                          valueListenable: widget.entry.modified,
                          builder: (context, modified, _) {
                            return modified
                                ? TextButton(
                                    child: const Text('保存',
                                        style: AppTextStyle.textButtonBlue),
                                    onPressed: () async {
                                      hideKeyboard(context);
                                      save();
                                    },
                                  )
                                : const SizedBox();
                          }),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      SizedBox(
                        height: 40,
                        child: Row(
                          children: [
                            Expanded(
                                child: ValueListenableBuilder(
                              valueListenable: _tab,
                              builder: (_, tab, child) =>
                                  _infoTabBuilder(tab == 0, child!),
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _tab.value = 0;
                                  },
                                  child: const Center(child: Text('基础信息'))),
                            )),
                            Expanded(
                                child: ValueListenableBuilder(
                              valueListenable: _tab,
                              builder: (_, tab, child) =>
                                  _infoTabBuilder(tab == 1, child!),
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _tab.value = 1;
                                  },
                                  child: const Center(child: Text('附加信息'))),
                            )),
                            Expanded(
                                child: ValueListenableBuilder(
                              valueListenable: _tab,
                              builder: (_, tab, child) =>
                                  _infoTabBuilder(tab == 2, child!),
                              child: GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTap: () {
                                    _tab.value = 2;
                                  },
                                  child: const Center(child: Text('文件'))),
                            )),
                          ],
                        ),
                      ),
                      Expanded(
                          child: ValueListenableBuilder(
                              valueListenable: _tab,
                              builder: (_, tab, __) => switch (tab) {
                                    0 => EntryBaseInfo(
                                        controller: _entryDetailController,
                                      ),
                                    1 => EntryOtherInfo(
                                        controller: _entryDetailController,
                                      ),
                                    2 => EntryFiles(
                                        controller: _entryDetailController,
                                      ),
                                    _ => const SizedBox()
                                  }))
                    ],
                  ),
                ),
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoTabBuilder(bool selected, Widget child) =>
      AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: TextStyle(
            color: selected ? AppColors.text0 : Colors.black54,
            fontSize: selected ? 16 : 12),
        child: child,
      );
}
