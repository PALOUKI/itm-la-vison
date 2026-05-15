import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/core/utils/image_utils.dart';
import 'package:vision/domain/models/child.dart' as child_models;
import 'package:vision/presentation/viewmodels/child_detail_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

class ChildDetailScreen extends ConsumerStatefulWidget {
  final String childUuid;
  const ChildDetailScreen({super.key, required this.childUuid});

  @override
  ConsumerState<ChildDetailScreen> createState() => _ChildDetailScreenState();
}

class _ChildDetailScreenState extends ConsumerState<ChildDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final childState = ref.watch(childDetailProvider(widget.childUuid));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'Menu',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: childState.when(
        data: (child) => SingleChildScrollView(
          child: Column(
            children: [
              _buildProfileHeader(child),
              SizedBox(height: 16.h),

              _buildMenuItem(
                icon: Icons.school_outlined,
                title: 'Notes & Résultats',
                badgeCount: ref.watch(childSectionNotificationProvider((studentId: child.id, type: 'grades_published'))),
                onTap: () => context.push('/home/child-detail/${child.uuid}/grades', extra: child),
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Bulletins Scolaires',
                onTap: () => context.push('/home/child-detail/${child.uuid}/bulletins', extra: child),
              ),
              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Emploi du temps',
                onTap: () => context.push('/home/child-detail/${child.uuid}/timetable'),
              ),
              _buildMenuItem(
                icon: Icons.access_time_outlined,
                title: 'Absences / Retards',
                badgeCount: ref.watch(childSectionNotificationProvider((studentId: child.id, type: 'attendance_recorded'))),
                onTap: () => context.push('/home/child-detail/${child.uuid}/attendances'),
              ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Paiements',
                badgeCount: ref.watch(childSectionNotificationProvider((studentId: child.id, type: 'payment_received'))),
                onTap: () => context.push('/home/child-detail/${child.uuid}/finances'),
              ),
              _buildMenuItem(
                icon: Icons.chat_bubble_outline_outlined,
                title: 'Communications',
                onTap: () => context.push('/home/child-detail/${child.uuid}/messages'),
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        loading: () => const ChildDetailLoadingView(),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
      ),
    );
  }

  Widget _buildProfileHeader(child_models.Child child) {
    String lastLoginText;
    if (child.user?.lastLoginAt != null) {
      lastLoginText =
          DateFormat('dd/MM/yyyy \'à\' HH:mm').format(child.user!.lastLoginAt!);
    } else {
      lastLoginText = 'Aucune';
    }

    // Get initials for placeholder
    String initials = '';
    if (child.fullName.isNotEmpty) {
      final names = child.fullName.trim().split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[names.length - 1][0]}';
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        initials = names[0][0];
      }
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 24.h),
      color: const Color(0xFFF0F5FF).withOpacity(0.5),
      child: Column(
        children: [
          Container(
            width: 80.w,
            height: 80.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
            ),
            child: ClipOval(
              child: ImageUtils.getImageUrl(child.displayPhoto) != null
                  ? Image.network(
                      ImageUtils.getImageUrl(child.displayPhoto)!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Text(
                          initials.toUpperCase(),
                          style: TextStyle(
                            color: const Color(0xFF1E3A8A),
                            fontWeight: FontWeight.bold,
                            fontSize: 28.sp,
                          ),
                        ),
                      ),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: const Color(0xFF1E3A8A).withOpacity(0.3),
                          ),
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        initials.toUpperCase(),
                        style: TextStyle(
                          color: const Color(0xFF1E3A8A),
                          fontWeight: FontWeight.bold,
                          fontSize: 28.sp,
                        ),
                      ),
                    ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            child.fullName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 4.h),
          Text(
            '${child.currentEnrollment?.classData.name ?? 'N/A'} • Lycée ${child.currentEnrollment?.classData.establishmentType ?? ''}',
            style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: const Color(0xFF475569)),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.access_time, size: 14.sp, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                'Dernière connexion : $lastLoginText',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE0E7FF),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(icon, color: const Color(0xFF1E3A8A), size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B)),
              ),
            ),
            if (badgeCount > 0)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)),
                child: Text(badgeCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
              ),
            SizedBox(width: 8.w),
            Icon(
              Icons.keyboard_arrow_right,
              color: Colors.grey.shade400,
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
