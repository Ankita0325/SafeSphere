import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/safety_score_service.dart';
import '../services/location_service.dart';
import '../services/api_service.dart';
import '../widgets/animated_bottom_nav_bar.dart';
import 'route_screen.dart';
import 'emergency_screen.dart';
import 'community_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeContent(),
    const RouteScreen(),
    const EmergencyScreen(),
    const CommunityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    if (!authService.isAuthenticated) {
      Future.microtask(() {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

// Home Content Widget – welcome card removed
class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoadingNotifications = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchSafetyData();
    });
  }

  Future<void> _fetchSafetyData() async {
    final safetyService = Provider.of<SafetyScoreService>(context, listen: false);
    final locationService = Provider.of<LocationService>(context, listen: false);
    
    try {
      if (locationService.currentPosition != null) {
        await safetyService.fetchSafetyMetrics(
          lat: locationService.currentPosition!.latitude,
          lng: locationService.currentPosition!.longitude,
        );
        await _fetchRecentReports(safetyService.latitude ?? 19.0760, safetyService.longitude ?? 72.8777);
      } else {
        await safetyService.fetchSafetyMetrics();
        await _fetchRecentReports();
      }
    } catch (e) {
      // ignore
    }
  }

  Future<void> _fetchRecentReports([double lat = 19.0760, double lng = 72.8777]) async {
    final apiService = ApiService();
    try {
      final response = await apiService.get(
        '/reports/incidents?lat=$lat&lng=$lng&radius=10&limit=5',
      );
      final reports = response['incidents'] as List?;
      if (reports != null && mounted) {
        setState(() {
          _notifications = reports.map((e) => Map<String, dynamic>.from(e)).toList();
          _isLoadingNotifications = false;
        });
      }
    } catch (e) {
      // Use fallback mock data when API fails
      if (mounted) {
        setState(() {
          _notifications = [
            {
              'incident_type': 'Harassment',
              'address': 'Andheri Station',
              'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
            },
            {
              'incident_type': 'Stalking',
              'address': 'Bandra West',
              'timestamp': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
            },
          ];
          _isLoadingNotifications = false;
        });
      }
    }
  }

  String _getTimeAgo(String timestamp) {
    try {
      final time = DateTime.parse(timestamp);
      final now = DateTime.now();
      final diff = now.difference(time);
      if (diff.inDays > 0) return '${diff.inDays}d ago';
      if (diff.inHours > 0) return '${diff.inHours}h ago';
      if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
      return 'Just now';
    } catch (_) {
      return 'Recently';
    }
  }

  Color _getNotificationColor(String incidentType) {
    final type = incidentType.toLowerCase();
    if (type.contains('harassment') || type.contains('assault')) {
      return Colors.red;
    }
    if (type.contains('theft') || type.contains('stalking')) {
      return Colors.orange;
    }
    return Colors.blue;
  }

  Color _getTrustColor(String color) {
    switch (color.toLowerCase()) {
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safetyService = Provider.of<SafetyScoreService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Home',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF6E3FB0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              _showNotifications(context);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _fetchSafetyData();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSafetyScore(safetyService),
              const SizedBox(height: 16),

              // Quick Actions
              const Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildQuickAction(
                    icon: Icons.heat_pump,
                    label: 'Heatmap',
                    color: Colors.orange,
                    onTap: () {
                      Navigator.pushNamed(context, '/heatmap');
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.support_agent,
                    label: 'Support',
                    color: Colors.purple,
                    onTap: () {
                      Navigator.pushNamed(context, '/support');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Safety Tips
              const Text(
                'Safety Tips',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF7C3AED).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [
                    _buildSafetyTip(
                      icon: Icons.share_location,
                      title: 'Share your location',
                      description: 'Share your live location with trusted contacts',
                    ),
                    const Divider(),
                    _buildSafetyTip(
                      icon: Icons.phone,
                      title: 'Emergency contacts',
                      description: 'Keep emergency contacts updated',
                    ),
                    const Divider(),
                    _buildSafetyTip(
                      icon: Icons.flag,
                      title: 'Report incident',
                      description: 'Report any suspicious activity immediately',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Safety Score Widget – with gradient background
  Widget _buildSafetyScore(SafetyScoreService safetyService) {
    if (safetyService.isLoading) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF6E3FB0), Color(0xFFE4406C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF6E3FB0), Color(0xFFE4406C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row with circular score and labels
          Row(
            children: [
              // Circular progress with score
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: safetyService.overallScore / 100,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Colors.white,
                      ),
                    ),
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '${safetyService.overallScore}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            '/ 100',
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Safety Score',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          safetyService.overallScore >= 70
                              ? Icons.trending_up
                              : Icons.trending_down,
                          color: safetyService.overallScore >= 70
                              ? Colors.green
                              : Colors.orange,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          safetyService.safetyStatus,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.85),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getTrustColor(safetyService.trustColor)
                            .withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: _getTrustColor(safetyService.trustColor)
                                .withOpacity(0.5)),
                      ),
                      child: Text(
                        'Trust: ${safetyService.trustLevel}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.white.withOpacity(0.3), thickness: 1),
          const SizedBox(height: 8),

          // Metric rows with progress bars – using distinct colours
          _buildMetricRow(
            label: 'AI Detection',
            value: safetyService.aiDetectionScore,
            color: const Color(0xFF8A3FFC),
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            label: 'SOS Response',
            value: safetyService.sosResponseScore,
            color: const Color(0xFFE4406C),
          ),
          const SizedBox(height: 8),
          _buildMetricRow(
            label: 'Community Trust',
            value: safetyService.communityTrustScore,
            color: const Color(0xFFFF8A5B),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow({
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 6,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value%',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  // ---- Helper widgets ----
  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 32, color: color),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyTip({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE4406C).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFFE4406C), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showNotifications(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        height: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Community Reports',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _isLoadingNotifications
                  ? const Center(child: CircularProgressIndicator())
                  : _notifications.isEmpty
                      ? const Center(
                          child: Text('No recent reports'),
                        )
                      : ListView.builder(
                          itemCount: _notifications.length,
                          itemBuilder: (context, index) {
                            final report = _notifications[index];
                            return ListTile(
                              leading: Icon(
                                Icons.report,
                                color: _getNotificationColor(
                                    report['incident_type'] ?? ''),
                              ),
                              title: Text(
                                report['incident_type'] ?? 'Incident Reported',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w500),
                              ),
                              subtitle: Text(
                                report['address'] ?? 'Nearby location',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Text(
                                _getTimeAgo(report['timestamp'] ?? ''),
                                style: const TextStyle(fontSize: 12),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
