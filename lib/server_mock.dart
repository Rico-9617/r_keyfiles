import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'remote/server/api_server.dart';

main() {
  final pipeline = const shelf.Pipeline()
      .addMiddleware(shelf.logRequests())
      .addMiddleware(corsHeadersMiddleware())
      .addMiddleware(handleOptionsRequests());
  try {
    final handler = ApiServer().createApiRouter('12345678');
    // Cascade().add(ApiServer().createApiRouter('12345678').call).handler;
    final corsHandler = pipeline.addHandler(handler.call);

    shelf_io.serve(corsHandler.call, '127.0.0.1', 54321).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
    return true;
  } catch (e) {
    print(e);
  }
}
