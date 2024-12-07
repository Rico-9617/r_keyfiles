import 'dart:io';
import 'dart:math';

import 'package:flutter/widgets.dart';
import 'package:package_info_plus/package_info_plus.dart';

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).unfocus();
  FocusManager.instance.primaryFocus?.unfocus();
}

Future<String?> getIpAddress() async {
  try {
    for (var interface in await NetworkInterface.list()) {
      for (var address in interface.addresses) {
        if (address.type == InternetAddressType.IPv4 && !address.isLoopback) {
          return address.address;
        }
      }
    }
  } catch (e) {
    print('Failed to get IP address: $e');
  }
  return null;
}

int generatePortNumber() {
  final random = Random(); // Port range: 1024 to 65535
  int minPort = 1024;
  int maxPort = 65535;
  return minPort + random.nextInt(maxPort - minPort);
}

Future<String> getVersion() async {
  return (await PackageInfo.fromPlatform()).version;
}
