import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/attendance_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';
import 'package:vision/presentation/widgets/attendance_card.dart';

import '../../config/themes/app_colors.dart';

class AttendancesScreen extends ConsumerWidget {
  final String childUuid;

  const AttendancesScreen({super.key, required this.childUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider(childUuid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Absences & Retards',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: attendanceState.when(
        data: (attendance) => _buildContent(context, attendance),
        loading: () => const AttendanceLoadingView(),
        error: (err, stack) => VisionStateView(
          icon: Icons.event_busy_outlined,
          title: 'Absences indisponibles',
          message: err.toString(),
          actionLabel: 'Réessayer',
          onAction: () => ref.refresh(attendanceProvider(childUuid)),
          accentColor: const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AttendanceResponse attendance) {
    // Calculer le nombre d'absences qui n'ont ni raison ni ne sont excusées
    final unjustifiedAbsencesCount = attendance.byMonth
        .expand((m) => m.records)
        .where((r) => r.isAbsent && !r.justified)
        .length;

    return SingleChildScrollView(
      child: Column(
        children: [
          // Alert Section - Uniquement s'il y a des absences sans raison
          if (unjustifiedAbsencesCount > 0)
            _buildAlertSection(unjustifiedAbsencesCount),

          // Statistics Section
          _buildStatisticsSection(attendance),

          // Monthly Sections
          ...attendance.byMonth.map((monthData) => _buildMonthSection(monthData)),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildAlertSection(int count) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.only(top: 16.w, bottom: 16.w, right: 16.w),
      decoration: BoxDecoration(
          color: const Color(0xFFFEE2E2),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(12.w),
              bottomRight: Radius.circular(12.w)),
          border: Border(
              left: BorderSide(
            color: const Color(0xFFDC2626),
            width: 4.w,
          ))),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.warning_rounded,
              color: const Color(0xFFDC2626), size: 24.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Absences à justifier !',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFDC2626),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Vous avez $count absence(s) non justifiée(s). Veuillez régulariser la situation.',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: const Color(0xFFB91C1C),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection(AttendanceResponse attendance) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Text(
            'STATISTIQUES GLOBALES',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade500,
            ),
          ),
        ),
        SizedBox(height: 6.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.calendar_month,
                count: attendance.overallStats.absent.toString(),
                label: 'ABSENCES',
                color: const Color(0xFFEF4444),
              ),
              _buildStatCard(
                icon: Icons.access_time_outlined,
                count: attendance.overallStats.late.toString(),
                label: 'RETARDS',
                color: AppColors.darkBlue,
              ),
              _buildStatCard(
                icon: Icons.trending_up_outlined,
                count:
                    '${attendance.overallStats.getAttendancePercentage().toStringAsFixed(0)}%',
                label: 'ASSIDUITE',
                color: Colors.grey.shade800,
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 5.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              blurRadius: 2,
              color: Colors.black.withValues(alpha: 0.05),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            Text(
              count,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade800,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthSection(MonthAttendance monthData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTORIQUE RÉCENT',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                child: Text(
                  monthData.monthLabel.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...monthData.records.map((att) => AttendanceCard(attendance: att)),
      ],
    );
  }
}
