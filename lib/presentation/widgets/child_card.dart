import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/core/utils/image_utils.dart';

class ChildCard extends ConsumerWidget {
  final Child child;
  final bool isSelected;
  final VoidCallback onTap;

  const ChildCard({
    super.key,
    required this.child,
    required this.isSelected,
    required this.onTap,
  });

  Widget _buildPlaceholder() {
    // Get initials from fullName
    String initials = '';
    if (child.fullName.isNotEmpty) {
      final names = child.fullName.trim().split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[names.length - 1][0]}';
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        initials = names[0][0];
      }
    }

    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF1e3a8a),
          fontWeight: FontWeight.bold,
          fontSize: 20.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch notifications for this specific child
    final notificationCount = ref.watch(childNotificationsCountProvider(child.id));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        margin: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: Colors.grey.shade100,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Photo Enfant avec Badge Notification
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 60.w,
                  height: 60.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1e3a8a).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16.r),
                    child: ImageUtils.getImageUrl(child.displayPhoto) != null
                        ? Image.network(
                            ImageUtils.getImageUrl(child.displayPhoto)!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Erreur chargement image élève: ${ImageUtils.getImageUrl(child.displayPhoto)}');
                              return _buildPlaceholder();
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: SizedBox(
                                  width: 20.w,
                                  height: 20.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                    color: const Color(0xFF1e3a8a).withOpacity(0.3),
                                  ),
                                ),
                              );
                            },
                          )
                        : _buildPlaceholder(),
                  ),
                ),
                // Badge Notification sur la photo
                if (notificationCount > 0)
                  Positioned(
                    top: -5,
                    right: -5,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      constraints: BoxConstraints(
                        minWidth: 22.w,
                        minHeight: 22.w,
                      ),
                      child: Text(
                        notificationCount > 9 ? '9+' : notificationCount.toString(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(width: 16.w),
            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    child.fullName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1e3a8a),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Text(
                          child.currentEnrollment?.classData.name ?? 'N/A',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        child.matricule,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Flèche de navigation dans un cercle gris
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.grey.shade400,
                size: 14.sp,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
