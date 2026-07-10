// File: lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'firebase_options.dart';

// Import services
import 'services/auth_service.dart';
import 'services/location_service.dart';
import 'services/emergency_service.dart';
import 'services/voice_service.dart';
import 'services/sms_service.dart';
import 'services/route_service.dart';
import 'services/safety_score_service.dart';

// Import screens (only existing ones)
import 'screen/splash_screen.dart';
import 'screen/onboarding_screen.dart';
import 'screen/home_screen.dart';
import 'screen/login_screen.dart';
import 'screen/register_screen.dart';
import 'screen/emergency_screen.dart';
import 'screen/heatmap_screen.dart';
import 'screen/route_screen.dart';
import 'screen/community_screen.dart';
import 'screen/support_screen.dart';
import 'screen/profile_screen.dart';
import 'screen/my_profile_screen.dart';
import 'screen/emergency_contacts_screen.dart';
import 'screen/emergency_history_screen.dart';
import 'screen/notifications_screen.dart';
import 'screen/location_settings_screen.dart';
import 'screen/safe_maps_screen.dart';

// Import utils
import 'utils/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    // Load environment variables
    await dotenv.load(fileName: '.env');
    print('✅ Environment variables loaded successfully');
    
    // Initialize Firebase
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Initialize App Check for Android and iOS/macOS
    try {
      await FirebaseAppCheck.instance.activate(
        androidProvider: AndroidProvider.playIntegrity,
        appleProvider: AppleProvider.deviceCheck,
      );
      print('✅ Firebase App Check initialized successfully');
    } catch (e) {
      print('⚠️ Firebase App Check initialization failed: $e');
    }

    print('✅ Firebase initialized successfully');
  } catch (e) {
    print('❌ Error during initialization: $e');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => EmergencyService()),
        ChangeNotifierProvider(create: (_) => VoiceService()),
        ChangeNotifierProvider(create: (_) => SmsService()),
        ChangeNotifierProvider(create: (_) => RouteService()),
        ChangeNotifierProvider(create: (_) => SafetyScoreService()),
      ],
      child: MaterialApp(
        title: 'SafeSphere',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/': (context) => const SplashScreen(),
          '/onboarding': (context) => const OnboardingScreen(),
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/register': (context) => const RegisterScreen(),
          '/emergency': (context) => const EmergencyScreen(),
          '/heatmap': (context) => const HeatmapScreen(),
          '/route': (context) => const RouteScreen(),
          '/community': (context) => const CommunityScreen(),
          '/support': (context) => const SupportScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/my-profile': (context) => const MyProfileScreen(),
          '/emergency-contacts': (context) => const EmergencyContactsScreen(),
          '/emergency-history': (context) => const EmergencyHistoryScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/location-settings': (context) => const LocationSettingsScreen(),
          '/safe-maps': (context) => const SafeMapsScreen(),
        },
      ),
    );
  }
}