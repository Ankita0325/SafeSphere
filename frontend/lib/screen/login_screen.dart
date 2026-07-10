import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';
import '../services/auth_service.dart';
import '../widgets/loading_widget.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late AnimationController _pulseController;

  static const Color primaryDark = Color(0xFF0A0915);
  static const Color appBackgroundStart = Color(0xFF121026);
  static const Color appBackgroundEnd = Color(0xFF161330);
  static const Color cardBackground = Color(0xFF1E1B4B);
  static const Color vibrantPink = Color(0xFFD92662);
  static const Color vibrantPinkLight = Color(0xFFE11D48);
  static const Color purpleAccent = Color(0xFF7C3AED);
  static const Color highRiskRed = Color(0xFFEF4444);
  static const Color primaryText = Color(0xFFFFFFFF);
  static const Color secondaryText = Color(0xFF9CA3AF);

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);

    return Scaffold(
      backgroundColor: appBackgroundStart,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              appBackgroundStart,
              appBackgroundEnd,
              primaryDark,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 40),
                      _buildEmailField(),
                      const SizedBox(height: 16),
                      _buildPasswordField(),
                      const SizedBox(height: 24),
                      if (authService.error != null)
                        _buildErrorMessage(authService.error!),
                      const SizedBox(height: 20),
                      _buildLoginButton(),
                      const SizedBox(height: 20),
                      _buildFooter(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Center(
      child: Column(
        children: [
          AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              return Transform.scale(
                scale: 1 + (0.05 * sin(_pulseController.value * 2 * pi)),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [vibrantPink, vibrantPinkLight, purpleAccent],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: vibrantPink.withOpacity(0.4),
                        blurRadius: 30,
                        spreadRadius: 10,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.shield,
                    size: 45,
                    color: Colors.white,
                  ),
                ),
              );
            },
          ),
const SizedBox(height: 16),
          const Text(
            'SafeSphere',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: primaryText,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmailField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: vibrantPink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _emailController,
        style: const TextStyle(color: primaryText),
        decoration: InputDecoration(
          labelText: 'Email Address',
          labelStyle: TextStyle(color: secondaryText),
          prefixIcon: const Icon(
            Icons.email_outlined,
            color: purpleAccent,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardBackground,
          contentPadding: const EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cardBackground),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: vibrantPink, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: highRiskRed, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your email';
          }
          if (!value.contains('@')) {
            return 'Please enter a valid email';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: vibrantPink.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: _passwordController,
        style: const TextStyle(color: primaryText),
        obscureText: _obscurePassword,
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: secondaryText),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: purpleAccent,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: cardBackground,
          contentPadding: const EdgeInsets.all(16),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: cardBackground),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: vibrantPink, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(12)),
            borderSide: BorderSide(color: highRiskRed, width: 2),
          ),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility_off : Icons.visibility,
              color: secondaryText,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter your password';
          }
          if (value.length < 6) {
            return 'Password must be at least 6 characters';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highRiskRed.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: highRiskRed.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: highRiskRed, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(color: highRiskRed, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleLogin,
        style: ElevatedButton.styleFrom(
          backgroundColor: vibrantPink,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: vibrantPink.withOpacity(0.4),
        ),
        child: _isLoading
            ? const LoadingWidget()
            : const Text(
                'Log In',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Don't have an account?",
              style: TextStyle(
                fontSize: 14,
                color: secondaryText,
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pushNamed(context, '/register');
              },
              style: TextButton.styleFrom(
                foregroundColor: vibrantPink,
              ),
              child: const Text(
                'Sign Up',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'By continuing, you agree to our Terms & Privacy Policy',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: secondaryText.withOpacity(0.6),
          ),
        ),
      ],
    );
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}