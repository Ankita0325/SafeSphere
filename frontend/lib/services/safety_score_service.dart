import 'package:flutter/material.dart';
import 'api_service.dart';

class SafetyScoreService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  int _overallScore = 67;
  int _aiDetectionScore = 88;
  int _sosResponseScore = 75;
  int _communityTrustScore = 82;
  int _trustScore = 75;
  
  String _safetyStatus = 'Medium Risk';
  String _trustLevel = 'Medium';
  String _trustColor = 'yellow';
  
  bool _isLoading = false;
  String? _error;
  double? _latitude;
  double? _longitude;
  
  int get overallScore => _overallScore;
  int get aiDetectionScore => _aiDetectionScore;
  int get sosResponseScore => _sosResponseScore;
  int get communityTrustScore => _communityTrustScore;
  int get trustScore => _trustScore;
  String get safetyStatus => _safetyStatus;
  String get trustLevel => _trustLevel;
  String get trustColor => _trustColor;
  bool get isLoading => _isLoading;
  String? get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;
  
  Future<void> fetchSafetyMetrics({double? lat, double? lng}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    try {
      final double latitude = lat ?? _latitude ?? 19.0760;
      final double longitude = lng ?? _longitude ?? 72.8777;
      
      _latitude = latitude;
      _longitude = longitude;
      
      final response = await _apiService.get(
        '/analytics/safety-metrics?lat=$latitude&lng=$longitude',
      );
      
      _overallScore = response['overall_safety_score'] ?? 67;
      _safetyStatus = response['safety_status'] ?? 'Medium Risk';
      _trustColor = response['trust_color'] ?? 'yellow';
      _aiDetectionScore = response['ai_detection_score'] ?? 88;
      _sosResponseScore = response['sos_response_score'] ?? 75;
      _communityTrustScore = response['community_trust_score'] ?? 82;
      _trustScore = response['trust_score'] ?? 75;
      _trustLevel = response['trust_level'] ?? 'Medium';
      
      _error = null;
    } catch (e) {
      // Fallback to default values when API fails
      _overallScore = 67;
      _safetyStatus = 'Medium Risk';
      _trustColor = 'yellow';
      _aiDetectionScore = 88;
      _sosResponseScore = 75;
      _communityTrustScore = 82;
      _trustScore = 75;
      _trustLevel = 'Medium';
      _error = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  void updateLocation(double lat, double lng) {
    _latitude = lat;
    _longitude = lng;
    fetchSafetyMetrics(lat: lat, lng: lng);
  }
  
  Map<String, dynamic> getMetrics() {
    return {
      'overallScore': _overallScore,
      'aiDetection': _aiDetectionScore,
      'sosResponse': _sosResponseScore,
      'communityTrust': _communityTrustScore,
      'trustScore': _trustScore,
      'status': _safetyStatus,
      'trustLevel': _trustLevel,
      'trustColor': _trustColor,
    };
  }
}