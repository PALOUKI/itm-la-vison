import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/attendance.dart';
import 'package:vision/presentation/viewmodels/attendance_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';
import 'package:vision/presentation/widgets/attendance_card.dart';

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
      data: (attendance) {
        // Calculer le nombre d'absences qui n'ont ni raison ni ne sont excusées
        final unjustifiedAbsencesCount = attendance.byMonth
            .expand((m) => m.records)
            .where((r) => r.isAbsent && !r.justified)
            .length;

        return Container(
          color: const Color(0xFFF8FAFC),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Alert Section - Uniquement s'il y a des absences sans raison
                if (unjustifiedAbsencesCount > 0)
                  Container(
                    margin: EdgeInsets.all(16.w),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEE2E2),
                      border: Border(
                        left: BorderSide(
                            color: const Color(0xFFDC2626), width: 4.w),
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
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
                                'Vous avez $unjustifiedAbsencesCount absence(s) non justifiée(s). Veuillez régulariser la situation.',
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
                        'STATISTIQUES GLOBALES',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Row(
                        children: [
                          _buildStatItem(
                            icon: Icons.check_circle_outline,
                            count: attendance.overallStats.present.toString(),
                            label: 'Présences',
                            color: const Color(0xFF10B981),
                          ),
                          _buildStatItem(
                            icon: Icons.access_time_outlined,
                            count: attendance.overallStats.late.toString(),
                            label: 'Retards',
                            color: const Color(0xFFF59E0B),
                          ),
                          _buildStatItem(
                            icon: Icons.trending_up_outlined,
                            count:
                                '${attendance.overallStats.getAttendancePercentage().toStringAsFixed(0)}%',
                            label: 'Assiduité',
                            color: const Color(0xFF3B82F6),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Attendance History Section Grouped by Month
                if (attendance.byMonth.isNotEmpty)
                  ...attendance.byMonth
                      .map((monthData) => _buildMonthSection(monthData))
                else
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    child: Text(
                      'Aucune absence ou retard enregistré.',
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 14.sp),
                    ),
                  ),
                SizedBox(height: 20.h),
              ],
            ),
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 32.h),
        child: const Center(
          child: VisionBusyIndicator(size: 30),
        ),
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

  Widget _buildMonthSection(MonthAttendance monthData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'HISTORIQUE - ${monthData.monthLabel.toUpperCase()}',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '${monthData.records.length} records',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        ...monthData.records.map((att) => AttendanceCard(attendance: att)),
      ],
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
}
