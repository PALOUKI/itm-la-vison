import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/attendance_viewmodel.dart';

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
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $err', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => ref.refresh(attendanceProvider(childUuid)),
                child: const Text("Réessayer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, AttendanceResponse attendance) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Alert Section
          if (attendance.stats.absent > 0) _buildAlertSection(attendance),

          // Statistics Section
          _buildStatisticsSection(attendance),

          // Attendance History Section
          if (attendance.attendances.isNotEmpty) _buildHistorySection(attendance, context),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildAlertSection(AttendanceResponse attendance) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.only(top: 16.w, bottom: 16.w, right: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFEE2E2),
        borderRadius: BorderRadius.only(topRight: Radius.circular(12.w), bottomRight: Radius.circular(12.w)),
        border: Border(
          left: BorderSide(
            color: Color(0xFFDC2626),
            width: 4.w,
          )
        )
      ),
      child: Row(
        children: [
          SizedBox(width: 12.w),
          Icon(Icons.warning_rounded, color: const Color(0xFFDC2626), size: 24.sp),
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
                  'Vous avez ${attendance.stats.absent} absence(s) non justifiée(s). Veuillez régulariser la situation.',
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
        // Title section (like "HISTORIQUE RÉCENT")
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STATISTIQUES DU MOIS',
                style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
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
                  'OCTOBRE 2024',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color:  Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            ],
          ),
        ),
        SizedBox(height: 6.h),
        // Three separate cards
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w,),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildStatCard(
                icon: Icons.calendar_month,
                count: attendance.stats.absent.toString(),
                label: 'ABSENCES',
                color: const Color(0xFFEF4444),
              ),
              _buildStatCard(
                icon: Icons.access_time_outlined,
                count: attendance.stats.late.toString(),
                label: 'RETARDS',
                color: AppColors.darkBlue,
              ),
              _buildStatCard(
                icon: Icons.trending_up_outlined,
                count: '${attendance.stats.getAttendancePercentage().toStringAsFixed(0)}%',
                label: 'ASSIDIUTE',
                color:  Colors.grey.shade800,
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
            // Round icon container
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20.sp),
            ),
            SizedBox(height: 10.h),
            // Count
            Text(
              count,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E293B),
              ),
            ),
            SizedBox(height: 4.h),
            // Label
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

  Widget _buildHistorySection(AttendanceResponse attendance, BuildContext context) {
    return Column(
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
              GestureDetector(
                onTap: () {
                  // TODO: Show full history
                },
                child: Text(
                  'Voir tout',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ),
            ],
          ),
        ),
        ...attendance.attendances.map((att) => _buildAttendanceCard(att, context)),
      ],
    );
  }

  Widget _buildAttendanceCard(Attendance attendance, BuildContext context) {
    final isAbsent = attendance.status == 'absent';
    final isLate = attendance.status == 'late';
    final isExcused = attendance.status == 'excused';

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (isAbsent) {
      statusColor = const Color(0xFFEF4444);
      statusIcon = Icons.event_busy_outlined;
    } else if (isLate) {
      statusColor = const Color(0xFFF59E0B);
      statusIcon = Icons.access_time_outlined;
    } else if (isExcused) {
      statusColor = const Color(0xFF10B981);
      statusIcon = Icons.check_circle_outline;
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.only(right: 16.w, top: 8.h, bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12.w),
        decoration:(
          BoxDecoration(
            border: Border(
              left: BorderSide(color: statusColor, width: 4.w)
            )
          )
        ),
        child: Column(
          children: [

            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(10.w),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(statusIcon, color: statusColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        attendance.subject?.name ?? 'Cours',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Jour : ${_formatDate(attendance.date)}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (!attendance.justified && isAbsent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      'Non justifiée',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Icon(Icons.schedule_outlined, size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Text(
                  '${attendance.startTime} - ${attendance.endTime}',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ],
            ),
            if (attendance.schedule?.teacher != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.person_outline, size: 16.sp, color: Colors.grey.shade600),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      attendance.schedule!.teacher!.fullName,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (attendance.reason != null) ...[
              SizedBox(height: 12.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16.sp, color: Colors.grey.shade600),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        attendance.reason ?? '',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (!attendance.justified && isAbsent) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    // TODO: Implement justification logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Justification en développement')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    'Justifier l\'absence',
                    style: TextStyle(
                      color: const Color(0xFF1E3A8A),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final dayName = days[date.weekday - 1];
    return '$dayName ${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    const months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }
}

