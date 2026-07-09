import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';

class SmsService extends ChangeNotifier {
  bool _isSmsSupported = false;
  String _emergencyPhone = '+919970206614';
  final ApiService _apiService = ApiService();

  bool get isSmsSupported => _isSmsSupported;
  String get emergencyPhone => _emergencyPhone;

  Future<void> setEmergencyPhone(String phone) async {
    _emergencyPhone = phone;
    notifyListeners();
  }

  SmsService() {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      _isSmsSupported = true;
      notifyListeners();
    } catch (e) {
      print('SMS initialization error: $e');
      _isSmsSupported = false;
    }
  }

  Future<bool> sendEmergencySMS({
    required String userId,
    required double latitude,
    required double longitude,
    String? customPhone,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userName = prefs.getString(AppConstants.PREF_USER_NAME) ?? 'User';

      final message = '''
🚨 EMERGENCY ALERT!

$userName may be in danger!

📍 Live Location:
https://maps.google.com/?q=$latitude,$longitude

🕐 Time: ${DateTime.now().toLocal().toString()}

⚠️ Please respond immediately!
''';

      final phone = customPhone ?? _emergencyPhone;

      if (kIsWeb ||
          defaultTargetPlatform != TargetPlatform.android &&
              defaultTargetPlatform != TargetPlatform.iOS) {
        return _dispatchEmergencyViaBackend(
          userId: userId,
          phone: phone,
          message: message,
          latitude: latitude,
          longitude: longitude,
        );
      }

      final status = await Permission.sms.request();
      if (!status.isGranted) {
        print('SMS permission not granted, using fallback dispatch');
        return _dispatchEmergencyViaBackend(
          userId: userId,
          phone: phone,
          message: message,
          latitude: latitude,
          longitude: longitude,
        );
      }

      try {
        await _sendSmsFallback(phone, message);
        print('SMS sent to $phone');
        return true;
      } catch (e) {
        print('Failed to send SMS: $e');
        return false;
      }
    } catch (e) {
      print('Failed to send emergency SMS: $e');
      return false;
    }
  }

  Future<bool> _dispatchEmergencyViaBackend({
    required String userId,
    required String phone,
    required String message,
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _apiService.post(
        '/emergency/trigger',
        body: {
          'message': message,
          'location': 'Live location request',
          'user_id': userId,
          'emergency_type': 'danger',
          'latitude': latitude,
          'longitude': longitude,
          'contact_numbers': [phone],
          'description': 'Emergency alert triggered from app',
        },
      );

      return response['success'] == true;
    } catch (e) {
      print('Backend emergency dispatch failed: $e');
      return false;
    }
  }

  Future<void> _sendSmsFallback(String phone, String message) async {
    try {
      final Uri smsUri = Uri(
        scheme: 'sms',
        path: phone,
        queryParameters: {'body': message},
      );

      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      }
    } catch (e) {
      print('SMS fallback failed: $e');
    }
  }

  Future<bool> sendSms(String phone, String message) async {
    if (kIsWeb ||
        defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS) {
      print('SMS launch is not supported on this platform');
      return false;
    }

    try {
      final status = await Permission.sms.request();
      if (!status.isGranted) {
        print('SMS permission not granted');
        return false;
      }

      await _sendSmsFallback(phone, message);
      return true;
    } catch (e) {
      print('Failed to send SMS: $e');
      return false;
    }
  }
}
