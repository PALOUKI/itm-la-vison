import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/attendance.dart';

class AttendanceCard extends StatefulWidget {
  final Attendance attendance;

  const AttendanceCard({super.key, required this.attendance});

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard> {
  bool _showJustificationInstruction = false;

  @override
  Widget build(BuildContext context) {
    final attendance = widget.attendance;
    final isAbsent = attendance.isAbsent;
    final isLate = attendance.isLate;
    final isExcused = attendance.isExcused;

    Color statusColor = Colors.grey;
    IconData statusIcon = Icons.help_outline;

    if (isAbsent) {
      statusColor = attendance.justified ? const Color(0xFF10B981) : const Color(0xFFEF4444);
      statusIcon = attendance.justified ? Icons.check_circle_outline : Icons.event_busy_outlined;
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        padding: EdgeInsets.only(left: 12.w),
        decoration: BoxDecoration(
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
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
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
                      attendance.teacher!.name,
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],
            if (attendance.reason != null && attendance.reason!.isNotEmpty) ...[
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
                        attendance.reason!,
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
            if (!attendance.justified && (isAbsent || isLate)) ...[
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () {
                    if (attendance.reason == null || attendance.reason!.isEmpty) {
                      setState(() {
                        _showJustificationInstruction = true;
                      });
                      return;
                    }

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Justification en développement')),
                    );
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                    padding: EdgeInsets.symmetric(vertical: 10.h),
                  ),
                  child: Text(
                    isAbsent ? 'Justifier l\'absence' : 'Justifier le retard',
                    style: TextStyle(
                      color: const Color(0xFF1E3A8A),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (_showJustificationInstruction && (attendance.reason == null || attendance.reason!.isEmpty))
                Padding(
                  padding: EdgeInsets.only(top: 8.h),
                  child: Text(
                    'Le parent doit se rendre à l\'école pour la justification.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFDC2626),
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
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
