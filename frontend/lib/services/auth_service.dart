import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'api_service.dart';
import '../utils/constants.dart';

class AuthService extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _error;
  bool _useMockBackend = true; // Use Mock Backend by default so the app is immediately testable without configuration

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _currentUser != null;
  bool get useMockBackend => _useMockBackend;

  bool _isInitialized = false;

  AuthService() {
    _init();
  }

  Future<void> waitForInit() async {
    while (!_isInitialized) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _useMockBackend = prefs.getBool('use_mock_backend') ?? true;
      final firebaseUser = _auth.currentUser;

      if (_useMockBackend) {
        // Check if user is already logged in from shared preferences
        final isLoggedIn =
            prefs.getBool(AppConstants.PREF_IS_LOGGED_IN) ?? false;
        if (isLoggedIn) {
          final userId = prefs.getString(AppConstants.PREF_USER_ID) ?? '';
          final userName =
              prefs.getString(AppConstants.PREF_USER_NAME) ?? 'User';
          final userEmail = prefs.getString(AppConstants.PREF_USER_EMAIL) ?? '';
          final userPhone = prefs.getString(AppConstants.PREF_USER_PHONE) ?? '';

          if (userId.isNotEmpty) {
            final signupDate = prefs.getString('user_signup_date');
            final sosCount = prefs.getInt(AppConstants.PREF_SOS_TRIGGER_COUNT) ?? 0;
            _currentUser = UserModel(
              uid: userId,
              email: userEmail,
              name: userName,
              phone: userPhone,
              role: 'user',
              emergencyContacts: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
              isVerified: false,
              signupDate: signupDate != null ? DateTime.parse(signupDate) : null,
              sosTriggerCount: sosCount,
            );
          }
        }
      } else if (firebaseUser != null) {
        await _loadUser();
      }
    } catch (e) {
      print('Error initializing AuthService: $e');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUser() async {
    try {
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _currentUser = null;
        return;
      }

      final doc = await _firestore.collection('users').doc(firebaseUser.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _currentUser = UserModel.fromJson({
          'uid': firebaseUser.uid,
          'email': firebaseUser.email ?? '',
          'name': data['name'] ?? firebaseUser.displayName ?? '',
          'phone': data['phone'] ?? data['phone_number'] ?? '',
          'role': data['role'] ?? 'user',
          'emergency_contacts': data['emergency_contacts'] ?? [],
          'created_at': data['created_at'] ?? DateTime.now().toIso8601String(),
          'updated_at': data['updated_at'] ?? DateTime.now().toIso8601String(),
          'is_verified': firebaseUser.emailVerified,
          'signup_date': data['signup_date'] ?? data['created_at'],
          'sos_trigger_count': data['sos_trigger_count'] ?? 0,
        });
      } else {
        _currentUser = UserModel(
          uid: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          name: firebaseUser.displayName ?? '',
          phone: '',
          role: 'user',
          emergencyContacts: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
          isVerified: firebaseUser.emailVerified,
          signupDate: DateTime.now(),
        );
        await _firestore.collection('users').doc(firebaseUser.uid).set(_currentUser!.toJson());
      }

      notifyListeners();
    } catch (e) {
      print('Error loading user: $e');
      if (e.toString().contains('401') || e.toString().contains('403')) {
        await logout();
      }
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useMockBackend) {
        // Mock registration - bypass backend
        await Future.delayed(const Duration(seconds: 1));

        // Validate input
        if (email.isEmpty ||
            password.isEmpty ||
            name.isEmpty ||
            phone.isEmpty) {
          _error = 'All fields are required';
          _isLoading = false;
          notifyListeners();
          return;
        }

        if (password.length < 6) {
          _error = 'Password must be at least 6 characters';
          _isLoading = false;
          notifyListeners();
          return;
        }

        final now = DateTime.now();

        // Generate a mock user
        _currentUser = UserModel(
          uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
          email: email,
          name: name,
          phone: phone,
          role: 'user',
          emergencyContacts: [
            EmergencyContact(
              name: 'Police',
              phone: '112',
              relation: 'Emergency',
              isPrimary: true,
            ),
            EmergencyContact(
              name: 'Women Helpline',
              phone: '1091',
              relation: 'Emergency',
              isPrimary: false,
            ),
          ],
          createdAt: now,
          updatedAt: now,
          isVerified: false,
        );

        // Save to shared preferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.PREF_AUTH_TOKEN,
            'mock_token_${DateTime.now().millisecondsSinceEpoch}');
        await prefs.setString(AppConstants.PREF_USER_ID, _currentUser!.uid);
        await prefs.setString(AppConstants.PREF_USER_NAME, _currentUser!.name);
        await prefs.setString(
            AppConstants.PREF_USER_EMAIL, _currentUser!.email);
        await prefs.setString(
            AppConstants.PREF_USER_PHONE, _currentUser!.phone);
        await prefs.setBool(AppConstants.PREF_IS_LOGGED_IN, true);

        notifyListeners();
        print('✅ Mock registration successful for: $email');
        return;
      }

      // Firebase registration
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();

      _currentUser = UserModel(
        uid: credential.user?.uid ?? '',
        email: credential.user?.email ?? email,
        name: name,
        phone: phone,
        role: 'user',
        emergencyContacts: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isVerified: credential.user?.emailVerified ?? false,
        signupDate: DateTime.now(),
      );

      await _firestore.collection('users').doc(_currentUser!.uid).set({
        'email': _currentUser!.email,
        'name': _currentUser!.name,
        'phone': _currentUser!.phone,
        'role': _currentUser!.role,
        'emergency_contacts': [],
        'created_at': _currentUser!.createdAt.toIso8601String(),
        'updated_at': _currentUser!.updatedAt.toIso8601String(),
        'is_verified': _currentUser!.isVerified,
        'signup_date': _currentUser!.signupDate?.toIso8601String(),
        'sos_trigger_count': _currentUser!.sosTriggerCount,
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.PREF_USER_ID, _currentUser!.uid);
      await prefs.setString(AppConstants.PREF_USER_NAME, _currentUser!.name);
      await prefs.setString(AppConstants.PREF_USER_EMAIL, _currentUser!.email);
      await prefs.setString(AppConstants.PREF_USER_PHONE, _currentUser!.phone);
      await prefs.setBool(AppConstants.PREF_IS_LOGGED_IN, true);

      notifyListeners();
      print('✅ Registration successful for: $email');
    } on FirebaseAuthException catch (e) {
      if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
        print('⚠️ Firebase not configured. Falling back to Mock Backend.');
        await toggleBackendMode(true);
        return register(
          email: email,
          password: password,
          name: name,
          phone: phone,
        );
      }
      _error = _firebaseAuthErrorMessage(e);
      print('❌ Registration error: ${e.code} - ${e.message}');
    } on FirebaseException catch (e) {
      _error = e.message ?? 'Firebase error occurred. Please try again.';
      print('❌ Firebase registration error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = _extractErrorMessage(e);
      print('❌ Registration error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login({required String email, required String password}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (_useMockBackend) {
        // Mock login - bypass backend
        await Future.delayed(const Duration(seconds: 1));

        // Validate credentials
        if (email.isEmpty || password.isEmpty) {
          _error = 'Please enter email and password';
          _isLoading = false;
          notifyListeners();
          return;
        }

        if (password.length < 6) {
          _error = 'Password must be at least 6 characters';
          _isLoading = false;
          notifyListeners();
          return;
        }

        final prefs = await SharedPreferences.getInstance();
        final savedEmail = prefs.getString(AppConstants.PREF_USER_EMAIL);

        final now = DateTime.now();

        if (savedEmail != null && savedEmail.isNotEmpty) {
          // User exists, load from prefs
          final userId =
              prefs.getString(AppConstants.PREF_USER_ID) ?? 'mock_user_123';
          final userName =
              prefs.getString(AppConstants.PREF_USER_NAME) ?? 'User';
          final userPhone = prefs.getString(AppConstants.PREF_USER_PHONE) ?? '';

          _currentUser = UserModel(
            uid: userId,
            email: savedEmail,
            name: userName,
            phone: userPhone,
            role: 'user',
            emergencyContacts: [
              EmergencyContact(
                name: 'Police',
                phone: '112',
                relation: 'Emergency',
                isPrimary: true,
              ),
              EmergencyContact(
                name: 'Women Helpline',
                phone: '1091',
                relation: 'Emergency',
                isPrimary: false,
              ),
            ],
            createdAt: now,
            updatedAt: now,
            isVerified: false,
          );

          // Update login status
          await prefs.setBool(AppConstants.PREF_IS_LOGGED_IN, true);
        } else {
          // Create new mock user (for first-time login)
          _currentUser = UserModel(
            uid: 'mock_${DateTime.now().millisecondsSinceEpoch}',
            email: email,
            name: email.split('@')[0], // Use email prefix as name
            phone: '1234567890',
            role: 'user',
            emergencyContacts: [
              EmergencyContact(
                name: 'Police',
                phone: '112',
                relation: 'Emergency',
                isPrimary: true,
              ),
              EmergencyContact(
                name: 'Women Helpline',
                phone: '1091',
                relation: 'Emergency',
                isPrimary: false,
              ),
            ],
            createdAt: now,
            updatedAt: now,
            isVerified: false,
          );

          // Save to prefs
          await prefs.setString(AppConstants.PREF_AUTH_TOKEN,
              'mock_token_${DateTime.now().millisecondsSinceEpoch}');
          await prefs.setString(AppConstants.PREF_USER_ID, _currentUser!.uid);
          await prefs.setString(
              AppConstants.PREF_USER_NAME, _currentUser!.name);
          await prefs.setString(
              AppConstants.PREF_USER_EMAIL, _currentUser!.email);
          await prefs.setString(
              AppConstants.PREF_USER_PHONE, _currentUser!.phone);
          await prefs.setBool(AppConstants.PREF_IS_LOGGED_IN, true);
          await prefs.setString('mock_password', password); // Store for demo
        }

        notifyListeners();
        print('✅ Mock login successful for: $email');
        return;
      }

      // Firebase login
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final firebaseUser = credential.user;
      if (firebaseUser == null) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Failed to sign in. Please try again.',
        );
      }

      await _loadUser();

      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(AppConstants.PREF_USER_ID, _currentUser!.uid);
        await prefs.setString(AppConstants.PREF_USER_NAME, _currentUser!.name);
        await prefs.setString(AppConstants.PREF_USER_EMAIL, _currentUser!.email);
        await prefs.setString(AppConstants.PREF_USER_PHONE, _currentUser!.phone);
        await prefs.setBool(AppConstants.PREF_IS_LOGGED_IN, true);
      }

      notifyListeners();
      print('✅ Login successful for: $email');
    } on FirebaseAuthException catch (e) {
      if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
        print('⚠️ Firebase not configured. Falling back to Mock Backend.');
        await toggleBackendMode(true);
        return login(email: email, password: password);
      }
      _error = _firebaseAuthErrorMessage(e);
      print('❌ Login error: ${e.code} - ${e.message}');
    } on FirebaseException catch (e) {
      _error = e.message ?? 'Firebase error occurred. Please try again.';
      print('❌ Firebase login error: ${e.code} - ${e.message}');
    } catch (e) {
      _error = _extractErrorMessage(e);
      print('❌ Login error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_useMockBackend) {
        // Mock logout
        await Future.delayed(const Duration(milliseconds: 500));
        _currentUser = null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(AppConstants.PREF_AUTH_TOKEN);
        await prefs.remove(AppConstants.PREF_USER_ID);
        await prefs.remove(AppConstants.PREF_USER_NAME);
        await prefs.remove(AppConstants.PREF_USER_EMAIL);
        await prefs.remove(AppConstants.PREF_USER_PHONE);
        await prefs.remove(AppConstants.PREF_IS_LOGGED_IN);
        await prefs.remove('mock_password'); // Remove stored password

        notifyListeners();
        print('✅ Mock logout successful');
        return;
      }

      // Firebase logout
      await _auth.signOut();
      _currentUser = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConstants.PREF_AUTH_TOKEN);
      await prefs.remove(AppConstants.PREF_USER_ID);
      await prefs.remove(AppConstants.PREF_USER_NAME);
      await prefs.remove(AppConstants.PREF_USER_EMAIL);
      await prefs.remove(AppConstants.PREF_USER_PHONE);
      await prefs.remove(AppConstants.PREF_IS_LOGGED_IN);

      print('✅ Logout successful');
    } catch (e) {
      print('❌ Logout error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Helper method to switch between mock and real backend
  Future<void> toggleBackendMode(bool useMock) async {
    _useMockBackend = useMock;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('use_mock_backend', useMock);
    notifyListeners();
    print('🔄 Backend mode switched to: ${useMock ? "Mock" : "Real"}');
  }

  // Method to check if user is logged in (for splash screen)
  Future<bool> isUserLoggedIn() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(AppConstants.PREF_IS_LOGGED_IN) ?? false;
    } catch (e) {
      print('Error checking login status: $e');
      return false;
    }
  }

  // Helper method to check if user has completed profile
  bool get hasProfileComplete {
    if (_currentUser == null) return false;
    return _currentUser!.name.isNotEmpty &&
        _currentUser!.email.isNotEmpty &&
        _currentUser!.phone.isNotEmpty;
  }

  // Get emergency contacts
  List<EmergencyContact> getEmergencyContacts() {
    return _currentUser?.emergencyContacts ?? [];
  }

  // Add emergency contact
  Future<void> addEmergencyContact({
    required String name,
    required String phone,
    required String relation,
    bool isPrimary = false,
  }) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      final newContact = EmergencyContact(
        name: name,
        phone: phone,
        relation: relation,
        isPrimary: isPrimary,
      );

      if (_useMockBackend) {
        // Mock add contact
        await Future.delayed(const Duration(milliseconds: 500));

        // If this is primary, set all others to non-primary
        List<EmergencyContact> updatedContacts =
            List.from(_currentUser!.emergencyContacts);
        if (isPrimary) {
          updatedContacts = updatedContacts.map((contact) {
            return EmergencyContact(
              name: contact.name,
              phone: contact.phone,
              relation: contact.relation,
              isPrimary: false,
            );
          }).toList();
        }

        updatedContacts.add(newContact);

        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          emergencyContacts: updatedContacts,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
          isVerified: _currentUser!.isVerified,
        );

        notifyListeners();
        print('✅ Emergency contact added: $name');
        return;
      }

      // Firebase add emergency contact
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _error = 'Not authenticated';
        return;
      }

      final updatedContacts = List<Map<String, dynamic>>.from(
          _currentUser?.emergencyContacts.map((e) => e.toJson()).toList() ?? []);
      if (isPrimary) {
        for (var contact in updatedContacts) {
          contact['is_primary'] = false;
        }
      }
      updatedContacts.add(newContact.toJson());

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'emergency_contacts': updatedContacts,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        role: _currentUser!.role,
        emergencyContacts: updatedContacts
            .map((contact) => EmergencyContact.fromJson(contact))
            .toList(),
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        isVerified: _currentUser!.isVerified,
        signupDate: _currentUser!.signupDate,
        sosTriggerCount: _currentUser!.sosTriggerCount,
      );

      notifyListeners();
      print('✅ Emergency contact added: $name');
    } catch (e) {
      _error = _extractErrorMessage(e);
      print('❌ Error adding emergency contact: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Remove emergency contact
  Future<void> removeEmergencyContact(String phone) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      if (_useMockBackend) {
        // Mock remove contact
        await Future.delayed(const Duration(milliseconds: 500));

        final updatedContacts = _currentUser!.emergencyContacts
            .where((contact) => contact.phone != phone)
            .toList();

        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: _currentUser!.email,
          name: _currentUser!.name,
          phone: _currentUser!.phone,
          role: _currentUser!.role,
          emergencyContacts: updatedContacts,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
          isVerified: _currentUser!.isVerified,
        );

        notifyListeners();
        print('✅ Emergency contact removed: $phone');
        return;
      }

      // Firebase remove emergency contact
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _error = 'Not authenticated';
        return;
      }

      final updatedContacts = _currentUser!.emergencyContacts
          .where((contact) => contact.phone != phone)
          .map((contact) => contact.toJson())
          .toList();

      await _firestore.collection('users').doc(firebaseUser.uid).set({
        'emergency_contacts': updatedContacts,
        'updated_at': DateTime.now().toIso8601String(),
      }, SetOptions(merge: true));

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: _currentUser!.email,
        name: _currentUser!.name,
        phone: _currentUser!.phone,
        role: _currentUser!.role,
        emergencyContacts: updatedContacts
            .map((contact) => EmergencyContact.fromJson(contact))
            .toList(),
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        isVerified: _currentUser!.isVerified,
        signupDate: _currentUser!.signupDate,
        sosTriggerCount: _currentUser!.sosTriggerCount,
      );

      notifyListeners();
      print('✅ Emergency contact removed: $phone');
    } catch (e) {
      _error = _extractErrorMessage(e);
      print('❌ Error removing emergency contact: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update user profile
  Future<void> updateUserProfile({
    String? name,
    String? email,
    String? phone,
  }) async {
    if (_currentUser == null) return;

    try {
      _isLoading = true;
      notifyListeners();

      if (_useMockBackend) {
        // Mock update
        await Future.delayed(const Duration(seconds: 1));

        _currentUser = UserModel(
          uid: _currentUser!.uid,
          email: email ?? _currentUser!.email,
          name: name ?? _currentUser!.name,
          phone: phone ?? _currentUser!.phone,
          role: _currentUser!.role,
          emergencyContacts: _currentUser!.emergencyContacts,
          createdAt: _currentUser!.createdAt,
          updatedAt: DateTime.now(),
          isVerified: _currentUser!.isVerified,
          signupDate: _currentUser!.signupDate,
          sosTriggerCount: _currentUser!.sosTriggerCount,
        );

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(AppConstants.PREF_USER_NAME, _currentUser!.name);
        await prefs.setString(
            AppConstants.PREF_USER_EMAIL, _currentUser!.email);
        await prefs.setString(
            AppConstants.PREF_USER_PHONE, _currentUser!.phone);
        if (_currentUser!.signupDate != null) {
          await prefs.setString('user_signup_date', _currentUser!.signupDate!.toIso8601String());
        }

        notifyListeners();
        print('✅ Profile updated successfully');
        return;
      }

      // Firebase profile update
      final firebaseUser = _auth.currentUser;
      if (firebaseUser == null) {
        _error = 'Not authenticated';
        return;
      }

      final updatedData = <String, dynamic>{
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (name != null && name.isNotEmpty) {
        await firebaseUser.updateDisplayName(name);
      }
      if (email != null && email.isNotEmpty && email != firebaseUser.email) {
        await firebaseUser.updateEmail(email);
      }

      await _firestore.collection('users').doc(firebaseUser.uid).set(updatedData, SetOptions(merge: true));

      _currentUser = UserModel(
        uid: _currentUser!.uid,
        email: email ?? _currentUser!.email,
        name: name ?? _currentUser!.name,
        phone: phone ?? _currentUser!.phone,
        role: _currentUser!.role,
        emergencyContacts: _currentUser!.emergencyContacts,
        createdAt: _currentUser!.createdAt,
        updatedAt: DateTime.now(),
        isVerified: firebaseUser.emailVerified,
        signupDate: _currentUser!.signupDate,
        sosTriggerCount: _currentUser!.sosTriggerCount,
      );

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.PREF_USER_NAME, _currentUser!.name);
      await prefs.setString(AppConstants.PREF_USER_EMAIL, _currentUser!.email);
      await prefs.setString(AppConstants.PREF_USER_PHONE, _currentUser!.phone);

      notifyListeners();
      print('✅ Profile updated successfully');
    } catch (e) {
      _error = _extractErrorMessage(e);
      print('❌ Profile update error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Extract meaningful error message
  String _extractErrorMessage(dynamic error) {
    String errorString = error.toString();

    if (errorString.contains('SocketException')) {
      return 'Unable to connect to server. Please check your internet connection.';
    } else if (errorString.contains('FirebaseAuthException')) {
      return 'Authentication failed. Please verify your credentials and try again.';
    } else if (errorString.contains('401')) {
      return 'Invalid email or password. Please try again.';
    } else if (errorString.contains('403')) {
      return 'Access denied. Please login again.';
    } else if (errorString.contains('409')) {
      return 'This email is already registered. Please use a different email or login.';
    } else if (errorString.contains('422')) {
      return 'Invalid data. Please check your input.';
    } else if (errorString.contains('500')) {
      return 'Server error. Please try again later.';
    } else if (errorString.contains('timeout')) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (errorString.contains('FirebaseException')) {
      return 'Firebase connection error. Please try again.';
    }

    // If error contains 'message' field in JSON
    try {
      if (errorString.contains('message')) {
        final start = errorString.indexOf('message') + 10;
        final end = errorString.indexOf('}', start);
        if (start < end) {
          return errorString.substring(start, end).replaceAll('"', '');
        }
      }
    } catch (e) {
      // Fallback to default message
    }

    return 'An unexpected error occurred. Please try again.';
  }

  String _firebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'The email address is invalid. Please check and try again.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'user-not-found':
        return 'No account found with this email. Please sign up first.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please use another email or login.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection and try again.';
      case 'too-many-requests':
        return 'Too many login attempts. Please wait a few minutes and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled. Please contact support.';
      default:
        if (e.message != null && e.message!.contains('CONFIGURATION_NOT_FOUND')) {
          return 'Firebase Auth is not configured. Please enable Email/Password Sign-in in your Firebase Console, or toggle "Demo Mode" at the top-right of the screen.';
        }
        return e.message ?? 'Authentication failed. Please try again.';
    }
  }

  @override
  void dispose() {
    // Clean up if needed
    super.dispose();
  }
}
