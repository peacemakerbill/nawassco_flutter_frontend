import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;

class AppConstants {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000/api';
    }
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:3000/api';
    }
    return 'http://localhost:3000/api';
  }

  static const String logoPath = 'assets/logo.png';

  //Date and Time Format Constants
  static const String displayDateFormat = 'dd MMM yyyy';         // e.g. 07 Nov 2025
  static const String apiDateFormat = 'yyyy-MM-dd';              // e.g. 2025-11-07
  static const String displayDateTimeFormat = 'dd MMM yyyy, HH:mm'; // e.g. 07 Nov 2025, 14:30
}
