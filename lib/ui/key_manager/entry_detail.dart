import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/password_dialog.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/utils/tools.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';
import 'package:r_backup_tool/widgets/text_field_wrapper.dart';

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
  late KeyEntryDetailController entryDetailController;

  @override
  void initState() {
    entryDetailController = KeyEntryDetailController(widget.entry);
    super.initState();
  }

  @override
  void dispose() {
    entryDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> save() async {
      EasyLoading.show();
      final result =
          await entryDetailController.saveChanges(widget.keyFile, widget.entry);
      if (result != null && result.isNotEmpty) {
        EasyLoading.showToast(result);
      } else {
        EasyLoading.dismiss();
      }
      return result == null;
    }

    onClickBack() {
      hideKeyboard(context);
      if (widget.entry.modified.value) {
        showCenterDialog(context,
            builder: (_, __, ___) => TipsDialog(
                  tips: '内容有变更，是否保存?',
                  actions: [
                    TextButton(
                      child: const Text('忽略'),
                      onPressed: () {
                        Navigator.of(context).pop();
                        entryDetailController.recover(widget.entry);
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: const Text('保存'),
                      onPressed: () async {
                        Navigator.of(context).pop();
                        if (await save() && mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ));
      } else {
        Navigator.of(context).pop();
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        onClickBack();
      },
      child: Scaffold(
        body: Hero(
          tag: widget.heroTag,
          child: Container(
            color: AppColors.entryBackground,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).padding.top,
                ),
                Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      IconButton(
                          onPressed: () {
                            onClickBack();
                          },
                          icon: const Icon(Icons.close)),
                      Expanded(
                        child: ValueListenableBuilder(
                            valueListenable: widget.entry.title,
                            builder: (_, title, __) {
                              return Text(
                                title?.getText() ?? 'unnamed',
                                style: AppTextStyle.textEntityTitle,
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
                        OutlinedButton(
                          child: const Text('修改名称'),
                          onPressed: () {
                            hideKeyboard(context);
                            TextInputDialog.show(
                                context,
                                (_) => TextInputDialog(
                                      onConfirm: (text) async {
                                        EasyLoading.show();
                                        final result = entryDetailController
                                            .modifyEntryName(
                                                text, widget.entry);
                                        if (result != null &&
                                            result.isNotEmpty) {
                                          EasyLoading.showToast(result);
                                        } else {
                                          EasyLoading.dismiss();
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
                        OutlinedButton(
                          child: const Text('删除'),
                          onPressed: () {
                            hideKeyboard(context);
                            showCenterDialog(context,
                                builder: (_, __, ___) =>
                                    TipsDialog(tips: '是否删除该密钥?', actions: [
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
                                          final result =
                                              await entryDetailController
                                                  .deleteEntry(widget.keyFile,
                                                      widget.entry);
                                          if (result != null &&
                                              result.isNotEmpty) {
                                            EasyLoading.showToast(result);
                                          } else {
                                            EasyLoading.dismiss();
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
                                ? OutlinedButton(
                                    child: const Text('保存'),
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
                  child: Stack(
                    children: [
                      ListView(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            '用户名',
                            style: AppTextStyle.textEntityItemTitle,
                          ),
                          TextHeadTailWrapper(
                            textField: TextField(
                              controller:
                                  entryDetailController.userNameEditController,
                              onTapOutside: (_) => hideKeyboard(context),
                              enabled: hasExternalStoragePermission.value ||
                                  !widget.keyFile.externalStore.value,
                              style: AppTextStyle.textPrimary,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(right: 50),
                              ),
                            ),
                            tail: TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: entryDetailController
                                          .userNameEditController.text));
                                  EasyLoading.showToast('已复制');
                                },
                                child: const Text(
                                  '复制',
                                  style: AppTextStyle.textButtonBlue,
                                )),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            '密码',
                            style: AppTextStyle.textEntityItemTitle,
                          ),
                          TextHeadTailWrapper(
                            textField: GestureDetector(
                              onTap: () {
                                if (hasExternalStoragePermission.value ||
                                    !widget.keyFile.externalStore.value) {
                                  hideKeyboard(context);
                                  PasswordDialog(
                                    onConfirm: (p) async {
                                      entryDetailController.modifyPsw(
                                          p, widget.entry);
                                      return true;
                                    },
                                    title: '设置新密码',
                                    useGenerator: true,
                                  ).show(context);
                                }
                              },
                              child: TextField(
                                maxLines: null,
                                controller:
                                    entryDetailController.pswEditController,
                                enabled: false,
                                style: AppTextStyle.textPrimary,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(right: 100),
                                ),
                              ),
                            ),
                            tail: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  behavior: HitTestBehavior.translucent,
                                  onTapDown: (_) {
                                    entryDetailController
                                        .switchPswDisplay(false);
                                  },
                                  onTapUp: (_) {
                                    entryDetailController
                                        .switchPswDisplay(true);
                                  },
                                  onTapCancel: () {
                                    entryDetailController
                                        .switchPswDisplay(true);
                                  },
                                  onDoubleTap: () async {
                                    entryDetailController
                                        .switchPswDisplay(false);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 4),
                                    height: 40,
                                    child: const Center(
                                      child: Text(
                                        '查看',
                                        style: AppTextStyle.textButtonBlue,
                                      ),
                                    ),
                                  ),
                                ),
                                TextButton(
                                    onPressed: () async {
                                      Clipboard.setData(ClipboardData(
                                          text: entryDetailController.curPsw
                                                  ?.getText() ??
                                              ''));
                                      EasyLoading.showToast('已复制，10秒内有效！');
                                      await Future.delayed(
                                          const Duration(seconds: 10));
                                      Clipboard.setData(
                                          const ClipboardData(text: ''));
                                    },
                                    child: const Text(
                                      '复制',
                                      style: AppTextStyle.textButtonBlue,
                                    )),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 16,
                          ),
                          const Text(
                            '地址',
                            style: AppTextStyle.textEntityItemTitle,
                          ),
                          TextHeadTailWrapper(
                            textField: TextField(
                              controller:
                                  entryDetailController.urlEditController,
                              enabled: hasExternalStoragePermission.value ||
                                  !widget.keyFile.externalStore.value,
                              onTapOutside: (_) => hideKeyboard(context),
                              style: AppTextStyle.textPrimary,
                              decoration: const InputDecoration(
                                contentPadding: EdgeInsets.only(right: 50),
                              ),
                            ),
                            tail: TextButton(
                                onPressed: () {
                                  Clipboard.setData(ClipboardData(
                                      text: entryDetailController
                                          .urlEditController.text));
                                  EasyLoading.showToast('已复制');
                                },
                                child: const Text(
                                  '复制',
                                  style: AppTextStyle.textButtonBlue,
                                )),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          Row(
                            children: [
                              const Text(
                                '备注',
                                style: AppTextStyle.textEntityItemTitle,
                              ),
                              GestureDetector(
                                onTap: () {
                                  Clipboard.setData(ClipboardData(
                                      text: entryDetailController
                                          .noteEditController.text));
                                  EasyLoading.showToast('已复制');
                                },
                                child: const SizedBox(
                                  width: 50,
                                  height: 40,
                                  child: Center(
                                    child: Text(
                                      '复制',
                                      style: AppTextStyle.textButtonBlue,
                                    ),
                                  ),
                                ),
                              )
                            ],
                          ),
                          TextField(
                            controller:
                                entryDetailController.noteEditController,
                            enabled: hasExternalStoragePermission.value ||
                                !widget.keyFile.externalStore.value,
                            onTapOutside: (_) => hideKeyboard(context),
                            style: AppTextStyle.textPrimary,
                            maxLines: null,
                            decoration: const InputDecoration(
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ],
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
}
