import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ApiServer {
  Router createApiRouter(String passcode) {
    return Router()
      ..get('/api/files', (Request request) {
        return Response(200, body: '{"test":"test"}');
      });
  }
}
