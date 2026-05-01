import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';

class HomeHeader extends StatelessWidget {
  final VoidCallback onNotificationTap;

  const HomeHeader({
    super.key,
    required this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo à gauche
          Image.asset(
            AppConstants.appLogoPath,
            width: 40.w,
            height: 40.h,
          ),
          
          // Notification à droite
          GestureDetector(
            onTap: onNotificationTap,
            child: Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFF1e3a8a).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    size: 24.sp,
                    color: const Color(0xFF1e3a8a),
                  ),
                  Positioned(
                    right: 2,
                    top: 2,
                    child: Container(
                      width: 8.w,
                      height: 8.w,
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

