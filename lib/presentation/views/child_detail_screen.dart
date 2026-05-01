import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:vision/config/constants.dart';
import 'package:vision/domain/models/child.dart' as child_models;
import 'package:vision/domain/models/bulletins.dart' as bulletins_models;
import 'package:vision/domain/models/common_models.dart';
import 'package:vision/presentation/viewmodels/child_detail_viewmodel.dart';
import 'package:vision/presentation/viewmodels/bulletins_viewmodel.dart';
import 'package:intl/intl.dart';

class ChildDetailScreen extends ConsumerWidget {
  final String childUuid;

  const ChildDetailScreen({super.key, required this.childUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final childState = ref.watch(childDetailProvider(childUuid));
    final expandedMenu = ref.watch(expandedMenuProvider);

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
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: Colors.black, size: 24.sp),
            onPressed: () {},
          ),
        ],
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
                onTap: () => context.push('/home/child-detail/${child.uuid}/grades', extra: child),
                isExpanded: false,
              ),
              _buildMenuItem(
                icon: Icons.description_outlined,
                title: 'Bulletins Scolaires',
                onTap: () => context.push('/home/child-detail/${child.uuid}/bulletins', extra: child),
                isExpanded: false,
              ),
              _buildMenuItem(
                icon: Icons.calendar_today_outlined,
                title: 'Emploi du temps',
                onTap: () => context.push('/home/child-detail/${child.uuid}/timetable'),
                isExpanded: false,
              ),
              _buildMenuItem(
                icon: Icons.access_time_outlined,
                title: 'Absences / Retards',
                badgeCount: 2,
                onTap: () => context.push('/home/child-detail/${child.uuid}/attendances'),
                isExpanded: false,
              ),
              _buildMenuItem(
                icon: Icons.payment_outlined,
                title: 'Paiements',
                onTap: () => context.push('/home/child-detail/${child.uuid}/finances'),
                isExpanded: false,
              ),
              _buildMenuItem(
                icon: Icons.chat_bubble_outline_outlined,
                title: 'Communications',
                onTap: () => context.push('/home/child-detail/${child.uuid}/messages'),
                isExpanded: false,
              ),
              SizedBox(height: 32.h),
            ],
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
              image: child.displayPhoto != null
                  ? DecorationImage(
                      image: NetworkImage('${AppConstants.storageBaseUrl}/${child.displayPhoto}'),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: child.displayPhoto == null ? Icon(Icons.person, size: 40.sp) : null,
          ),
          SizedBox(height: 16.h),
          Text(
            child.fullName,
            style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
          ),
          SizedBox(height: 4.h),
          Text(
            '${child.currentEnrollment?.classData.name ?? 'N/A'} • Lycée Moderne',
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
    int? badgeCount,
    VoidCallback? onTap,
    bool isExpanded = false,
    Widget? expandedContent,
  }) {
    return Column(
      children: [
        InkWell(
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
                if (badgeCount != null)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                    decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(10.r)),
                    child: Text(badgeCount.toString(), style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
                  ),
                SizedBox(width: 8.w),
                Icon(
                  isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_right,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
              ],
            ),
          ),
        ),
        if (isExpanded && expandedContent != null) expandedContent,
      ],
    );
  }

  Widget _buildBulletinsContent(WidgetRef ref, child_models.Child child) {
    final bulletinsState = ref.watch(bulletinsProvider);
    final selectedSemester = ref.watch(selectedSemesterProvider);

    return bulletinsState.when(
      data: (bulletins) {
        // Trouver les bulletins pour cet enfant
        final childId = child.id;
        final miniBulletin = bulletins.miniBulletins.cast<dynamic>().firstWhere(
          (b) => b.studentId == childId,
          orElse: () => null,
        );

        final exams = miniBulletin?.exams ?? [];

        // Extraire les périodes uniques avec leurs informations complètes
        final periods = <int, Period>{};
        for (var exam in exams) {
          if (!periods.containsKey(exam.period.number)) {
            periods[exam.period.number] = exam.period;
          }
        }

        // Trier les périodes par numéro
        final sortedPeriods = periods.entries.toList()..sort((a, b) => a.key.compareTo(b.key));

        // Filtrer les exams pour la période sélectionnée
        int? activePeriodNumber = selectedSemester != 0
          ? selectedSemester
          : (sortedPeriods.isNotEmpty ? sortedPeriods.first.key : null);

        final filteredExams = exams.where((e) => e.period.number == activePeriodNumber).toList();

        if (sortedPeriods.isEmpty) {
          return Container(
            padding: EdgeInsets.all(16.w),
            color: const Color(0xFFF8FAFC),
            child: Center(
              child: Text(
                'Aucun bulletin disponible',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
              ),
            ),
          );
        }

        return Container(
          padding: EdgeInsets.all(16.w),
          color: const Color(0xFFF8FAFC),
          child: Column(
            children: [
              // Période Selector - Dynamique basé sur les données
              Container(
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: sortedPeriods.map((entry) {
                    return Expanded(
                      child: _buildSemesterTab(
                        ref,
                        entry.value.name,
                        activePeriodNumber == entry.key,
                        entry.key,
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 16.h),
              // Afficher les bulletins filtrés
              if (filteredExams.isEmpty)
                Container(
                  padding: EdgeInsets.all(16.w),
                  child: Text(
                    'Aucun bulletin pour cette période',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp),
                  ),
                )
              else
                ...filteredExams.map((exam) {
                  return Container(
                    margin: EdgeInsets.only(bottom: 12.h),
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                exam.title,
                                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                'Type: ${exam.examType.name}',
                                style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                        Builder(
                          builder: (context) => GestureDetector(
                            onTap: () async {
                              // Télécharger le bulletin
                              await _downloadBulletin(
                                context,
                                ref,
                                child.uuid,
                                exam.period.name,
                                exam.period.number,
                              );
                            },
                            child: Container(
                              padding: EdgeInsets.all(8.w),
                              decoration: BoxDecoration(
                                border: Border.all(color: const Color(0xFF1E3A8A)),
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                              child: Icon(Icons.file_download_outlined, color: const Color(0xFF1E3A8A), size: 20.sp),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
            ],
          ),
        );
      },
      loading: () => Container(
        padding: EdgeInsets.all(16.w),
        child: const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
      ),
      error: (err, stack) => Container(
        padding: EdgeInsets.all(16.w),
        child: Text(
          'Erreur: $err',
          style: TextStyle(color: Colors.red, fontSize: 12.sp),
        ),
      ),
    );
  }

  Widget _buildSemesterTab(WidgetRef ref, String text, bool isActive, int value) {
    return GestureDetector(
      onTap: () => ref.read(selectedSemesterProvider.notifier).setSemester(value),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(color: isActive ? Colors.white : Colors.grey, fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
        ),
      ),
    );
  }


  Widget _buildGradesContent(List<child_models.Grade> grades) {
    if (grades.isEmpty) {
      return Container(
        padding: EdgeInsets.all(16.w),
        color: const Color(0xFFF8FAFC),
        child: Center(
          child: Text('Aucune note récente.', style: TextStyle(color: Colors.grey.shade600, fontSize: 14.sp)),
        ),
      );
    }

    return Container(
      color: const Color(0xFFF8FAFC),
      child: Column(
        children: grades.take(5).map((grade) {
          final isGood = !grade.isAbsent && (num.tryParse(grade.score.toString()) ?? 0) >= 10;
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: grade.isAbsent ? Colors.grey.shade200 : (isGood ? const Color(0xFFD1FAE5) : const Color(0xFFFEE2E2)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    grade.isAbsent ? Icons.event_busy_outlined : (isGood ? Icons.trending_up : Icons.trending_down),
                    color: grade.isAbsent ? Colors.grey.shade600 : (isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444)),
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Évaluation Continue', // Label par défaut si non fourni par API
                        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Enregistré le ${grade.createdAt.day.toString().padLeft(2,'0')}/${grade.createdAt.month.toString().padLeft(2,'0')}/${grade.createdAt.year}',
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                if (grade.isAbsent)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(12.r)),
                    child: Text('ABSENT', style: TextStyle(color: Colors.grey.shade700, fontSize: 10.sp, fontWeight: FontWeight.bold)),
                  )
                else
                  Text(
                    '${grade.score}/20',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: isGood ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Télécharger le bulletin PDF
  Future<void> _downloadBulletin(
    BuildContext context,
    WidgetRef ref,
    String studentUuid,
    String periodName,
    int periodNumber,
  ) async {
    try {
      // Afficher un dialog de chargement
      if (context.mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext ctx) => const AlertDialog(
            content: Row(
              children: [
                CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                SizedBox(width: 16),
                Text('Téléchargement...'),
              ],
            ),
          ),
        );
      }


      // Obtenir le répertoire de téléchargements
      late Directory downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = Directory('/storage/emulated/0/Download');
        if (!await downloadsDir.exists()) {
          downloadsDir = await getApplicationDocumentsDirectory();
        }
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory();
      } else {
        downloadsDir = await getDownloadsDirectory() ?? await getApplicationDocumentsDirectory();
      }

      // Créer le nom du fichier
      final fileName = 'Bulletin_${studentUuid}_${periodNumber}.pdf';
      final filePath = '${downloadsDir.path}/$fileName';

      // Télécharger le bulletin
      final bulletinsRepository = ref.read(bulletinsRepositoryProvider);
      final pdfBytes = await bulletinsRepository.downloadBulletinPdf(
        studentUuid: studentUuid,
        periodId: periodNumber.toString(),
      );

      // Écrire le fichier
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      // Fermer le dialog de chargement
      if (context.mounted) {
        Navigator.pop(context);

        // Afficher le message de succès
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bulletin téléchargé: $fileName'),
            action: SnackBarAction(
              label: 'Voir',
              onPressed: () {
                // Ouvrir le fichier (optionnel)
              },
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}
