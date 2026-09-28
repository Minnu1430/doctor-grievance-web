import 'dart:io';
import 'package:flutter/foundation.dart';

class AppConfig {
  static const String appName = 'Doctor Grievance System';
  static const String orgName = 'Telangana Council of Hospitals';
  static const String appVersion = '1.0.0';
  static const String supportEmail =
      'support.grievance@tch.telangana.gov.in';

  static String get defaultBaseUrl {
    // Production Flutter Web
    if (kIsWeb) {
      return 'https://doctor-grievance-backend.onrender.com/api';
    }

    // Android physical device - local development
    if (Platform.isAndroid) {
      return 'http://192.168.0.9:5000/api';
    }

    // Windows/Desktop - local development
    return 'http://localhost:5000/api';
  }

  static String customBaseUrl = '';

  static String get baseUrl {
    if (customBaseUrl.isNotEmpty) {
      return customBaseUrl;
    }

    return defaultBaseUrl;
  }

  static const int connectTimeoutSeconds = 15;
  static const int receiveTimeoutSeconds = 15;
}
