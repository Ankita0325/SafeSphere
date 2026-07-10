import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import '../models/emergency_model.dart';
import 'api_service.dart';
import 'location_service.dart';

class EmergencyService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  int _sosTriggerCount = 0;

  bool _isEmergencyActive = false;
  Emergency? _currentEmergency;
  List<Emergency> _emergencyHistory = [];

  bool get isEmergencyActive => _isEmergencyActive;
  Emergency? get currentEmergency => _currentEmergency;
  List<Emergency> get emergencyHistory => _emergencyHistory;
  int get sosTriggerCount => _sosTriggerCount;

  Future<void> _playSiren() async {
    try {
      Vibration.vibrate(pattern: [500, 200, 500, 200, 500]);
      await Future.delayed(const Duration(seconds: 1));
      Vibration.vibrate(pattern: [500, 200, 500, 200, 500]);
    } catch (e) {
      print('Siren playback error: $e');
    }
  }

  Future<void> _stopSiren() async {
    try {
      Vibration.cancel();
    } catch (e) {}
  }

  Future<void> triggerEmergency({
    required String userId,
    String? incidentType,
    String? description,
    double? latitude,
    double? longitude,
    bool playSiren = true,
  }) async {
    _isEmergencyActive = true;
    _sosTriggerCount++;
    notifyListeners();

    try {
      if (playSiren) {
        await _playSiren();
      }

      Vibration.vibrate(pattern: [500, 200, 500, 200, 500]);

      final response = await _apiService.post('/emergency/trigger', body: {
        'user_id': userId,
        'latitude': latitude,
        'longitude': longitude,
        'emergency_type': incidentType ?? 'general',
        'description': description ?? 'SOS alert triggered',
        'message': 'Emergency alert from SafeSphere',
      });

      _currentEmergency = Emergency(
        id: response['emergency_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        latitude: latitude ?? 0.0,
        longitude: longitude ?? 0.0,
        incidentType: incidentType ?? 'general',
        description: description ?? 'SOS alert triggered',
        timestamp: DateTime.now(),
        contactsNotified: 1,
        policeNotified: false,
      );

      notifyListeners();
    } catch (e) {
      print('Emergency trigger error: $e');
      _isEmergencyActive = false;
      await _stopSiren();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> triggerOfflineEmergency({
    required String userId,
    String? incidentType,
    String? description,
  }) async {
    _isEmergencyActive = true;
    _sosTriggerCount++;
    notifyListeners();

    try {
      final position = await _locationService.getCurrentPosition();

      if (position != null) {
        await _playSiren();
        Vibration.vibrate(pattern: [500, 200, 500, 200, 500]);
      }

      final response = await _apiService.post('/emergency/trigger', body: {
        'user_id': userId,
        'latitude': position?.latitude ?? 0.0,
        'longitude': position?.longitude ?? 0.0,
        'emergency_type': incidentType ?? 'general',
        'description': description ?? 'SOS alert triggered',
        'message': 'Emergency alert from SafeSphere',
      });

      _currentEmergency = Emergency(
        id: response['emergency_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        userId: userId,
        latitude: position?.latitude ?? 0.0,
        longitude: position?.longitude ?? 0.0,
        incidentType: incidentType ?? 'general',
        description: description ?? 'SOS alert triggered',
        timestamp: DateTime.now(),
        contactsNotified: 1,
        policeNotified: false,
      );

      notifyListeners();
    } catch (e) {
      print('Emergency trigger error: $e');
      _isEmergencyActive = false;
      await _stopSiren();
      notifyListeners();
    }
  }

  Future<void> cancelEmergency(String emergencyId) async {
    try {
      await _apiService.put(
        '/emergency/update-status/$emergencyId',
        body: {'status': 'cancelled'},
      );
    } catch (e) {
      print('Cancel emergency API error: $e');
    }

    await _stopSiren();
    Vibration.cancel();

    _isEmergencyActive = false;
    _currentEmergency = null;
    notifyListeners();
  }

  Future<void> resolveEmergency(String emergencyId) async {
    try {
      await _apiService.put(
        '/emergency/update-status/$emergencyId',
        body: {'status': 'resolved'},
      );
    } catch (e) {
      print('Resolve emergency API error: $e');
    }

    await _stopSiren();
    Vibration.cancel();

    _isEmergencyActive = false;
    _currentEmergency = null;
    notifyListeners();
  }

  Future<void> loadEmergencyHistory(String userId) async {
    try {
      final response = await _apiService.get('/emergency/history/$userId');
      _emergencyHistory = (response['history'] as List)
          .map((e) => Emergency.fromJson(e))
          .toList();
      notifyListeners();
    } catch (e) {
      print('Load emergency history error: $e');
    }
  }

  Future<Map<String, dynamic>> getNearbyServices(String userId) async {
    try {
      final response = await _apiService.get(
        '/emergency/nearby-services/$userId',
      );
      return response;
    } catch (e) {
      print('Get nearby services error: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> detectVoiceEmergency(String audioText) async {
    try {
      final response = await _apiService.post(
        '/emergency/voice-detection',
        body: {'audio_text': audioText},
      );
      return response;
    } catch (e) {
      print('Voice detection error: $e');
      return {'emergency_detected': false, 'keywords_detected': []};
    }
  }
}