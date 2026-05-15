import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../viewmodels/navigation_viewmodel.dart';
import '../../core/services/notification_service.dart';

class CustomAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onNotificationTap;
  final bool hasNotification;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.onNotificationTap,
    this.hasNotification = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Container(
        height: 60.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(
            bottom: BorderSide(
              color: Colors.grey.shade200,
              width: 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Bouton Retour ou espace vide
            if (showBackButton)
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new,
                  size: 20.sp,
                  color: Colors.black87,
                ),
                onPressed: () {
                  if (context.canPop()) {
                    context.pop();
                  }
                },
              )
            else
              const SizedBox(width: 48),

            // Titre centré
            Expanded(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Bouton Notification avec badge dynamique (affiché seulement si hasNotification est vrai)
            if (hasNotification)
              GestureDetector(
                onTap: () {
                  ref.read(navigationProvider.notifier).goToTab(2);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.notifications_none,
                        size: 24.sp,
                        color: Colors.black87,
                      ),
                      onPressed: () {
                        ref.read(navigationProvider.notifier).goToTab(2);
                      },
                    ),
                    ref.watch(unreadNotificationsCountProvider).when(
                      data: (count) => count > 0
                          ? Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: BoxDecoration(
                                  color: Colors.red,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 16,
                                  minHeight: 16,
                                ),
                                child: Text(
                                  count > 9 ? '9+' : '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
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
              )
            else
              const SizedBox(width: 48), // Espaceur pour garder le titre centré
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(60.h);
}
