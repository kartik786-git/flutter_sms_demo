import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;

bool isMobilePlatform() {
  if (kIsWeb) return false;
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (_) {
    return false;
  }
}

bool isDesktopPlatform() {
  if (kIsWeb) return false;
  try {
    return Platform.isWindows || Platform.isLinux || Platform.isMacOS;
  } catch (_) {
    return false;
  }
}