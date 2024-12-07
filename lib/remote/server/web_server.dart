import 'dart:io';
import 'dart:math';

import 'package:archive/archive_io.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:r_backup_tool/main.dart';
import 'package:r_backup_tool/repo/local_repo.dart';
import 'package:r_backup_tool/utils/tools.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_static/shelf_static.dart';

import 'api_server.dart';
import 'host_controller.dart';

class WebServer {
  int port = 0;
  HttpServer? server;
  final passcode = ValueNotifier('');

  String get serverAddress => 'http://${server?.address.host}:${server?.port}';

  startServer() async {
    Directory webFolder = Directory(
        p.join((await getApplicationDocumentsDirectory()).path, 'remote'));
    await _checkWebFolder(webFolder);
    final ip = await HostController.instance.loadIPAddress();
    if (ip.isEmpty) return false;
    port = generatePortNumber();
    var pipeline = const shelf.Pipeline();

    if (kDebugMode) {
      pipeline = pipeline.addMiddleware(shelf.logRequests());
    }
    try {
      passcode.value = (10000000 + Random().nextInt(80000000)).toString();
      final handler = Cascade()
          .add(createStaticHandler(
            webFolder.path,
            defaultDocument: 'index.html',
          ))
          .add(ApiServer().createApiRouter(passcode.value).call)
          .handler;
      final corsHandler =
          pipeline.addMiddleware(corsHeaders()).addHandler(handler);

      shelf_io.serve(corsHandler.call, ip, port).then((server) {
        print('Serving at http://${server.address.host}:${server.port}');
        this.server = server;
      });
      return true;
    } catch (e) {
      logger.e(e);
    }
    return false;
  }

  Future<void> _checkWebFolder(Directory webFolder) async {
    if (await webFolder.exists()) {
      final webVersion = await LocalRepo.instance.getString('_web_version');
      if (webVersion != (await getVersion())) {
        await webFolder.delete(recursive: true);
        await _unzipWebFolder(webFolder.parent.path);
      }
    } else {
      await _unzipWebFolder(webFolder.parent.path);
    }
  }

  Future<void> _unzipWebFolder(String parent) async {
    final bytes =
        (await rootBundle.load('assets/remote.zip')).buffer.asUint8List();
    final archive = ZipDecoder().decodeBytes(bytes);
    for (final file in archive) {
      final filename = file.name;
      if (filename.contains('__MACOSX') || filename.contains('.DS_Store')) {
        continue;
      }
      if (file.isFile) {
        final data = file.content as List<int>;
        File('$parent/$filename')
          ..createSync(recursive: true)
          ..writeAsBytesSync(data);
      } else {
        Directory('$parent/$filename').createSync(recursive: true);
      }
    }
    LocalRepo.instance.saveString('_web_version', await getVersion());
  }

  stopServer() {
    server?.close();
  }
}

Middleware corsHeaders() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
        'Access-Control-Allow-Headers': 'Origin,Content-Type',
      });
    };
  };
}
