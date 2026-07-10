import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/api_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();
  final TextEditingController _reportController = TextEditingController();
  String _selectedIncidentType = 'Harassment';
  bool _isAnonymous = true;
  bool _isSubmitting = false;
  List<Map<String, dynamic>> _communityReports = [];
  List<Map<String, dynamic>> _myReports = [];

  final List<String> _incidentTypes = [
    'Harassment',
    'Stalking',
    'Physical Assault',
    'Sexual Assault',
    'Domestic Violence',
    'Road Accident',
    'Medical Emergency',
    'Fire',
    'Theft',
    'Other'
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadMockDataImmediately();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _reportController.dispose();
    super.dispose();
  }

  // Load mock data immediately for faster display
  void _loadMockDataImmediately() {
    // Mock community reports - load instantly
    _communityReports = [
      {
        'id': '1',
        'type': 'Harassment',
        'description': 'Verbal harassment near Andheri station. A group of men were making inappropriate comments.',
        'location': 'Andheri Station, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(hours: 2)),
        'anonymous': true,
        'severity': 'medium',
        'isMyReport': false,
      },
      {
        'id': '2',
        'type': 'Stalking',
        'description': 'Suspicious person following me at Bandra. Same person seen multiple times.',
        'location': 'Bandra West, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(days: 1)),
        'anonymous': true,
        'severity': 'high',
        'isMyReport': false,
      },
      {
        'id': '3',
        'type': 'Theft',
        'description': 'Phone snatching near Juhu beach. Two people on a bike.',
        'location': 'Juhu Beach, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(days: 2)),
        'anonymous': false,
        'severity': 'medium',
        'isMyReport': false,
      },
      {
        'id': '4',
        'type': 'Road Accident',
        'description': 'Minor accident near Andheri flyover. Please drive carefully.',
        'location': 'Andheri Flyover, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'anonymous': true,
        'severity': 'low',
        'isMyReport': false,
      },
    ];

    // Mock my reports - load instantly
    _myReports = [
      {
        'id': 'm1',
        'type': 'Harassment',
        'description': 'Someone was following me near my office building',
        'location': 'BKC, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(hours: 5)),
        'anonymous': true,
        'severity': 'high',
        'status': 'In Progress',
        'isMyReport': true,
      },
      {
        'id': 'm2',
        'type': 'Stalking',
        'description': 'Same car seen multiple times near my building at night',
        'location': 'Powai, Mumbai',
        'timestamp': DateTime.now().subtract(const Duration(days: 3)),
        'anonymous': false,
        'severity': 'medium',
        'status': 'Resolved',
        'isMyReport': true,
      },
    ];
    
    // Load real data in background
    _loadReportsInBackground();
  }

  // Load real data in background without blocking UI
  Future<void> _loadReportsInBackground() async {
    try {
      final response = await _apiService.get(
        '/reports/incidents?lat=19.0760&lng=72.8777&radius=10&limit=50',
      );
      final data = response['incidents'] as List?;
      if (data != null && data.isNotEmpty && mounted) {
        setState(() {
          _communityReports = data.map((e) {
            return {
              'id': e['id'] ?? e['_id'] ?? 'unknown',
              'type': e['incident_type'] ?? 'General',
              'description': e['description'] ?? '',
              'location': e['address'] ?? 'Unknown Location',
              'timestamp': DateTime.tryParse(e['timestamp'] ?? '') ?? DateTime.now(),
              'anonymous': e['is_anonymous'] ?? true,
              'severity': e['severity'] ?? 'medium',
              'isMyReport': false,
            };
          }).toList();
        });
      }
    } catch (e) {
      // Silently fail - mock data is already showing
      print('Background load failed: $e');
    }
  }

  Future<void> _submitReport() async {
    if (_reportController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please describe the incident'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Set submitting to true
    setState(() {
      _isSubmitting = true;
    });

    // Optimistic update - add report immediately
    final newReport = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'type': _selectedIncidentType,
      'description': _reportController.text,
      'location': 'Current Location',
      'timestamp': DateTime.now(),
      'anonymous': _isAnonymous,
      'severity': 'medium',
      'status': 'Pending',
      'isMyReport': true,
    };

    setState(() {
      _myReports.insert(0, newReport);
    });
    _reportController.clear();

    try {
      // Try to submit to server
      await _apiService.post(
        '/reports/incident',
        body: {
          'type': _selectedIncidentType,
          'description': newReport['description'],
          'latitude': 19.0760,
          'longitude': 72.8777,
          'address': 'Current Location',
          'is_anonymous': _isAnonymous,
          'images': [],
        },
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report submitted successfully! 🎉'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      // Report is already added locally, just show a notification
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report saved locally (offline mode)'),
          backgroundColor: Colors.orange,
          duration: Duration(seconds: 2),
        ),
      );
    } finally {
      // Reset submitting state
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _formatTimeAgo(dynamic timestamp) {
    if (timestamp == null) return 'Recently';
    if (timestamp is String) {
      try {
        timestamp = DateTime.parse(timestamp);
      } catch (_) {
        return 'Recently';
      }
    }
    if (timestamp is! DateTime) return 'Recently';
    
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'resolved':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Widget _buildReportCard(Map<String, dynamic> report, {bool isMyReport = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(report['severity'] ?? 'medium'),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    report['type'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (isMyReport && report['status'] != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(report['status']).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getStatusColor(report['status']).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      report['status'],
                      style: TextStyle(
                        color: _getStatusColor(report['status']),
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                const Spacer(),
                if (isMyReport)
                  PopupMenuButton(
                    icon: const Icon(Icons.more_vert, size: 18, color: Color(0xFF1A1A2E)),
                    onSelected: (value) {
                      if (value == 'delete') {
                        _showDeleteConfirmation(report);
                      } else if (value == 'edit') {
                        _showUpdateReportDialog(report);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16, color: Color(0xFF6E3FB0)),
                            SizedBox(width: 8),
                            Text('Edit', style: TextStyle(color: Color(0xFF1A1A2E))),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                Icon(
                  report['anonymous'] ? Icons.person_outline : Icons.person,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  report['anonymous'] ? 'Anonymous' : 'User',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              report['description'],
              style: const TextStyle(
                fontSize: 14, 
                height: 1.4,
                color: Color(0xFF1A1A2E),
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.location_on,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    report['location'],
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(report['timestamp']),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            if (isMyReport)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        _showReportDetails(report);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFF6E3FB0),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        'View Details',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF6E3FB0),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: () {
                        _showUpdateReportDialog(report);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: const Color(0xFFE4406C),
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 30),
                      ),
                      child: const Text(
                        'Update',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFE4406C),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReportDetails(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _getSeverityColor(report['severity'] ?? 'medium'),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                report['type'],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const Spacer(),
            if (report['status'] != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: _getStatusColor(report['status']).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: _getStatusColor(report['status']).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  report['status'],
                  style: TextStyle(
                    color: _getStatusColor(report['status']),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report['description'],
              style: const TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  report['location'],
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  _formatTimeAgo(report['timestamp']),
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  report['anonymous'] ? Icons.person_outline : Icons.person,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  report['anonymous'] ? 'Anonymous' : 'User',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close', style: TextStyle(color: Color(0xFF6E3FB0))),
          ),
        ],
      ),
    );
  }

  void _showUpdateReportDialog(Map<String, dynamic> report) {
    final updateController = TextEditingController(text: report['description']);
    String selectedStatus = report['status'] ?? 'Pending';
    final List<String> statusOptions = ['Pending', 'In Progress', 'Resolved'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Update Report',
          style: TextStyle(color: Color(0xFF1A1A2E)),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: updateController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Update Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.all(12),
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedStatus,
              decoration: const InputDecoration(
                labelText: 'Status',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12),
              ),
              items: statusOptions.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _getStatusColor(status),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                selectedStatus = value!;
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1A1A2E))),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                report['description'] = updateController.text;
                report['status'] = selectedStatus;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report updated successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6E3FB0),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(Map<String, dynamic> report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Delete Report',
          style: TextStyle(color: Color(0xFF1A1A2E)),
        ),
        content: const Text(
          'Are you sure you want to delete this report? This action cannot be undone.',
          style: TextStyle(color: Color(0xFF1A1A2E)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF1A1A2E))),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _myReports.removeWhere((r) => r['id'] == report['id']);
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Report deleted successfully'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Community',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF6E3FB0),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
          tabs: const [
            Tab(text: 'Report'),
            Tab(text: 'Community'),
            Tab(text: 'My Issues'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildReportTab(),
          _buildCommunityTab(),
          _buildMyReportsTab(),
        ],
      ),
    );
  }

  Widget _buildReportTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Report Incident',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Your report helps keep the community safe',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 16),
              // Fixed Dropdown - removed labelText, using hintText instead
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonFormField<String>(
                  value: _selectedIncidentType,
                  decoration: const InputDecoration(
                    hintText: 'Select Incident Type',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                  items: _incidentTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedIncidentType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _reportController,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Describe what happened...\nBe as detailed as possible.',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.all(12),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Checkbox(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value!;
                      });
                    },
                    activeColor: const Color(0xFF6E3FB0),
                  ),
                  const Text(
                    'Report Anonymously',
                    style: TextStyle(fontSize: 14, color: Color(0xFF1A1A2E)),
                  ),
                  const Spacer(),
                  Text(
                    _isAnonymous ? 'Identity hidden' : 'Identity visible',
                    style: TextStyle(
                      fontSize: 12,
                      color: _isAnonymous ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE4406C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Submit Report',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCommunityTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsInBackground,
      child: _communityReports.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.people_outline, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'No community reports yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Be the first to report an incident',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _communityReports.length,
              itemBuilder: (context, index) {
                final report = _communityReports[index];
                return _buildReportCard(report, isMyReport: false);
              },
            ),
    );
  }

  Widget _buildMyReportsTab() {
    return RefreshIndicator(
      onRefresh: _loadReportsInBackground,
      child: _myReports.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.report_problem_outlined, size: 64, color: Colors.grey),
                    SizedBox(height: 16),
                    Text(
                      'You haven\'t reported any issues yet',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap the "Report" tab to report an incident',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _myReports.length,
              itemBuilder: (context, index) {
                final report = _myReports[index];
                return _buildReportCard(report, isMyReport: true);
              },
            ),
    );
  }
}