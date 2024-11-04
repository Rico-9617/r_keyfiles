import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:r_backup_tool/colors.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/ui/dialog/text_input_dialog.dart';
import 'package:r_backup_tool/widgets/dialogs.dart';
import 'package:r_backup_tool/widgets/scrollable_tab_bar.dart';
import 'package:r_backup_tool/widgets/transparent_page_route.dart';

import 'entry_detail.dart';

class GroupDetail extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final headHeight = MediaQuery.of(context).padding.top + 40;
    final content = Stack(
      children: [
        Positioned.fill(
            child: Hero(
          tag: animTag,
          child: Container(
            color: AppColors.detailBackground,
            child: Container(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
              constraints: BoxConstraints(minHeight: headHeight),
              child: Row(
                children: [
                  if (individual)
                    IconButton(
                        onPressed: () {
                          // onClickBack();
                        },
                        icon: const Icon(Icons.close)),
                  Expanded(
                      child: ValueListenableBuilder(
                          valueListenable: group.title,
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
        )),
        Positioned.fill(
          child: Column(
            children: [
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
                            : Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 8.0),
                                child:
                                    Wrap(spacing: 8, runSpacing: 4, children: [
                                  TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        '修改组名',
                                        style: AppTextStyle.textButtonBlue,
                                      )),
                                  TextButton(
                                      onPressed: () {
                                        showCenterDialog(context,
                                            builder: (_, __, ___) =>
                                                TextInputDialog(
                                                  onConfirm: (text) async {
                                                    if (text.isEmpty) {
                                                      EasyLoading.showToast(
                                                          '名称不能为空!');
                                                      return false;
                                                    }
                                                    EasyLoading.show();
                                                    // final result =
                                                    //     await detailController
                                                    //         .modifyKeyStoreTitle(
                                                    //             keyFile, text);
                                                    // if (result != null &&
                                                    //     result.isNotEmpty) {
                                                    //   EasyLoading.showToast(
                                                    //       result);
                                                    // } else {
                                                    //   EasyLoading.dismiss();
                                                    // }
                                                    // return result == null;
                                                    return true;
                                                  },
                                                  title: '设置名称',
                                                  content: keyFile.title.value,
                                                ));
                                      },
                                      child: const Text(
                                        '创建子组',
                                        style: AppTextStyle.textButtonBlue,
                                      )),
                                  TextButton(
                                      onPressed: () {},
                                      child: const Text(
                                        '创建密钥',
                                        style: AppTextStyle.textButtonBlue,
                                      )),
                                  if (group.removable)
                                    TextButton(
                                        onPressed: () {},
                                        child: const Text(
                                          '删除该组',
                                          style: AppTextStyle.textButtonBlue,
                                        )),
                                ]));
                      },
                      valueListenable: keyFile.externalStore,
                    );
                  }),
              ValueListenableBuilder(
                  valueListenable: group.groups,
                  builder: (_, subGroups, __) => subGroups.isEmpty
                      ? const SizedBox()
                      : Column(
                          children: [
                            Divider(),
                            ScrollableTabBar(
                                children: subGroups.map((e) {
                              final heroTag = 'group_${e.hashCode}';
                              return Hero(
                                tag: heroTag,
                                child: OutlinedButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(buildTransparentPageRoute(
                                        GroupDetail(
                                            keyFile: keyFile,
                                            group: e,
                                            animTag: heroTag),
                                      ));
                                    },
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
                            Divider(),
                          ],
                        )),
              Expanded(
                child: Stack(
                  children: [
                    ValueListenableBuilder(
                        valueListenable: group.entries,
                        builder: (_, entries, __) {
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            itemCount: entries.length,
                            itemBuilder: (context, index) {
                              final item = entries[index];
                              final heroTag = 'key_title_$index';
                              return GestureDetector(
                                onTap: () {
                                  Navigator.of(context)
                                      .push(buildTransparentPageRoute(
                                    EntryDetail(
                                        keyFile: keyFile,
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
                                      color: AppColors.entryBackground,
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
    return individual
        ? PopScope(
            canPop: false,
            onPopInvokedWithResult: (didPop, result) {
              if (didPop) return;
              // onClickBack();
            },
            child: content)
        : content;
  }
}
