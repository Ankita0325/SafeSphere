import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  List<Map<String, dynamic>> _communityReports = [];
  bool _sosNotifications = true;
  bool _locationAlerts = true;
  bool _communityReportsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadCommunityReports();
  }

  Future<void> _loadCommunityReports() async {
    setState(() => _isLoading = true);
    try {
      final response = await _apiService.get(
        '/reports/incidents?lat=19.0760&lng=72.8777&radius=10&limit=20',
      );
      if (response.containsKey('incidents')) {
        setState(() {
          _communityReports = List<Map<String, dynamic>>.from(
            response['incidents'].map((e) => Map<String, dynamic>.from(e)),
          );
        });
      } else {
        _loadOfflineFallback();
      }
    } catch (e) {
      _loadOfflineFallback();
    }
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _loadOfflineFallback() {
    _communityReports = [
      {
        'id': '1',
        'type': 'Harassment',
        'description': 'Verbal harassment reported near Andheri station',
        'location': 'Andheri, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'severity': 'medium',
      },
      {
        'id': '2',
        'type': 'Stalking',
        'description': 'Suspicious activity reported in Bandra area',
        'location': 'Bandra, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'severity': 'high',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
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
                      'Notification Preferences',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ),
                  const Divider(height: 1),
                  SwitchListTile(
                    title: const Text('SOS Alerts'),
                    subtitle: const Text('Notify when emergency is triggered'),
                    value: _sosNotifications,
                    onChanged: (v) => setState(() => _sosNotifications = v),
                    activeColor: const Color(0xFF7C3AED),
                  ),
                  SwitchListTile(
                    title: const Text('Location Safety Alerts'),
                    subtitle: const Text('Notify about nearby danger zones'),
                    value: _locationAlerts,
                    onChanged: (v) => setState(() => _locationAlerts = v),
                    activeColor: const Color(0xFF7C3AED),
                  ),
                  SwitchListTile(
                    title: const Text('Community Reports'),
                    subtitle: const Text('Notify about nearby incident reports'),
                    value: _communityReportsEnabled,
                    onChanged: (v) => setState(() => _communityReportsEnabled = v),
                    activeColor: const Color(0xFF7C3AED),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Recent Community Reports',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_communityReports.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    'No recent reports in your area',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              )
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _communityReports.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final report = _communityReports[index];
                  return _buildReportCard(report);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> report) {
    Color severityColor;
    switch (report['severity'] ?? 'medium') {
      case 'high':
        severityColor = const Color(0xFFEF4444);
        break;
      case 'medium':
        severityColor = const Color(0xFFF59E0B);
        break;
      default:
        severityColor = const Color(0xFF10B981);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: severityColor.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            Icons.report,
            color: severityColor,
            size: 20,
          ),
        ),
        title: Text(
          report['type'] ?? 'Incident Report',
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              report['description'] ?? '',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.location_on, size: 14, color: Colors.grey[500]),
                const SizedBox(width: 4),
                Text(
                  report['location'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Text(
          report['timestamp'] is DateTime
              ? DateFormat('MMM dd').format(report['timestamp'])
              : 'Recently',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}