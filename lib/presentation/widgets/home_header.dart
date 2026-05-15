import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/presentation/viewmodels/navigation_viewmodel.dart';

class HomeHeader extends ConsumerWidget {
  final VoidCallback? onNotificationTap;

  const HomeHeader({
    super.key,
    this.onNotificationTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Logo de l'école à gauche
          Image.asset(
            'assets/images/logo.png',
            height: 40.h,
            errorBuilder: (context, error, stackTrace) => Icon(
              Icons.school_rounded,
              color: const Color(0xFF1E3A8A),
              size: 32.sp,
            ),
          ),

          // Icône Notification à droite (Sans cercle gris, avec Badge rouge)
          GestureDetector(
            onTap: onNotificationTap ?? () => ref.read(navigationProvider.notifier).goToTab(2),
            child: SizedBox(
              width: 44.w,
              height: 44.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Icon(
                    Icons.notifications_none_rounded,
                    color: Colors.black87,
                    size: 28.sp,
                  ),
                  ref.watch(unreadNotificationsCountProvider).when(
                    data: (count) => count > 0
                        ? Positioned(
                            top: 8.h,
                            right: 8.w,
                            child: Container(
                              padding: EdgeInsets.all(2.w),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEF4444),
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              constraints: BoxConstraints(
                                minWidth: 16.w,
                                minHeight: 16.w,
                              ),
                              child: Text(
                                count > 9 ? '9+' : count.toString(),
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
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
