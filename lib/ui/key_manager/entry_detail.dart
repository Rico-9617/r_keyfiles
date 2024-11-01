import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_entry_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';

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
    logger.d(
        'permission ${hasExternalStoragePermission.value}  ${widget.keyFile.encrypted.value}');
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        logger.w('popdetail $didPop');
        if (didPop) return;
        Navigator.of(context).pop();
      },
      child: Hero(
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
                    IconButton(onPressed: () {}, icon: const Icon(Icons.close)),
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
                  children: [
                    ValueListenableBuilder(
                        valueListenable: widget.entry.modified,
                        builder: (context, modified, _) {
                          return modified
                              ? OutlinedButton(
                                  child: const Text('保存'),
                                  onPressed: () async {
                                    EasyLoading.show();
                                    final result =
                                        await entryDetailController.saveChanges(
                                            widget.keyFile, widget.entry);
                                    if (result != null && result.isNotEmpty) {
                                      EasyLoading.showToast(result);
                                    } else {
                                      EasyLoading.dismiss();
                                    }
                                  },
                                )
                              : const SizedBox();
                        }),
                    if (!widget.keyFile.externalStore.value ||
                        hasExternalStoragePermission.value)
                      OutlinedButton(
                        child: const Text('修改名称'),
                        onPressed: () {
                          TextInputDialog(
                            onConfirm: (text) async {
                              EasyLoading.show();
                              final result = entryDetailController
                                  .modifyEntryName(text, widget.entry);
                              if (result != null && result.isNotEmpty) {
                                EasyLoading.showToast(result);
                              } else {
                                EasyLoading.dismiss();
                              }
                              return result == null;
                            },
                            title: '设置新名称',
                            content: widget.keyFile.title.value,
                          );
                        },
                      ),
                    if (!widget.keyFile.externalStore.value ||
                        hasExternalStoragePermission.value)
                      OutlinedButton(
                        child: const Text('删除'),
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    title: const Text('是否删除该密钥?'),
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
                                    ],
                                  ));
                        },
                      ),
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
                        TextField(
                          controller:
                              entryDetailController.userNameEditController,
                          enabled: hasExternalStoragePermission.value ||
                              !widget.keyFile.externalStore.value,
                          style: AppTextStyle.textPrimary,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              suffix: TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: entryDetailController
                                            .userNameEditController.text));
                                    EasyLoading.showToast('已复制');
                                  },
                                  child: const Text(
                                    '复制',
                                    style: AppTextStyle.textButtonBlue,
                                  ))),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          '密码',
                          style: AppTextStyle.textEntityItemTitle,
                        ),
                        TextField(
                          controller:
                              entryDetailController.userNameEditController,
                          enabled: false,
                          onTap: () {},
                          style: AppTextStyle.textPrimary,
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.zero,
                              suffix: TextButton(
                                  onPressed: () {
                                    Clipboard.setData(ClipboardData(
                                        text: entryDetailController
                                            .userNameEditController.text));
                                    EasyLoading.showToast('已复制');
                                  },
                                  child: const Text(
                                    '复制',
                                    style: AppTextStyle.textButtonBlue,
                                  ))),
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          'URL',
                          style: AppTextStyle.textEntityItemTitle,
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        const Text(
                          '备注',
                          style: AppTextStyle.textEntityItemTitle,
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
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
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
    );
  }
}
