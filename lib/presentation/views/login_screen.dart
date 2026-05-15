import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late final Connectivity _connectivity;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isPasswordVisible = false;
  bool _hasNetwork = true;
  String? _emailError;
  String? _passwordError;

  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _initializeConnectivity();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _initializeConnectivity() async {
    final initialResults = await _connectivity.checkConnectivity();
    _updateConnectivityState(initialResults);

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _updateConnectivityState,
    );
  }

  void _updateConnectivityState(List<ConnectivityResult> results) {
    if (!mounted) return;

    final hasNetwork = !results.contains(ConnectivityResult.none);

    if (_hasNetwork != hasNetwork) {
      setState(() {
        _hasNetwork = hasNetwork;
      });
    }
  }

  bool _validateInputs() {
    setState(() {
      _emailError = null;
      _passwordError = null;
    });

    bool isValid = true;

    if (_emailController.text.isEmpty) {
      setState(() => _emailError = "L'email est requis");
      isValid = false;
    } else if (!_isValidEmail(_emailController.text)) {
      setState(() => _emailError = 'Veuillez entrez un email valide');
      isValid = false;
    }

    if (_passwordController.text.isEmpty) {
      setState(() => _passwordError = 'Lemot de passe est requis');
      isValid = false;
    } else if (_passwordController.text.length < 6) {
      setState(() => _passwordError = 'Le mot de passe doit contenir au moins 6 caractères');
      isValid = false;
    }

    return isValid;
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegex.hasMatch(email);
  }

  void _openHelp() {
    context.push('/help');
  }

  void _openTerms() {
    context.push('/terms');
  }

  void _openPrivacy() {
    context.push('/privacy');
  }

  void _handleLogin() async {
    if (!_validateInputs()) return;
    if (!_hasNetwork) {
      _showErrorSnackBar(
        'Aucune connexion internet détectée. Connectez-vous à un réseau puis réessayez.',
      );
      return;
    }

    try {
      await ref.read(authStateProvider.notifier).login(
            _emailController.text.trim(),
            _passwordController.text,
          );
      // ✅ Pas besoin de redirection explicite ici :
      // le `redirect` de GoRouter dans app_router.dart
      // détecte le passage à `AuthStateAuthenticated` et va à /home.
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.toString());
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 40.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 40.h),
              // Logo
              Image.asset(
                'assets/images/logo.png',
                width: 80.w,
                height: 80.h,
              ),
              SizedBox(height: 24.h),
              // Title
              Text(
                'Portail Parent',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              // Subtitle
              Text(
                'Suivi académique en temps réel',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey,
                ),
              ),
              if (!_hasNetwork) ...[
                SizedBox(height: 24.h),
                _buildOfflineBanner(),
              ],
              SizedBox(height: 40.h),
              // Email Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email ou Téléphone',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      hintText: 'parent@example.com',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      prefixIcon: Icon(
                        Icons.email_outlined,
                        color: Colors.grey,
                        size: 20.sp,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: _emailError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: _emailError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF1e3a8a),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    enabled: !isLoading,
                  ),
                  if (_emailError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        _emailError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 24.h),
              // Password Field
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Mot de passe',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      GestureDetector(
                        onTap: _openHelp,
                        child: Text(
                          'Oublié ?',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF1e3a8a),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre mot de passe',
                      hintStyle: TextStyle(color: Colors.grey, fontSize: 12.sp),
                      prefixIcon: Icon(
                        Icons.lock_outline,
                        color: Colors.grey,
                        size: 20.sp,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                        child: Icon(
                          _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                          color: Colors.grey,
                          size: 20.sp,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: _passwordError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(
                          color: _passwordError != null ? Colors.red : Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: const BorderSide(
                          color: Color(0xFF1e3a8a),
                          width: 2,
                        ),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 14.h,
                      ),
                    ),
                    enabled: !isLoading,
                  ),
                  if (_passwordError != null)
                    Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        _passwordError!,
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12.sp,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: 32.h),
              // Login Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading || !_hasNetwork ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1e3a8a),
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: isLoading
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: const VisionBusyIndicator(
                            size: 20,
                            color: Colors.white,
                            trackColor: Colors.white24,
                            strokeWidth: 2,
                            showHalo: false,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Se Connecter',
                              style: TextStyle(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward,
                              size: 18.sp,
                              color: Colors.white,
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: 16.h),
              // Help Button
              OutlinedButton(
                onPressed: _openHelp,
                style: OutlinedButton.styleFrom(
                  minimumSize: Size(double.infinity, 48.h),
                  side: BorderSide(color: Colors.grey.shade300),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.help_outline,
                      size: 18.sp,
                      color: Colors.black,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Besoin d\'aide pour vous connecter ?',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 32.h),
              // Footer
              Column(
                children: [
                  Text(
                    'En vous connectant, vous acceptez nos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: _openTerms,
                        child: Text(
                          'Conditions d\'Utilisation',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF1e3a8a),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      Text(
                        ' et notre ',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey,
                        ),
                      ),
                      GestureDetector(
                        onTap: _openPrivacy,
                        child: Text(
                          'Politique de Confidentialité',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: const Color(0xFF1e3a8a),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    '© 2026 ITM LA VISION - Version 2.4.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF4E5),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFF59E0B).withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: const Color(0xFFF59E0B).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.wifi_off_rounded,
              color: const Color(0xFFB45309),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Aucune connexion détectée',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF92400E),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Connectez votre appareil à internet pour vous authentifier et synchroniser vos données.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    height: 1.45,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
