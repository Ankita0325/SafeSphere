import 'dart:convert';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _authToken;
  final Map<String, String> _headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> setAuthToken(String token) async {
    _authToken = token;
    _headers['Authorization'] = 'Bearer $token';
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.PREF_AUTH_TOKEN, token);
  }

  Future<String?> getAuthToken() async {
    if (_authToken != null) return _authToken;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.PREF_AUTH_TOKEN);
  }

  Future<void> clearAuthToken() async {
    _authToken = null;
    _headers.remove('Authorization');
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.PREF_AUTH_TOKEN);
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    if (endpoint.startsWith('/')) {
      return _handleFirestoreRequest('GET', endpoint);
    }

    try {
      final response = await http.get(
        Uri.parse('${AppConstants.API_BASE_URL}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (endpoint.startsWith('/')) {
      return _handleFirestoreRequest('POST', endpoint, body: body);
    }

    try {
      final response = await http.post(
        Uri.parse('${AppConstants.API_BASE_URL}$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    if (endpoint.startsWith('/')) {
      return _handleFirestoreRequest('PUT', endpoint, body: body);
    }

    try {
      final response = await http.put(
        Uri.parse('${AppConstants.API_BASE_URL}$endpoint'),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<Map<String, dynamic>> delete(String endpoint) async {
    if (endpoint.startsWith('/')) {
      return _handleFirestoreRequest('DELETE', endpoint);
    }

    try {
      final response = await http.delete(
        Uri.parse('${AppConstants.API_BASE_URL}$endpoint'),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Connection failed: $e');
    }
  }

  Future<Map<String, dynamic>> _handleFirestoreRequest(
    String method,
    String endpoint, {
    Map<String, dynamic>? body,
  }) async {
    try {
      final uri = Uri.parse('https://firebase.local$endpoint');
      final path = uri.path;
      final queryParams = uri.queryParameters;

      if (path == '/reports/incidents' && method == 'GET') {
        return _getReportIncidents(queryParams);
      }
      if (path == '/reports/heatmap-data' && method == 'GET') {
        return _getHeatmapData(queryParams);
      }
      if (path == '/reports/incident' && method == 'POST') {
        return _createIncident(body ?? {});
      }
      if (path.startsWith('/reports/') && path.endsWith('/vote') && method == 'POST') {
        return _voteReport(path, body ?? {});
      }
      if (path == '/emergency/trigger' && method == 'POST') {
        return _createEmergency(body ?? {});
      }
      if (path.startsWith('/emergency/update-status/') && method == 'PUT') {
        return _updateEmergencyStatus(path, body ?? {});
      }
      if (path.startsWith('/emergency/history/') && method == 'GET') {
        final userId = path.replaceFirst('/emergency/history/', '');
        return _getEmergencyHistory(userId);
      }
      if (path.startsWith('/emergency/nearby-services/') && method == 'GET') {
        final userId = path.replaceFirst('/emergency/nearby-services/', '');
        return _getNearbyServices(userId);
      }
      if (path == '/emergency/voice-detection' && method == 'POST') {
        return _detectVoiceEmergency(body ?? {});
      }
      if (path == '/routes/safe-route' && method == 'POST') {
        return _getSafeRoute(body ?? {});
      }
      if (path == '/routes/nearby-safe-zones' && method == 'GET') {
        return _getNearbySafeZones(queryParams);
      }
      if (path == '/routes/route-safety-score' && method == 'GET') {
        return _getRouteSafetyScore(queryParams);
      }
      if (path == '/analytics/safety-metrics' && method == 'GET') {
        return _getSafetyMetrics(queryParams);
      }

      return {};
    } catch (e) {
      throw Exception('Firebase request failed: $e');
    }
  }

  Future<Map<String, dynamic>> _getReportIncidents(
    Map<String, String> params,
  ) async {
    final latitude = _toDouble(params['lat']) ?? 0.0;
    final longitude = _toDouble(params['lng']) ?? 0.0;
    final radius = _toDouble(params['radius']) ?? 15.0;
    final limit = int.tryParse(params['limit'] ?? '50') ?? 50;
    final category = params['category'];

    final snapshot = await _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .get();

    final incidents = snapshot.docs
        .map((doc) => _reportFromDocument(doc))
        .where((incident) {
          if (category != null && category.isNotEmpty &&
              category != 'All' &&
              incident['category']?.toString().toLowerCase() !=
                  category.toLowerCase()) {
            return false;
          }
          if (latitude != 0.0 || longitude != 0.0) {
            final lat = _toDouble(incident['latitude']) ?? 0.0;
            final lng = _toDouble(incident['longitude']) ?? 0.0;
            final distance = _calculateDistance(latitude, longitude, lat, lng);
            return distance <= radius;
          }
          return true;
        })
        .take(limit)
        .toList();

    return {'incidents': incidents};
  }

  Future<Map<String, dynamic>> _getHeatmapData(
    Map<String, String> params,
  ) async {
    final reportData = await _getReportIncidents(params);
    final heatmapData = (reportData['incidents'] as List)
        .map((item) => Map<String, dynamic>.from(item as Map<String, dynamic>))
        .toList();

    return {
      'heatmap_data': heatmapData,
      'hospitals': [
        {
          'id': 'hospital_1',
          'name': 'Bandra General Hospital',
          'latitude': 19.0542,
          'longitude': 72.8454,
          'radius_m': 600,
        },
        {
          'id': 'hospital_2',
          'name': 'Juhu Medical Center',
          'latitude': 19.0981,
          'longitude': 72.8218,
          'radius_m': 500,
        },
      ],
      'analysis': {
        'recommendations': [
          'Avoid poorly lit roads after dusk near your area.',
          'Prefer main thoroughfares and police patrol zones.',
          'Report suspicious activity immediately.',
        ],
      },
    };
  }

  Future<Map<String, dynamic>> _createIncident(
    Map<String, dynamic> body,
  ) async {
    final now = DateTime.now();
    final reportData = {
      'type': body['type'] ?? 'General',
      'description': body['description'] ?? body['incident_description'] ?? '',
      'latitude': _toDouble(body['latitude']) ?? 0.0,
      'longitude': _toDouble(body['longitude']) ?? 0.0,
      'address': body['address'] ?? 'Unknown Location',
      'is_anonymous': body['is_anonymous'] ?? true,
      'severity': body['severity'] ?? 'medium',
      'category': body['category'] ?? body['type'] ?? 'General',
      'status': body['status'] ?? 'pending',
      'user_id': body['user_id'],
      'timestamp': Timestamp.fromDate(now),
      'upvotes': body['upvotes'] ?? 0,
      'downvotes': body['downvotes'] ?? 0,
      'safety_score': body['safety_score'] ?? 60,
    };

    final doc = await _firestore.collection('reports').add(reportData);

    return {
      'id': doc.id,
      ...reportData,
      'timestamp': now.toIso8601String(),
    };
  }

  Future<Map<String, dynamic>> _voteReport(
    String path,
    Map<String, dynamic> body,
  ) async {
    final reportId = path.split('/')[2];
    final voteType = body['vote_type']?.toString().toLowerCase() ?? 'upvote';
    final docRef = _firestore.collection('reports').doc(reportId);
    final doc = await docRef.get();

    if (!doc.exists) {
      return {'success': false};
    }

    final data = doc.data() as Map<String, dynamic>;
    final currentUpvotes = (data['upvotes'] ?? 0) as int;
    final currentDownvotes = (data['downvotes'] ?? 0) as int;
    final newUpvotes = voteType == 'upvote' ? currentUpvotes + 1 : currentUpvotes;
    final newDownvotes = voteType == 'downvote' ? currentDownvotes + 1 : currentDownvotes;
    final reportStatus = voteType == 'downvote' && newDownvotes > newUpvotes
        ? 'rejected'
        : data['status'] ?? 'pending';
    final safeScore = data['safety_score'] is int
        ? data['safety_score'] as int
        : int.tryParse(data['safety_score']?.toString() ?? '') ?? 60;

    await docRef.update({
      'upvotes': newUpvotes,
      'downvotes': newDownvotes,
      'status': reportStatus,
      'safety_score': safeScore,
    });

    return {
      'upvotes': newUpvotes,
      'downvotes': newDownvotes,
      'report_status': reportStatus,
      'safety_score': safeScore,
    };
  }

  Future<Map<String, dynamic>> _createEmergency(
    Map<String, dynamic> body,
  ) async {
    final now = DateTime.now();
    final userId = body['user_id']?.toString() ?? 'anonymous';
    final emergencyData = {
      'user_id': userId,
      'latitude': _toDouble(body['latitude']) ?? 0.0,
      'longitude': _toDouble(body['longitude']) ?? 0.0,
      'status': 'active',
      'incident_type': body['emergency_type'] ??
          body['incident_type'] ??
          body['type'] ??
          'general',
      'description': body['description'] ?? body['message'] ?? 'SOS alert triggered',
      'timestamp': Timestamp.fromDate(now),
      'resolved_at': null,
      'contacts_notified': body['contacts_notified'] ?? 1,
      'police_notified': body['police_notified'] ?? false,
    };

    final doc = await _firestore.collection('emergencies').add(emergencyData);

    if (userId != 'anonymous') {
      await _firestore.collection('users').doc(userId).set(
        {
          'sos_trigger_count': FieldValue.increment(1),
          'updated_at': now.toIso8601String(),
        },
        SetOptions(merge: true),
      );
    }

    return {
      'emergency_id': doc.id,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> _updateEmergencyStatus(
    String path,
    Map<String, dynamic> body,
  ) async {
    final emergencyId = path.replaceFirst('/emergency/update-status/', '');
    final updateData = <String, dynamic>{};

    if (body.containsKey('status')) {
      updateData['status'] = body['status'];
    }
    if (body['status'] == 'resolved' || body['status'] == 'cancelled') {
      updateData['resolved_at'] = Timestamp.fromDate(DateTime.now());
    }

    if (updateData.isNotEmpty) {
      await _firestore.collection('emergencies').doc(emergencyId).update(updateData);
    }

    return {'success': true};
  }

  Future<Map<String, dynamic>> _getEmergencyHistory(String userId) async {
    final snapshot = await _firestore
        .collection('emergencies')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .get();

    final history = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'user_id': data['user_id'],
        'latitude': _toDouble(data['latitude']) ?? 0.0,
        'longitude': _toDouble(data['longitude']) ?? 0.0,
        'status': data['status'] ?? 'active',
        'incident_type': data['incident_type'],
        'description': data['description'],
        'timestamp': _timestampToIsoString(data['timestamp']),
        'resolved_at': _timestampToIsoString(data['resolved_at']),
        'contacts_notified': data['contacts_notified'] ?? 0,
        'police_notified': data['police_notified'] ?? false,
      };
    }).toList();

    return {'history': history};
  }

  Future<Map<String, dynamic>> _getNearbyServices(String userId) async {
    final emergencySnapshot = await _firestore
        .collection('emergencies')
        .where('user_id', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(1)
        .get();

    if (emergencySnapshot.docs.isEmpty) {
      return {'nearby_services': []};
    }

    final emergency = emergencySnapshot.docs.first.data();
    final lat = _toDouble(emergency['latitude']) ?? 19.0760;
    final lng = _toDouble(emergency['longitude']) ?? 72.8777;

    final services = [
      {
        'type': 'police',
        'name': 'Bandra Police Station',
        'latitude': 19.0542,
        'longitude': 72.8401,
        'phone': '+91 022 2649 7495',
      },
      {
        'type': 'hospital',
        'name': 'Juhu Hospital',
        'latitude': 19.0987,
        'longitude': 72.8220,
        'phone': '+91 022 2615 5000',
      },
    ];

    return {
      'nearby_services': services
          .map((service) => {
                ...service,
                'distance_km': _calculateDistance(
                  lat,
                  lng,
                  _toDouble(service['latitude']) ?? 0.0,
                  _toDouble(service['longitude']) ?? 0.0,
                ),
              })
          .toList(),
    };
  }

  Future<Map<String, dynamic>> _detectVoiceEmergency(
    Map<String, dynamic> body,
  ) async {
    final text = (body['audio_text'] ?? '').toString().toLowerCase();
    final keywords = AppConstants.EMERGENCY_KEYWORDS
        .where((keyword) => text.contains(keyword.toLowerCase()))
        .toList();

    return {
      'emergency_detected': keywords.isNotEmpty,
      'keywords_detected': keywords,
    };
  }

  Future<Map<String, dynamic>> _getSafeRoute(
    Map<String, dynamic> body,
  ) async {
    final startLat = _toDouble(body['start_lat']);
    final startLng = _toDouble(body['start_lng']);
    final endLat = _toDouble(body['end_lat']);
    final endLng = _toDouble(body['end_lng']);
    final avoidUnsafeAreas = body['avoid_unsafe_areas'] ?? true;

    final waypoints = [
      {
        'latitude': startLat,
        'longitude': startLng,
        'safety_score': 90,
      },
      {
        'latitude': (startLat + endLat) / 2,
        'longitude': (startLng + endLng) / 2,
        'safety_score': avoidUnsafeAreas ? 85 : 70,
      },
      {
        'latitude': endLat,
        'longitude': endLng,
        'safety_score': 90,
      },
    ];

    final distance = _calculateDistance(startLat, startLng, endLat, endLng);
    final safeScore = (80 + max(0, 20 - distance.toInt())).clamp(40, 100).toInt();

    return {
      'waypoints': waypoints,
      'distance': distance,
      'duration': (distance * 12).round(),
      'safe_score': safeScore,
      'steps': [
        {
          'instruction': 'Start at your current location',
          'latitude': startLat,
          'longitude': startLng,
        },
        {
          'instruction': 'Follow the safe corridor through well-lit areas',
          'latitude': (startLat + endLat) / 2,
          'longitude': (startLng + endLng) / 2,
        },
        {
          'instruction': 'Arrive at your destination safely',
          'latitude': endLat,
          'longitude': endLng,
        },
      ],
      'warnings': avoidUnsafeAreas ? [] : ['Use caution near busy intersections'],
      'police_stations_nearby': [
        {
          'name': 'Bandra Police Station',
          'latitude': 19.0542,
          'longitude': 72.8401,
          'distance_km': 2.5,
        }
      ],
      'hospitals_nearby': [
        {
          'name': 'Juhu Hospital',
          'latitude': 19.0987,
          'longitude': 72.8220,
          'distance_km': 3.2,
        }
      ],
      'transport_mode': 'walking',
      'hazards': avoidUnsafeAreas ? [] : ['poor lighting'],
      'safe_features': ['well-lit', 'patrolled area'],
    };
  }

  Future<Map<String, dynamic>> _getNearbySafeZones(
    Map<String, String> params,
  ) async {
    final latitude = _toDouble(params['lat']) ?? 19.0760;
    final longitude = _toDouble(params['lng']) ?? 72.8777;
    final radius = _toDouble(params['radius']) ?? 5.0;

    final snapshot = await _firestore.collection('safe_zones').get();
    final zones = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? 'Safe Zone',
        'latitude': _toDouble(data['latitude']) ?? 0.0,
        'longitude': _toDouble(data['longitude']) ?? 0.0,
        'type': data['type'] ?? 'police',
        'address': data['address'] ?? '',
        'phone': data['phone'] ?? '',
      };
    }).toList();

    final filtered = zones.where((zone) {
      final lat = _toDouble(zone['latitude']) ?? 0.0;
      final lng = _toDouble(zone['longitude']) ?? 0.0;
      final distance = _calculateDistance(latitude, longitude, lat, lng);
      return distance <= radius;
    }).toList();

    return {'safe_zones': filtered.isNotEmpty ? filtered : zones.take(3).toList()};
  }

  Future<Map<String, dynamic>> _getRouteSafetyScore(
    Map<String, String> params,
  ) async {
    final latitude = _toDouble(params['lat']) ?? 19.0760;
    final longitude = _toDouble(params['lng']) ?? 72.8777;
    final recentReportsSnapshot = await _firestore
        .collection('reports')
        .orderBy('timestamp', descending: true)
        .limit(20)
        .get();

    final nearbyReports = recentReportsSnapshot.docs.where((doc) {
      final data = doc.data();
      final lat = _toDouble(data['latitude']);
      final lng = _toDouble(data['longitude']);
      return _calculateDistance(latitude, longitude, lat, lng) <= 10.0;
    }).length;

    final safetyScore = (90 - nearbyReports * 5).clamp(30, 95).toInt();
    final riskLevel = safetyScore >= 75 ? 'low' : safetyScore >= 50 ? 'medium' : 'high';

    return {
      'safety_score': safetyScore,
      'risk_level': riskLevel,
    };
  }

  Future<Map<String, dynamic>> _getSafetyMetrics(
    Map<String, String> params,
  ) async {
    final incidentsResponse = await _getReportIncidents(params);
    final incidents = incidentsResponse['incidents'] as List;
    final count = incidents.length;

    final overall = max(40, 95 - min(count * 4, 55));
    final safetyStatus = overall >= 80
        ? 'Very Safe'
        : overall >= 60
            ? 'Moderately Safe'
            : 'Some Risk';
    final trustColor = overall >= 80
        ? 'green'
        : overall >= 60
            ? 'yellow'
            : 'orange';

    return {
      'overall_safety_score': overall,
      'safety_status': safetyStatus,
      'trust_color': trustColor,
      'ai_detection_score': 88,
      'sos_response_score': 75,
      'community_trust_score': 82,
      'trust_score': 76,
      'trust_level': overall >= 80 ? 'High' : 'Medium',
    };
  }

  double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  double _calculateDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    const earthRadius = 6371.0;
    final dLat = _degreesToRadians(lat2 - lat1);
    final dLng = _degreesToRadians(lng2 - lng1);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Map<String, dynamic> _reportFromDocument(QueryDocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return {
      'id': doc.id,
      'incident_type': data['type'] ?? 'General',
      'description': data['description'] ?? '',
      'address': data['address'] ?? 'Unknown Location',
      'latitude': _toDouble(data['latitude']),
      'longitude': _toDouble(data['longitude']),
      'timestamp': _timestampToIsoString(data['timestamp']),
      'anonymous': data['is_anonymous'] ?? true,
      'severity': data['severity'] ?? 'medium',
      'category': data['category'] ?? data['type'] ?? 'General',
      'status': data['status'] ?? 'pending',
      'user_id': data['user_id'],
      'upvotes': data['upvotes'] ?? 0,
      'downvotes': data['downvotes'] ?? 0,
      'safety_score': data['safety_score'] ?? 60,
    };
  }

  String _timestampToIsoString(dynamic timestamp) {
    if (timestamp == null) return DateTime.now().toIso8601String();
    if (timestamp is Timestamp) {
      return timestamp.toDate().toIso8601String();
    }
    if (timestamp is DateTime) {
      return timestamp.toIso8601String();
    }
    return timestamp.toString();
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }
      return json.decode(response.body);
    } else {
      try {
        final error = json.decode(response.body);
        throw Exception(error['detail'] ?? 'Request failed');
      } catch (e) {
        throw Exception('Request failed: ${response.statusCode}');
      }
    }
  }
}
