import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:3000';
    } else {
      return 'http://15.15.3.222:3000';
    }
  }
}
