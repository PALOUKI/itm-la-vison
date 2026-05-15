import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.watch(authStateProvider);

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
                Container(
                  width: 40.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 8.h),
                  decoration: BoxDecoration(
                    color: const Color(0xffe74c0d),
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
                //const VisionBusyIndicator(size: 38),
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
