import 'package:r_backup_tool/utils/encrypt_tool.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

class ApiServer {
  Router createApiRouter(String passcode) {
    return Router()
      ..post('/api/verify', (Request request) async {
        final md5 = EncryptTool.md5String(passcode);
        String? data = await request.readAsString();
        try {
          print('requestin verify $data');
          data = EncryptTool.decrypt(data, md5.substring(md5.length - 8));
          print('requestin decode ${data}  ${md5 == data}');
        } catch (e) {
          print(e);
        }
        // if (md5 == data) {
        //   final random = Random();
        //   final len = random.nextInt(data.length ~/ 2) + 6;
        //   return Response(200,
        //       body: '${random.nextInt(data.length - len)},$len');
        // } else {
        return Response(200);
        // }
      })
      ..get('/api/files', (Request request) {
        return Response(200, body: '{"test":"test"}');
      });
  }
}

const corsHeaders = <String, String>{
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET,POST,PUT,DELETE,OPTIONS',
  'Access-Control-Allow-Headers':
      'Origin,Content-Type,Authorization,auth-param',
};

Middleware corsHeadersMiddleware() {
  return (Handler handler) {
    return (Request request) async {
      final response = await handler(request);
      return response.change(headers: corsHeaders);
    };
  };
}

Middleware handleOptionsRequests() {
  return (Handler handler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok('', headers: corsHeaders);
      }
      return handler(request);
    };
  };
}
