import 'package:r_backup_tool/utils/tools.dart';

class HostController {
  HostController._();

  static HostController? _instance;

  static HostController get instance {
    _instance ??= HostController._();
    return _instance!;
  }

  String curIpAddress = '';

  Future<String> loadIPAddress({bool refresh = false}) async {
    if (!refresh && curIpAddress.isNotEmpty) return curIpAddress;
    final ip = await getIpAddress();
    if (ip == null || ip.isEmpty) {
      return '';
    } else {
      curIpAddress = ip;
      return ip;
    }
  }
}
