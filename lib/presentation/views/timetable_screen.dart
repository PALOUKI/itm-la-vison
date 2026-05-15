import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/domain/models/timetable.dart';
import 'package:vision/presentation/viewmodels/timetable_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

import '../../config/themes/app_colors.dart';

class TimetableScreen extends ConsumerStatefulWidget {
  final String childUuid;

  const TimetableScreen({super.key, required this.childUuid});

  @override
  ConsumerState<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends ConsumerState<TimetableScreen> {
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    selectedDate = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    final timetableState = ref.watch(timetableProvider(widget.childUuid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Emploi du temps',
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
      body: timetableState.when(
        data: (timetable) => _buildContent(context, timetable),
        loading: () => const TimetableLoadingView(),
        error: (err, stack) => VisionStateView(
          icon: Icons.calendar_month_outlined,
          title: 'Emploi du temps indisponible',
          message: err.toString(),
          actionLabel: 'Réessayer',
          onAction: () => ref.refresh(timetableProvider(widget.childUuid)),
          accentColor: const Color(0xFFDC2626),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, TimetableResponse timetable) {
    // Get first and last date from timetable items to determine week range
    if (timetable.items.isEmpty) {
      return const VisionStateView(
        icon: Icons.calendar_view_week_outlined,
        title: 'Aucun emploi du temps disponible',
        message: 'Le planning des cours sera affiché ici dès sa publication.',
      );
    }

    // Group items by date
    final itemsByDate = _groupItemsByDate(timetable.items);

    // Trouver la première et dernière date pour déterminer la semaine
    final allDatesWithCourses = itemsByDate.keys.toList()..sort();
    if (allDatesWithCourses.isEmpty) {
      return const VisionStateView(
        icon: Icons.calendar_view_week_outlined,
        title: 'Aucun emploi du temps disponible',
        message: 'Le planning hebdomadaire n’est pas encore disponible pour cette période.',
      );
    }

    // Générer la semaine complète à partir du lundi de la première date
    final firstDate = allDatesWithCourses.first;
    final weekStart = _getMonday(firstDate);
    final allDaysOfWeek = List.generate(7, (index) => weekStart.add(Duration(days: index)));

    // Utiliser la date sélectionnée (sans heure) ou le jour d'aujourd'hui
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Si la date sélectionnée n'a pas de cours, la réinitialiser au jour d'aujourd'hui ou au premier jour avec cours
    DateTime currentSelected = DateTime(selectedDate.year, selectedDate.month, selectedDate.day);
    if (!itemsByDate.containsKey(currentSelected)) {
      currentSelected = allDatesWithCourses.contains(today) ? today : allDatesWithCourses.first;
    }

    final itemsForSelectedDate = itemsByDate[currentSelected] ?? [];

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 6.h),

          // White card containing days selector and day title
          _buildHeaderCard(allDaysOfWeek, currentSelected, itemsForSelectedDate),

          SizedBox(height: 12.h),

          // Timetable content - courses for the selected day
          if (itemsForSelectedDate.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
              child: VisionStateView(
                icon: Icons.event_available_outlined,
                title: 'Aucun cours ce jour',
                message: 'Profitez de ce temps libre pour réviser ou vous reposer !',
                compact: true,
                accentColor: Colors.grey.shade400,
              ),
            )
          else
            ...itemsForSelectedDate.map((item) => _buildTimetableItem(item)),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildHeaderCard(List<DateTime> dates, DateTime selectedDateOnly, List<TimetableItem> dayItems) {
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);

    return Container(
      //margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: const BoxDecoration(
        color: Colors.white,
        //borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          // Days selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: dates.map((date) => _buildDayButton(date, selectedDateOnly)).toList(),
            ),
          ),
          SizedBox(height: 16.h),

          // Day title and status badge
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDateFull(selectedDateOnly),
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    _formatDateForDisplay(selectedDateOnly),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              if (selectedDateOnly == todayOnly)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.check_circle, size: 14.sp, color: const Color(0xFF10B981)),
                      SizedBox(width: 6.w),
                      Text(
                        'Aujourd\'hui',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Map<DateTime, List<TimetableItem>> _groupItemsByDate(List<TimetableItem> items) {
    final grouped = <DateTime, List<TimetableItem>>{};
    for (var item in items) {
      final dateOnly = DateTime(item.startTime.year, item.startTime.month, item.startTime.day);
      grouped.putIfAbsent(dateOnly, () => []);
      grouped[dateOnly]!.add(item);
    }
    grouped.forEach((key, value) {
      value.sort((a, b) => a.startTime.compareTo(b.startTime));
    });
    return grouped;
  }

  Widget _buildDayButton(DateTime date, DateTime selectedDateOnly) {
    final dayName = _getDayName(date.weekday);
    final dayNumber = date.day;
    final now = DateTime.now();
    final todayOnly = DateTime(now.year, now.month, now.day);
    final isSelected = date == selectedDateOnly;
    final isToday = date == todayOnly;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedDate = date;
        });
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.w),
        padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 18.w),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.darkBlue : (isToday ? Colors.grey.shade100 : Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              dayNumber.toString(),
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              dayName,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getColorForSubject(String code, String name) {
    final String cleanCode = code.toUpperCase();
    
    // Definitive colors for common subjects
    if (cleanCode.contains('MATH')) return const Color(0xFF3B82F6); // Blue
    if (cleanCode.contains('PC') || cleanCode.contains('PHYS')) return const Color(0xFFEF4444); // Red
    if (cleanCode.contains('SVT') || cleanCode.contains('BIO')) return const Color(0xFF10B981); // Green
    if (cleanCode.contains('HG') || cleanCode.contains('HIST') || cleanCode.contains('GEO')) return const Color(0xFFF59E0B); // Amber
    if (cleanCode.contains('FR') || cleanCode.contains('LITT')) return const Color(0xFFEC4899); // Pink
    if (cleanCode.contains('ANG') || cleanCode.contains('ENG')) return const Color(0xFF06B6D4); // Cyan
    if (cleanCode.contains('PHIL')) return const Color(0xFF8B5CF6); // Purple
    if (cleanCode.contains('EPS') || cleanCode.contains('SPORT')) return const Color(0xFF6366F1); // Indigo
    if (cleanCode.contains('PAUSE') || cleanCode.contains('REPOS')) return const Color(0xFF94A3B8); // Slate

    // Fallback palette for variety
    final List<Color> palette = [
      const Color(0xFFF43F5E), // Rose
      const Color(0xFF14B8A6), // Teal
      const Color(0xFFD946EF), // Fuchsia
      const Color(0xFFF97316), // Orange
      const Color(0xFF84CC16), // Lime
      const Color(0xFF0EA5E9), // Sky
    ];

    final int hash = name.hashCode.abs();
    return palette[hash % palette.length];
  }

  Widget _buildTimetableItem(TimetableItem item) {
    final color = _getColorForSubject(item.subject?.code ?? '', item.subject?.name ?? '');
    final startTime = _formatTime(item.startTime);
    final endTime = _formatTime(item.endTime);
    final badgeText = item.subject?.code ?? 'COURS';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      padding: EdgeInsets.only(top:14.w, right: 14.w, bottom: 14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            left: BorderSide(
              color: color,
              width: 4.w,
            ),
          )
        ),
        child: Row(
          children: [
            SizedBox(width: 12.w),
            // Left: Time
            SizedBox(
              width: 55.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    startTime,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    endTime,
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 4.w),
            Container(width: 1.5.w, height: 40.h, color: Colors.grey.shade100),
            SizedBox(width: 16.w),
            // Middle: Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badge
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      badgeText,
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Subject name
                  Text(
                    item.subject?.name ?? 'Cours',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF1E293B),
                    ),
                  ),
                  SizedBox(height: 4.h),

                  // Teacher
                  if (item.teacher != null)
                    Row(
                      children: [
                        Icon(Icons.person, size: 12.sp, color: Colors.grey.shade400),
                        SizedBox(width: 4.w),
                        Text(
                          '${item.teacher!.fullName}',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getDayName(int weekday) {
    const days = ['', 'LUN', 'MAR', 'MER', 'JEU', 'VEN', 'SAM', 'DIM'];
    return days[weekday];
  }

  DateTime _getMonday(DateTime date) {
    // Retour le lundi de la même semaine (weekday: 1 = Monday, 7 = Sunday)
    final daysToSubtract = date.weekday == 7 ? 6 : date.weekday - 1;
    return date.subtract(Duration(days: daysToSubtract));
  }

  String _formatDateFull(DateTime date) {
    const days = ['Lundi', 'Mardi', 'Mercredi', 'Jeudi', 'Vendredi', 'Samedi', 'Dimanche'];
    // weekday: 1 = Monday, 7 = Sunday
    final index = date.weekday == 7 ? 6 : date.weekday - 1;
    return days[index];
  }

  String _formatDateForDisplay(DateTime date) {
    final months = ['', 'Janvier', 'Février', 'Mars', 'Avril', 'Mai', 'Juin', 'Juillet', 'Août', 'Septembre', 'Octobre', 'Novembre', 'Décembre'];
    return '${date.day} ${months[date.month]} ${date.year}';
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
