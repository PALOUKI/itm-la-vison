import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // ❌ Ne plus réinitialiser l'auth ici : cela entrait en conflit
    // avec l'initialisation déclenchée dans AuthNotifier.build.
    // _initializeApp();
  }

  // On garde la méthode pour plus tard si on veut faire d'autres
  // initialisations (remote config, etc.), mais sans toucher à l'auth.
  Future<void> _initializeApp() async {
    // Initialiser l'authentification (restauration token / user)
    await ref.read(authStateProvider.notifier).initializeAuth();

    // Attendre 2 secondes pour l'effet du splash screen
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // ❗️On ne fait PLUS de navigation manuelle ici
    // GoRouter + redirect (dans app_router.dart) décident où aller
    // en fonction de authState (authenticated ou non).
  }

  @override
  Widget build(BuildContext context) {
    // On peut regarder l'état pour éventuellement adapter l'UI plus tard
    final authState = ref.watch(authStateProvider);
    // debugPrint('Splash authState: $authState');

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  AppConstants.appLogoPath,
                  width: 120.w,
                  height: 120.h,
                ),
                SizedBox(height: 24.h),
                // App Name
                Text(
                  'ITM LA VISION',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                // Tagline
                Text(
                  '« La Réussite est assurée »',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                SizedBox(height: 48.h),
                // Loading Indicator
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1e3a8a)),
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 24.h,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                '© INSTITUT TECHNIQUE ET MODERNE © 2024',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
