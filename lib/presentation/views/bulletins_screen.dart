import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/common_models.dart';
import 'package:vision/presentation/viewmodels/bulletins_viewmodel.dart';

class BulletinsScreen extends ConsumerStatefulWidget {
  final String childUuid;
  final Child child;

  const BulletinsScreen({
    super.key,
    required this.childUuid,
    required this.child,
  });

  @override
  ConsumerState<BulletinsScreen> createState() => _BulletinsScreenState();
}

class _BulletinsScreenState extends ConsumerState<BulletinsScreen> {
  String? _selectedTab = 'bulletin'; // 'bulletin' or 'compositions'
  Period? _selectedPeriod;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final periodsState = ref.watch(periodsProvider);

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
          'Bulletins Scolaires',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: periodsState.when(
        data: (periods) {
          if (periods.isEmpty) {
            return Center(
              child: Text('Aucune période disponible', style: TextStyle(fontSize: 14.sp)),
            );
          }

          // Set default selected period
          _selectedPeriod ??= periods.firstWhere(
            (p) => p.isCurrent,
            orElse: () => periods.first,
          );

          return SingleChildScrollView(
            child: Column(
              children: [
                // Period tabs
                _buildPeriodTabs(periods),
                SizedBox(height: 16.h),

                // Content tabs (Bulletin / Compositions)
                _buildContentTabs(),
                SizedBox(height: 16.h),

                // Content based on selected tab
                if (_selectedTab == 'bulletin')
                  _buildBulletinContent()
                else
                  _buildCompositionsContent(),

                SizedBox(height: 20.h),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a))),
        error: (err, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Erreur: $err', style: TextStyle(fontSize: 14.sp, color: Colors.red)),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => ref.refresh(periodsProvider),
                child: const Text("Réessayer"),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPeriodTabs(List<Period> periods) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: periods.map((period) {
          final isSelected = _selectedPeriod?.id == period.id;
          return Padding(
            padding: EdgeInsets.only(right: 12.w),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedPeriod = period;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey.shade300,
                    width: 1.5,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  period.name,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14.sp,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildContentTabs() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 'bulletin';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 'bulletin' ? const Color(0xFF1E3A8A) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Bulletin Général',
                    style: TextStyle(
                      color: _selectedTab == 'bulletin' ? const Color(0xFF1E3A8A) : Colors.grey,
                      fontWeight: _selectedTab == 'bulletin' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 'compositions';
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: _selectedTab == 'compositions' ? const Color(0xFF1E3A8A) : Colors.transparent,
                      width: 2,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    'Compositions',
                    style: TextStyle(
                      color: _selectedTab == 'compositions' ? const Color(0xFF1E3A8A) : Colors.grey,
                      fontWeight: _selectedTab == 'compositions' ? FontWeight.bold : FontWeight.normal,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBulletinContent() {
    if (_selectedPeriod == null) {
      return const SizedBox.shrink();
    }

    return ref.watch(
      bulletinHtmlProvider(
        BulletinParams(studentUuid: widget.childUuid, periodId: _selectedPeriod!.id),
      ),
    ).when(
      data: (htmlContent) => _buildWebViewContainer(htmlContent),
      loading: () => Padding(
        padding: EdgeInsets.symmetric(vertical: 50.h),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a))),
      ),
      error: (err, stack) => Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildErrorMessage(err.toString()),
      ),
    );
  }

  Widget _buildCompositionsContent() {
    if (_selectedPeriod == null) {
      return const SizedBox.shrink();
    }

    final examsState = ref.watch(examsProvider(_selectedPeriod!.id));

    return examsState.when(
      data: (exams) {
        if (exams.isEmpty) {
          return Padding(
            padding: EdgeInsets.all(16.w),
            child: Center(
              child: Text('Aucune composition pour cette période', style: TextStyle(fontSize: 14.sp)),
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: exams.map((exam) {
              return _buildExamCard(exam);
            }).toList(),
          ),
        );
      },
      loading: () => Padding(
        padding: EdgeInsets.all(16.w),
        child: const CircularProgressIndicator(color: Color(0xFF1e3a8a)),
      ),
      error: (err, stack) => Padding(
        padding: EdgeInsets.all(16.w),
        child: _buildErrorMessage(err.toString()),
      ),
    );
  }

  Widget _buildExamCard(Exam exam) {
    return GestureDetector(
      onTap: () {
        _showExamBulletinSheet(exam);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.title,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        exam.examType.name,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 24.sp),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showExamBulletinSheet(Exam exam) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
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
                  // Handle bar
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
                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                    child: Text(
                      exam.title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  // Content
                  Expanded(
                    child: _buildExamBulletinWebView(exam),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildExamBulletinWebView(Exam exam) {
    final miniBulletinState = ref.watch(
      miniBulletinHtmlProvider(
        MiniBulletinParams(studentUuid: widget.childUuid, examId: exam.id),
      ),
    );

    return miniBulletinState.when(
      data: (htmlContent) {
        return _buildWebViewContainer(htmlContent);
      },
      loading: () => const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a))),
      error: (err, stack) => Center(
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: _buildErrorMessage(err.toString()),
        ),
      ),
    );
  }

  Widget _buildWebViewContainer(String htmlContent) {
    return Container(
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: WebViewWidget(
          controller: _createWebViewController(htmlContent),
        ),
      ),
    );
  }

  WebViewController _createWebViewController(String htmlContent) {
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(htmlContent);
    return controller;
  }

  Widget _buildErrorMessage(String errorMessage) {
    // Extract meaningful error message
    String displayMessage = 'Une erreur s\'est produite';
    IconData icon = Icons.error_outline;
    Color iconColor = Colors.red;

    if (errorMessage.contains('Bulletin access not enabled')) {
      displayMessage = 'Le bulletin n\'est pas encore disponible\n\nCet accès sera activé dès que les bulletins seront publié par l\'établissement.';
      icon = Icons.lock_clock_outlined;
      iconColor = Colors.orange;
    } else if (errorMessage.contains('Mini-bulletin access not enabled') || errorMessage.contains('Les notes ne sont pas encore publiées')) {
      displayMessage = 'Les compositions ne sont pas encore disponibles\n\nCes documents seront accessibles une fois publié par l\'établissement.';
      icon = Icons.lock_clock_outlined;
      iconColor = Colors.orange;
    } else if (errorMessage.contains('not found')) {
      displayMessage = 'Aucun bulletin trouvé\n\nVérifiez que vous avez sélectionné une période valide.';
      icon = Icons.file_copy_outlined;
      iconColor = Colors.blue;
    } else if (errorMessage.contains('Connection') || errorMessage.contains('Network')) {
      displayMessage = 'Erreur de connexion\n\nVérifiez votre connexion Internet et réessayez.';
      icon = Icons.wifi_off;
      iconColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: iconColor.withValues(alpha: 0.3)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48.sp, color: iconColor),
          SizedBox(height: 12.h),
          Text(
            displayMessage,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: () {
              if (_selectedTab == 'bulletin') {
                if (_selectedPeriod != null) {
                  ref.refresh(
                    bulletinHtmlProvider(
                      BulletinParams(studentUuid: widget.childUuid, periodId: _selectedPeriod!.id),
                    ),
                  );
                }
              } else {
                ref.refresh(periodsProvider);
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: iconColor,
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
              side: BorderSide(color: iconColor, width: 1),
            ),
            child: Text(
              'Réessayer',
              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

