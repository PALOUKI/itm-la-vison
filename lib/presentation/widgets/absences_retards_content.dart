import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/attendance_viewmodel.dart';

class AbsencesRetardsContent extends ConsumerWidget {
  final String childUuid;

  const AbsencesRetardsContent({
    super.key,
    required this.childUuid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final attendanceState = ref.watch(attendanceProvider(childUuid));

    return attendanceState.when(
      data: (attendance) => Container(
        color: const Color(0xFFF8FAFC),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Alert Section
            if (attendance.stats.absent > 0)
              Container(
                margin: EdgeInsets.all(16.w),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  border: Border(
                    left: BorderSide(color: const Color(0xFFDC2626), width: 4.w),
                  ),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                  child: Row(
                    children: [
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
                ),

              // Statistics Section
              Container(
                padding: EdgeInsets.all(16.w),
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'STATISTIQUES DU MOIS',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      attendance.period.start.split('-').sublist(0, 2).join('/'),
                      style: TextStyle(fontSize: 10.sp, color: Colors.grey.shade500),
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        _buildStatItem(
                          icon: Icons.check_circle_outline,
                          count: attendance.stats.present.toString(),
                          label: 'Présences',
                          color: const Color(0xFF10B981),
                        ),
                        _buildStatItem(
                          icon: Icons.access_time_outlined,
                          count: attendance.stats.late.toString(),
                          label: 'Retards',
                          color: const Color(0xFFF59E0B),
                        ),
                        _buildStatItem(
                          icon: Icons.trending_up_outlined,
                          count: '${attendance.stats.getAttendancePercentage().toStringAsFixed(0)}%',
                          label: 'Assiduité',
                          color: const Color(0xFF3B82F6),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Attendance History Section
            if (attendance.attendances.isNotEmpty) ...[
              SizedBox(height: 16.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'HISTORIQUE RÉCENT',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade600,
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
                          color: const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              ...attendance.attendances.map((att) => _buildAttendanceCard(att)),
            ] else
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.h),
                  child: Text(
                    'Aucune absence ou retard enregistré.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                  ),
                ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const CircularProgressIndicator(),
      ),
      error: (err, stack) => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 16.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48.sp, color: Colors.red),
            SizedBox(height: 16.h),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                color: Colors.red,
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              err.toString(),
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 12.sp),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String count,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24.sp),
            SizedBox(height: 8.h),
            Text(
              count,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(Attendance attendance) {
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
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: statusColor, width: 4.w),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
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
          if (attendance.teacher != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.person_outline, size: 16.sp, color: Colors.grey.shade600),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    attendance.teacher!.fullName,
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
                },
                style: TextButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
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
    );
  }

  String _formatDate(DateTime date) {
    final days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    final dayName = days[date.weekday - 1];
    return '$dayName ${date.day.toString().padLeft(2, '0')} ${_getMonthName(date.month)} ${date.year}';
  }

  String _getMonthName(int month) {
    final months = [
      'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
      'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
    ];
    return months[month - 1];
  }
}
