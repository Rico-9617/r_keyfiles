import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'remote/server/api_server.dart';

main() {
  var pipeline = const shelf.Pipeline();

  pipeline = pipeline.addMiddleware(shelf.logRequests());
  try {
    final handler = Cascade()
        //     .add(createStaticHandler(
        //   '',
        //   defaultDocument: 'index.html',
        // ))
        .add(ApiServer().apiRouter.call)
        .handler;
    final corsHandler =
        pipeline.addMiddleware(corsHeaders()).addHandler(handler);

    shelf_io.serve(corsHandler.call, '127.0.0.1', 54321).then((server) {
      print('Serving at http://${server.address.host}:${server.port}');
    });
    return true;
  } catch (e) {
    print(e);
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
