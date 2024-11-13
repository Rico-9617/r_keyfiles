import 'package:flutter/material.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/controller/key_group_detail_controller.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/ui/dialog/tips_dialog.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';
import 'package:r_backup_tool/widgets/scrollable_tab_bar.dart';
import 'package:r_backup_tool/widgets/transparent_page_route.dart';

import 'entry_detail.dart';

class GroupDetail extends StatefulWidget {
  final KdbxGroupWrapper group;
  final KdbxFileWrapper keyFile;
  final String animTag;
  final bool individual;

  const GroupDetail(
      {super.key,
      required this.group,
      required this.keyFile,
      this.animTag = '',
      this.individual = true});

  @override
  State<GroupDetail> createState() => _GroupDetailState();
}

class _GroupDetailState extends State<GroupDetail> {
  final groupController = KeyGroupDetailController();

  @override
  Widget build(BuildContext context) {
    final background = widget.individual
        ? AppColors.groupBackground
        : AppColors.detailBackground;
    final double headHeight =
        widget.individual ? MediaQuery.of(context).padding.top + 40 : 40;
    final content = Stack(
      children: [
        if (widget.individual)
          Positioned.fill(
              child: Hero(
            tag: widget.animTag,
            child: Container(
              decoration: BoxDecoration(color: background, boxShadow: [
                if (widget.individual)
                  const BoxShadow(
                      color: Colors.black12,
                      offset: Offset(0.0, 1.0),
                      spreadRadius: 2,
                      blurRadius: 1)
              ]),
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: widget.individual
                      ? EdgeInsets.only(top: MediaQuery.of(context).padding.top)
                      : EdgeInsets.zero,
                  constraints: BoxConstraints(minHeight: headHeight),
                  child: Row(
                    children: [
                      if (widget.individual)
                        IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.close)),
                      Expanded(
                          child: ValueListenableBuilder(
                              valueListenable: widget.group.title,
                              builder: (_, title, __) {
                                return Text(
                                  title,
                                  style: AppTextStyle.textEntityTitle,
                                );
                              })),
                    ],
                  ),
                ),
              ),
            ),
          )),
        Positioned.fill(
          child: Column(
            children: [
              if (widget.individual)
                SizedBox(
                  height: headHeight,
                ),
              ValueListenableBuilder(
                  valueListenable: hasExternalStoragePermission,
                  builder: (context, hasStoragePermission, __) {
                    return ValueListenableBuilder(
                      builder: (context, external, __) {
                        return external && !hasStoragePermission
                            ? const SizedBox()
                            : Container(
                                width: double.infinity,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child:
                                    Wrap(spacing: 8, runSpacing: 4, children: [
                                  if (!widget.group.recycleBin)
                                    TextButton(
                                        onPressed: () {
                                          showCenterDialog(context,
                                              builder: (_, __, ___, ____) =>
                                                  TextInputDialog(
                                                    onConfirm: (text) async {
                                                      if (text.isEmpty) {
                                                        Toast.show('名称不能为空!');
                                                        return false;
                                                      }
                                                      LoadingDialog.show();
                                                      final result =
                                                          await groupController
                                                              .modifyGroupTitle(
                                                        text,
                                                        widget.group,
                                                        widget.keyFile,
                                                      );
                                                      LoadingDialog.dismiss();
                                                      if (result != null &&
                                                          result.isNotEmpty) {
                                                        Toast.show(result);
                                                      }

                                                      return result == null;
                                                    },
                                                    title: '设置新名称',
                                                    content: widget
                                                        .group.title.value,
                                                  ));
                                        },
                                        child: const Text(
                                          '修改名称',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                  if (!widget.group.recycleBin)
                                    TextButton(
                                        onPressed: () {
                                          showCenterDialog(context,
                                              builder: (_, __, ___, ____) =>
                                                  TextInputDialog(
                                                    onConfirm: (text) async {
                                                      if (text.isEmpty) {
                                                        Toast.show('名称不能为空!');
                                                        return false;
                                                      }
                                                      LoadingDialog.show();
                                                      final result =
                                                          await groupController
                                                              .createGroup(
                                                                  text,
                                                                  widget.group,
                                                                  widget
                                                                      .keyFile);
                                                      if (result != null &&
                                                          result.isNotEmpty) {
                                                        Toast.show(result);
                                                      }
                                                      LoadingDialog.dismiss();

                                                      return result == null;
                                                    },
                                                    title: '新组名称',
                                                  ));
                                        },
                                        child: const Text(
                                          '添加子组',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                  if (!widget.group.recycleBin)
                                    TextButton(
                                        onPressed: () {
                                          showCenterDialog(context,
                                              builder: (_, __, ___, route) =>
                                                  TextInputDialog(
                                                    onConfirm: (text) async {
                                                      if (text.isEmpty) {
                                                        Toast.show('名称不能为空!');
                                                        return false;
                                                      }
                                                      LoadingDialog.show();
                                                      final result =
                                                          await groupController
                                                              .createEntry(
                                                                  text,
                                                                  widget.group,
                                                                  widget
                                                                      .keyFile);
                                                      LoadingDialog.dismiss();
                                                      if (result.result !=
                                                          null) {
                                                        Toast.show(
                                                            result.result);
                                                      } else if (mounted &&
                                                          result.entryWrapper !=
                                                              null) {
                                                        Navigator.of(context)
                                                            .removeRoute(route);
                                                        final entryWrapper =
                                                            result
                                                                .entryWrapper!;
                                                        Navigator.of(context)
                                                            .push(
                                                                buildTransparentPageRoute(
                                                          EntryDetail(
                                                              keyFile: widget
                                                                  .keyFile,
                                                              entry:
                                                                  entryWrapper,
                                                              heroTag:
                                                                  'key_title_${entryWrapper.hashCode}'),
                                                        ))
                                                            .then((saved) {
                                                          if (saved != true) {
                                                            groupController
                                                                .recoverEntry(
                                                                    entryWrapper,
                                                                    widget
                                                                        .group,
                                                                    widget
                                                                        .keyFile);
                                                          }
                                                        });
                                                      }
                                                      return false;
                                                    },
                                                    title: '新密钥名称',
                                                  ));
                                        },
                                        child: const Text(
                                          '添加密钥',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                  if (!widget.group.rootGroup &&
                                      !widget.group.recycleBin)
                                    TextButton(
                                        onPressed: () {
                                          showCenterDialog(context,
                                              builder: (_, __, ___, ____) =>
                                                  TipsDialog(
                                                      tips: '是否删除该组?',
                                                      actions: [
                                                        TextButton(
                                                          child: const Text(
                                                            '取消',
                                                            style: AppTextStyle
                                                                .textButtonBlue,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            '确定',
                                                            style: AppTextStyle
                                                                .textButtonBlue,
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            LoadingDialog
                                                                .show();
                                                            final result =
                                                                await groupController
                                                                    .deleteGroup(
                                                                        widget
                                                                            .group,
                                                                        widget
                                                                            .keyFile);
                                                            LoadingDialog
                                                                .dismiss();
                                                            if (result !=
                                                                    null &&
                                                                result
                                                                    .isNotEmpty) {
                                                              Toast.show(
                                                                  result);
                                                            } else {
                                                              if (mounted) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ]));
                                        },
                                        child: const Text(
                                          '删除该组',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                  if (widget.group.recycleBin)
                                    TextButton(
                                        onPressed: () {
                                          showCenterDialog(context,
                                              builder: (_, __, ___, ____) =>
                                                  TipsDialog(
                                                      tips: '是否清空回收站（无法恢复）?',
                                                      actions: [
                                                        TextButton(
                                                          child: const Text(
                                                            '取消',
                                                            style: AppTextStyle
                                                                .textButtonBlue,
                                                          ),
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                          },
                                                        ),
                                                        TextButton(
                                                          child: const Text(
                                                            '确定',
                                                            style: AppTextStyle
                                                                .textButtonBlue,
                                                          ),
                                                          onPressed: () async {
                                                            Navigator.of(
                                                                    context)
                                                                .pop();
                                                            LoadingDialog
                                                                .show();
                                                            final result =
                                                                groupController
                                                                    .clearRecycleBin(
                                                                        widget
                                                                            .group);
                                                            LoadingDialog
                                                                .dismiss();
                                                            if (result !=
                                                                    null &&
                                                                result
                                                                    .isNotEmpty) {
                                                              Toast.show(
                                                                  result);
                                                            } else {
                                                              if (mounted) {
                                                                Navigator.of(
                                                                        context)
                                                                    .pop();
                                                              }
                                                            }
                                                          },
                                                        ),
                                                      ]));
                                        },
                                        child: const Text(
                                          '清空',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                ]));
                      },
                      valueListenable: widget.keyFile.externalStore,
                    );
                  }),
              ValueListenableBuilder(
                  valueListenable: widget.group.groups,
                  builder: (_, subGroups, __) => subGroups.isEmpty
                      ? const SizedBox()
                      : SizedBox(
                          width: double.infinity,
                          child: ScrollableTabBar(
                              onTap: (index) {
                                Navigator.of(context)
                                    .push(buildTransparentPageRoute(
                                  GroupDetail(
                                      keyFile: widget.keyFile,
                                      group: subGroups[index],
                                      animTag:
                                          'group_${subGroups[index].hashCode}'),
                                ));
                              },
                              children: subGroups.map((e) {
                                final heroTag = 'group_${e.hashCode}';
                                return Hero(
                                  tag: heroTag,
                                  child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 4, vertical: 4),
                                      decoration: const BoxDecoration(
                                          color: AppColors.groupItemBackground,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.black12,
                                                offset: Offset(0.0, 1.0),
                                                spreadRadius: 1,
                                                blurRadius: 1)
                                          ]),
                                      child: ValueListenableBuilder(
                                        builder: (_, title, __) {
                                          return Text(
                                            title,
                                            style: AppTextStyle.textPrimary
                                                .copyWith(fontSize: 12),
                                          );
                                        },
                                        valueListenable: e.title,
                                      )),
                                );
                              }).toList()),
                        )),
              Expanded(
                child: Stack(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: widget.group.entries,
                        builder: (_, entries, __) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final item = entries[index];
                              final heroTag = 'key_title_${item.hashCode}';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(buildTransparentPageRoute(
                                    EntryDetail(
                                        keyFile: widget.keyFile,
                                        entry: item,
                                        heroTag: heroTag),
                                  ));
                                },
                                child: Hero(
                                  tag: heroTag,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16, vertical: 4),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    height: 50,
                                    alignment: Alignment.centerLeft,
                                    decoration: const BoxDecoration(
                                      color: AppColors.entryItemBackground,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.black12,
                                            offset: Offset(0.0, 1.0),
                                            spreadRadius: 1,
                                            blurRadius: 2)
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        ValueListenableBuilder(
                                            valueListenable: item.title,
                                            builder: (_, title, __) {
                                              return Text(
                                                title?.getText() ?? 'unnamed',
                                                style: AppTextStyle
                                                    .textEntityTitle,
                                              );
                                            }),
                                      ],
                                    ),
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
                            colors: [background, background.withAlpha(0)],
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
                            colors: [background, background.withAlpha(0)],
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ],
    );
    return content;
  }
}
