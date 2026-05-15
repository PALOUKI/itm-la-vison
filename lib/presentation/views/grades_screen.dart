import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/grades.dart' as grades_models;
import 'package:vision/domain/models/common_models.dart';
import 'package:vision/presentation/viewmodels/grades_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';
import 'package:vision/presentation/viewmodels/bulletins_viewmodel.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GradesScreen extends ConsumerStatefulWidget {
  final String childUuid;
  final Child child;

  const GradesScreen({
    super.key,
    required this.childUuid,
    required this.child,
  });

  @override
  ConsumerState<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends ConsumerState<GradesScreen> {
  late int _selectedPeriodIndex;

  @override
  void initState() {
    super.initState();
    _selectedPeriodIndex = 0;
  }

  @override
  Widget build(BuildContext context) {
    final gradesState = ref.watch(gradesProvider(widget.childUuid));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Notes & Résultats',
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
      body: gradesState.when(
        data: (grades) => _buildContent(context, grades),
        loading: () => const GradesLoadingView(),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $err', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => ref.refresh(gradesProvider(widget.childUuid)),
                child: const Text("Réessayer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, grades_models.GradesResponse grades) {
    // Group grades by period
    final gradesByPeriod = _groupGradesByPeriod(grades.grades);
    final periods = gradesByPeriod.keys.toList()
      ..sort((a, b) => a.number.compareTo(b.number));

    // Get average score
    final averageScore = _calculateAverage(grades.grades);

    // Determine selected period object
    Period? selectedPeriod;
    if (periods.isNotEmpty && _selectedPeriodIndex < periods.length) {
      selectedPeriod = periods[_selectedPeriodIndex];
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          SizedBox(height: 12.h),

          // Header with child info
          _buildHeaderSection(),

          SizedBox(height: 16.h),

          // Period tabs
          if (periods.isNotEmpty) ...[
            _buildPeriodTabs(periods),
            SizedBox(height: 16.h),
          ],

          // Average card
          _buildAverageCard(averageScore),

          SizedBox(height: 16.h),

          // Details des matières - afficher seulement la période sélectionnée
          if (periods.isNotEmpty)
            _buildSubjectsDetailsSection(gradesByPeriod, periods[_selectedPeriodIndex], periods),

          SizedBox(height: 24.h),

          // Download button
          if (selectedPeriod != null)
            _buildDownloadButton(selectedPeriod, gradesByPeriod[selectedPeriod] ?? []),

          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Map<Period, List<grades_models.Grade>> _groupGradesByPeriod(List<grades_models.Grade> grades) {
    final grouped = <Period, List<grades_models.Grade>>{};
    for (var grade in grades) {
      // Chercher si la période existe déjà (par ID)
      final existingPeriod = grouped.keys.firstWhere(
        (p) => p.id == grade.exam.period.id,
        orElse: () => grade.exam.period,
      );
      grouped.putIfAbsent(existingPeriod, () => []);
      grouped[existingPeriod]!.add(grade);
    }
    return grouped;
  }

  double _calculateAverage(List<grades_models.Grade> grades) {
    if (grades.isEmpty) return 0;
    double sum = 0;
    int count = 0;
    for (var grade in grades) {
      if (!grade.isAbsent && grade.score > 0) {
        sum += grade.score;
        count++;
      }
    }
    return count > 0 ? sum / count : 0;
  }

  Widget _buildHeaderSection() {
    // Get initials for placeholder
    String initials = '';
    if (widget.child.fullName.isNotEmpty) {
      final names = widget.child.fullName.trim().split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[names.length - 1][0]}';
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        initials = names[0][0];
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Profile image with elegant fallback
          Container(
            width: 64.w,
            height: 64.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E3A8A).withOpacity(0.1),
            ),
            child: ClipOval(
              child: widget.child.displayPhoto != null && widget.child.displayPhoto!.isNotEmpty
                  ? Image.network(
                      '${AppConstants.storageBaseUrl}/${widget.child.displayPhoto}',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildInitialsPlaceholder(initials),
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
                  : _buildInitialsPlaceholder(initials),
            ),
          ),
          SizedBox(width: 12.w),

          // Student info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.child.fullName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Classe: ${widget.child.currentEnrollment?.classData.name ?? "N/A"}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitialsPlaceholder(String initials) {
    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF1E3A8A),
          fontWeight: FontWeight.bold,
          fontSize: 24.sp,
        ),
      ),
    );
  }

  Widget _buildPeriodTabs(List<Period> periods) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.r),
        color: Colors.white,
      ),
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: List.generate(periods.length, (index) {
          final period = periods[index];
          final isActive = index == _selectedPeriodIndex;

          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriodIndex = index;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: isActive ? const Color(0xFF1E3A8A) : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  period.name,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildAverageCard(double average) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF87171)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.all(10.w),
                      child: Icon(Icons.trending_up, color: Colors.white, size: 20.sp)
                  ),
                  SizedBox(width: 8.w),
                  Column(
                    children: [
                      Text(
                        'Moyenne Générale',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Excellent travail !',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 4.h),
            ],
          ),
          Column(
            children: [
              Text(
                '${average.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                'sur 20',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsDetailsSection(
    Map<Period, List<grades_models.Grade>> gradesByPeriod,
    Period selectedPeriod,
    List<Period> periods,
  ) {
    final selectedGrades = gradesByPeriod[selectedPeriod] ?? [];

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Détails des Matières',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                '${selectedGrades.length} MATIÈRES',
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Display grades from selected period
          ...selectedGrades.map((grade) {
            return _buildSubjectCard(grade);
          }).toList(),
        ],
      ),
    );
  }


  Widget _buildSubjectCard(grades_models.Grade grade) {
    final score = grade.isAbsent ? 'ABS' : grade.score.toStringAsFixed(2);
    final color = _getGradeColor(grade.subject.code, grade.subject.name);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: color, width: 4.w),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Left: Subject info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  grade.subject.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Coeff: ${grade.subject.coefficient}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: grade.isAbsent ? 0 : grade.score / 20,
                    minHeight: 5.h,
                    backgroundColor: Colors.grey.shade100,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      grade.isAbsent ? Colors.grey : color,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: 12.w),

          // Right: Score
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: grade.isAbsent ? Colors.grey : color,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '/20',
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          SizedBox(width: 8.w),
        ],
      ),
    );
  }

  Color _getGradeColor(String code, String name) {
    final String cleanCode = code.toUpperCase();
    
    // Identical palette as Timetable for consistency
    if (cleanCode.contains('MATH')) return const Color(0xFF3B82F6); // Blue
    if (cleanCode.contains('PC') || cleanCode.contains('PHYS')) return const Color(0xFFEF4444); // Red
    if (cleanCode.contains('SVT') || cleanCode.contains('BIO')) return const Color(0xFF10B981); // Green
    if (cleanCode.contains('HG') || cleanCode.contains('HIST') || cleanCode.contains('GEO')) return const Color(0xFFF59E0B); // Amber
    if (cleanCode.contains('FR') || cleanCode.contains('LITT')) return const Color(0xFFEC4899); // Pink
    if (cleanCode.contains('ANG') || cleanCode.contains('ENG')) return const Color(0xFF06B6D4); // Cyan
    if (cleanCode.contains('PHIL')) return const Color(0xFF8B5CF6); // Purple
    if (cleanCode.contains('EPS') || cleanCode.contains('SPORT')) return const Color(0xFF6366F1); // Indigo

    // Fallback palette
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

  Widget _buildDownloadButton(Period period, List<grades_models.Grade> gradesInPeriod) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (gradesInPeriod.isNotEmpty) {
            _showMiniBulletinBottomSheet(context, gradesInPeriod.first.exam);
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Aucune donnée d\'examen disponible pour cette période.')),
            );
          }
        },
        icon: Icon(Icons.description_outlined, size: 18.sp),
        label: Text(
          'Voir le relevé de notes',
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  void _showMiniBulletinBottomSheet(BuildContext context, Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _GradesMiniBulletinSheet(
          childUuid: widget.childUuid,
          exam: exam,
        );
      },
    );
  }
}

class _GradesMiniBulletinSheet extends ConsumerWidget {
  final String childUuid;
  final Exam exam;

  const _GradesMiniBulletinSheet({
    required this.childUuid,
    required this.exam,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final params = MiniBulletinParams(studentUuid: childUuid, examId: exam.id);
    final miniBulletinState = ref.watch(miniBulletinHtmlProvider(params));

    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.r),
              topRight: Radius.circular(20.r),
            ),
          ),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Container(
                  width: 40.w,
                  height: 4.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2.r),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: miniBulletinState.when(
                  data: (htmlContent) {
                    return _GradesMiniBulletinWebView(htmlContent: htmlContent);
                  },
                  loading: () => const DocumentLoadingView(height: 220),
                  error: (err, stack) => SingleChildScrollView(
                    controller: scrollController,
                    child: Padding(
                      padding: EdgeInsets.all(16.w),
                      child: _buildGradesRetryableErrorMessage(
                        errorMessage: err.toString(),
                        onRetry: () => ref.invalidate(miniBulletinHtmlProvider(params)),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GradesMiniBulletinWebView extends StatelessWidget {
  final String htmlContent;

  const _GradesMiniBulletinWebView({required this.htmlContent});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12.r),
          child: WebViewWidget(
            controller: WebViewController()
              ..setJavaScriptMode(JavaScriptMode.unrestricted)
              ..loadHtmlString(htmlContent),
          ),
        ),
      ),
    );
  }
}

Widget _buildGradesRetryableErrorMessage({
  required String errorMessage,
  required VoidCallback onRetry,
}) {
  String displayMessage = 'Une erreur s\'est produite';
  IconData icon = Icons.error_outline;
  Color iconColor = Colors.red;

  if (errorMessage.contains('access not enabled') || errorMessage.contains('pas encore publiées')) {
    displayMessage = 'Le relevé de notes n\'est pas encore disponible\n\nCe document sera accessible une fois publié par l\'établissement.';
    icon = Icons.lock_clock_outlined;
    iconColor = Colors.orange;
  } else if (errorMessage.contains('Connection') || errorMessage.contains('Network')) {
    displayMessage = 'Erreur de connexion\n\nVérifiez votre connexion Internet et réessayez.';
    icon = Icons.wifi_off;
    iconColor = Colors.red;
  }

  return Container(
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: iconColor.withOpacity(0.1),
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: iconColor.withOpacity(0.3)),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 48.sp, color: iconColor),
        SizedBox(height: 12.h),
        Text(
          displayMessage,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade800, height: 1.5),
        ),
        SizedBox(height: 16.h),
        TextButton(
          onPressed: onRetry,
          style: TextButton.styleFrom(
            foregroundColor: iconColor,
            side: BorderSide(color: iconColor),
          ),
          child: const Text('Réessayer'),
        ),
      ],
    ),
  );
}
