import 'dart:io';
import 'dart:core';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:kdbx_lib/kdbx.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:r_backup_tool/model/kdbx_file_wrapper.dart';
import 'package:r_backup_tool/styles.dart';
import 'package:r_backup_tool/widgets/buttons.dart';
import 'package:r_backup_tool/widgets/content_scaffold.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:path/path.dart' as p;

class KeyManagerTabPage extends StatefulWidget {
  const KeyManagerTabPage({super.key});

  @override
  State<KeyManagerTabPage> createState() => _KeyManagerTabPageState();
}

class _KeyManagerTabPageState extends State<KeyManagerTabPage>
    with SingleTickerProviderStateMixin {
  final filesNotifier = ValueNotifier<List<KdbxFileWrapper>>(List.empty());
  final currentFile = ValueNotifier<KdbxFileWrapper?>(null);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Permission.storage.onGrantedCallback(() async {
        final saved = (await SharedPreferences.getInstance())
            .getStringList('_k_files')
            ?.map((path) => File(path));
        if (saved != null && saved.isNotEmpty) {
          final kdbxFiles = <KdbxFileWrapper>[];
          for (final file in saved) {
            if (file.existsSync() &&
                file.statSync().type == FileSystemEntityType.file) {
              final wrapper = KdbxFileWrapper(file.path);
              wrapper.title.value = p.basename(file.path);
            }
          }
          filesNotifier.value = kdbxFiles;
          currentFile.value = kdbxFiles.firstOrNull;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return ContentScaffold(child: (statusBarHeight, _) {
      return Column(
        children: [
          Container(
            padding: EdgeInsets.only(top: statusBarHeight),
            height: statusBarHeight + 50,
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClickableWidget(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () {},
                    child: const Text(
                      "新建",
                      style: AppTexts.textButtonNormal,
                    )),
                ClickableWidget(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    onTap: () async {
                      await Permission.storage.onGrantedCallback(() async {
                        FilePickerResult? result =
                            await FilePicker.platform.pickFiles();

                        if (result != null) {
                          final file = File(result.files.single.path!);
                          // Decrypt the KDBX file
                          final kdbx = await KdbxFormat().read(
                              file.readAsBytesSync(),
                              Credentials(ProtectedValue.fromString('123456')));

                          final wrapper = KdbxFileWrapper(file.path);
                          wrapper.kdbxFile = kdbx;
                          wrapper.title.value = p.basename(file.path);
                          final wrapper1 = KdbxFileWrapper(file.path);
                          wrapper1.kdbxFile = kdbx;
                          wrapper1.title.value = '${p.basename(file.path)}1';

                          filesNotifier.value = [
                            wrapper,
                            wrapper1,
                          ];
                          currentFile.value = filesNotifier.value.firstOrNull;

                          print('body.rootGroup: ${kdbx.body.rootGroup}');
                          print('body.node: ${kdbx.body.node}');
                          _loop(kdbx.body.rootGroup.entries);
                        } else {
                          EasyLoading.showToast('文件解析失败！');
                        }
                      }).request();
                    },
                    child: const Text(
                      "打开",
                      style: AppTexts.textButtonNormal,
                    ))
              ],
            ),
          ),
          ValueListenableBuilder(
              valueListenable: filesNotifier,
              builder: (_, files, __) {
                return files.isEmpty
                    ? const SizedBox()
                    : Container(
                        color: Colors.white70,
                        height: 40,
                        child: TabBarView(
                            controller: TabController(
                                length: files.length, vsync: this),
                            children: files
                                .map((e) => GestureDetector(
                                      onTap: () {
                                        currentFile.value = e;
                                      },
                                      child: ValueListenableBuilder(
                                        builder: (_, file, __) {
                                          return ValueListenableBuilder(
                                            builder: (_, title, __) {
                                              return Text(
                                                title,
                                                style: file == e
                                                    ? AppTexts.textPrimary
                                                    : AppTexts.textDisable,
                                              );
                                            },
                                            valueListenable: e.title,
                                          );
                                        },
                                        valueListenable: currentFile,
                                      ),
                                    ))
                                .toList()),
                      );
              }),
          Expanded(
              child: Container(
            width: double.infinity,
            color: Colors.cyanAccent,
            child: ValueListenableBuilder(
              builder: (_, file, __) {
                print('testchange page ${file?.title}');
                return file == null
                    ? const SizedBox()
                    : Column(
                        children: [
                          const SizedBox(
                            height: 30,
                          ),
                          ValueListenableBuilder(
                            builder: (_, title, __) {
                              return Text(
                                title,
                                style: AppTexts.textPrimary,
                              );
                            },
                            valueListenable: file.title,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                file.title.value = 'changed title hahaha';
                              },
                              child: const Text('change')),
                        ],
                      );
              },
              valueListenable: currentFile,
            ),
          ))
        ],
      );
    });
  }

  void _loop(List<KdbxEntry> entries) {
    for (final entry in entries) {
      print('entry label: ${entry.label}');
      print('entry customData: ${entry.customData}');
      for (final se in entry.stringEntries) {
        print('entry string: ${se.key}  = ${se.value}');
      }
      for (final ce in entry.customData.entries) {
        print('entry custom entry: ${ce.key}  = ${ce.value}');
      }
    }
  }
}
