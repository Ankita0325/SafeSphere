import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';
import '../services/location_service.dart';

class LocationSettingsScreen extends StatefulWidget {
  const LocationSettingsScreen({super.key});

  @override
  State<LocationSettingsScreen> createState() => _LocationSettingsScreenState();
}

class _LocationSettingsScreenState extends State<LocationSettingsScreen> {
  final ApiService _apiService = ApiService();
  final MapController _mapController = MapController();
  
  LatLng _currentLocation = const LatLng(19.0760, 72.8777);
  bool _locationPermission = false;
  bool _backgroundLocation = false;
  bool _isLoading = false;
  List<Map<String, dynamic>> _safeZones = [];
  List<Map<String, dynamic>> _heatmapData = [];

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  Future<void> _loadLocation() async {
    final locationService = Provider.of<LocationService>(context, listen: false);
    final pos = locationService.currentPosition;
    if (pos != null) {
      setState(() {
        _currentLocation = LatLng(pos.latitude, pos.longitude);
      });
    }
    _loadSafeZones();
  }

  Future<void> _loadSafeZones() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        '/reports/heatmap-data?lat=${_currentLocation.latitude}&lng=${_currentLocation.longitude}&radius=15&days=30',
      );
      if (response.containsKey('heatmap_data')) {
        setState(() {
          _heatmapData = List<Map<String, dynamic>>.from(
            response['heatmap_data'].map((e) => Map<String, dynamic>.from(e)),
          );
        });
      }
    } catch (e) {
      _loadOfflineSafeZones();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _loadOfflineSafeZones() {
    _safeZones = [
      {'lat': 19.0760, 'lng': 72.8777, 'name': 'SafeZone Park', 'type': 'Safe Area'},
      {'lat': 19.1179, 'lng': 72.8488, 'name': 'Community Center', 'type': 'Safe Area'},
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Location Settings',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6E3FB0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 18, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Location Permissions',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('Location Access'),
                    subtitle: const Text('Allow SafeSphere to access your location'),
                    value: _locationPermission,
                    onChanged: (v) async {
                      setState(() => _locationPermission = v);
                      if (v) {
                        final locationService =
                            Provider.of<LocationService>(context, listen: false);
                        await locationService.getCurrentPosition();
                      }
                    },
                    activeColor: const Color(0xFF7C3AED),
                  ),
                  SwitchListTile(
                    title: const Text('Background Location'),
                    subtitle: const Text('Allow location access when app is in background'),
                    value: _backgroundLocation,
                    onChanged: (v) => setState(() => _backgroundLocation = v),
                    activeColor: const Color(0xFF7C3AED),
                  ),
                  ListTile(
                    leading: const Icon(Icons.my_location, color: Color(0xFF7C3AED)),
                    title: const Text('Current Location'),
                    subtitle: Text(
                      'Lat: ${_currentLocation.latitude.toStringAsFixed(4)}\nLng: ${_currentLocation.longitude.toStringAsFixed(4)}',
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.refresh, color: Color(0xFF7C3AED)),
                      onPressed: _loadLocation,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _currentLocation,
                    initialZoom: 13,
                    maxZoom: 18,
                    minZoom: 10,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                      subdomains: const ['a', 'b', 'c'],
                      userAgentPackageName: 'com.womensafety.safesphere',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _currentLocation,
                          child: const Icon(
                            Icons.my_location,
                            color: Colors.blue,
                            size: 30,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Saved Safe Zones',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (_safeZones.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No saved safe zones',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _safeZones.length,
                      itemBuilder: (context, index) {
                        final zone = _safeZones[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on, color: Colors.green),
                          title: Text(zone['name'] ?? 'Safe Zone'),
                          subtitle: Text(zone['type'] ?? 'Safe Area'),
                        );
                      },
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    spreadRadius: 0,
                    blurRadius: 20,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Text(
                      'Nearby Safety Heatmap Data',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  if (_heatmapData.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(20),
                      child: Text(
                        'No heatmap data available',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _heatmapData.length,
                      itemBuilder: (context, index) {
                        final data = _heatmapData[index];
                        return ListTile(
                          leading: Icon(
                            Icons.warning,
                            color: data['severity'] == 'high'
                                ? Colors.red
                                : Colors.orange,
                          ),
                          title: Text(data['type'] ?? 'Incident'),
                          subtitle: Text(
                            'Safety Score: ${data['safety_score'] ?? 0}',
                          ),
                          trailing: Text(
                            '${(data['weight'] ?? 0).toStringAsFixed(1)}x',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}