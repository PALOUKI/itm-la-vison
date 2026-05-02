import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/grades.dart' as grades_models;
import 'package:vision/domain/models/common_models.dart';
import 'package:vision/presentation/viewmodels/grades_viewmodel.dart';

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
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a))),
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
          _buildDownloadButton(),

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
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          // Profile image
          CircleAvatar(
            radius: 32.r,
            backgroundImage: widget.child.displayPhoto != null && widget.child.displayPhoto!.isNotEmpty
                ? NetworkImage('${AppConstants.storageBaseUrl}/${widget.child.displayPhoto}')
                : null,
            child: widget.child.displayPhoto == null || widget.child.displayPhoto!.isEmpty
                ? Icon(Icons.person, size: 32.sp)
                : null,
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

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border(
          left: BorderSide(color: const Color(0xFF1E3A8A), width: 4.w),
        ),
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
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Coeff: ${grade.subject.coefficient}',
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    /*
                    Text(
                      'Classe: 12.2',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),

                     */
                  ],
                ),
                SizedBox(height: 8.h),

                // Progress bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: grade.isAbsent ? 0 : grade.score / 20,
                    minHeight: 4.h,
                    backgroundColor: Colors.grey.shade300,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      grade.isAbsent ? Colors.grey : const Color(0xFF1E3A8A),
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
                  color: grade.isAbsent ? Colors.grey : const Color(0xFF1E3A8A),
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
          //Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24.sp),
        ],
      ),
    );
  }

  Widget _buildDownloadButton() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // TODO: Download PDF
        },
        icon: Icon(Icons.download_outlined, size: 18.sp),
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
}

