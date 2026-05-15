import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vision/config/themes/app_colors.dart';

class VisionShimmer extends StatelessWidget {
  final Widget child;

  const VisionShimmer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE6ECF5),
      highlightColor: const Color(0xFFF8FAFD),
      period: const Duration(milliseconds: 1500),
      child: child,
    );
  }
}

class SkeletonBox extends StatelessWidget {
  final double? width;
  final double height;
  final double radius;
  final EdgeInsetsGeometry? margin;

  const SkeletonBox({
    super.key,
    this.width,
    required this.height,
    this.radius = 14,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height.h,
      margin: margin,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(radius.r),
      ),
    );
  }
}

class SkeletonCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color color;

  const SkeletonCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionTitleSkeleton extends StatelessWidget {
  final double titleWidth;
  final double? pillWidth;

  const SectionTitleSkeleton({
    super.key,
    this.titleWidth = 120,
    this.pillWidth = 72,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SkeletonBox(width: titleWidth.w, height: 18, radius: 8),
        if (pillWidth != null) SkeletonBox(width: pillWidth!.w, height: 28, radius: 12),
      ],
    );
  }
}

class HomeLoadingView extends StatelessWidget {
  const HomeLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        children: [
          _homeTopBarSkeleton(),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: const [
                HomeGreetingSkeleton(),
                SizedBox(height: 24),
                HomeStatsSkeleton(),
                SizedBox(height: 32),
                HomeChildrenSectionSkeleton(),
                SizedBox(height: 18),
                HomeAnnouncementsSectionSkeleton(),
                SizedBox(height: 80),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _homeTopBarSkeleton() {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 6.h),
      child: VisionShimmer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SkeletonBox(width: 128, height: 28, radius: 10),
            Row(
              children: const [
                SkeletonBox(width: 42, height: 42, radius: 14),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HomeGreetingSkeleton extends StatelessWidget {
  const HomeGreetingSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SkeletonBox(width: 220, height: 24, radius: 8),
          SizedBox(height: 10.h),
          const SkeletonBox(width: 180, height: 14, radius: 8),
        ],
      ),
    );
  }
}

class HomeStatsSkeleton extends StatelessWidget {
  const HomeStatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SkeletonCard(
        color: AppColors.primary,
        padding: EdgeInsets.all(20.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 86.w,
                  height: 12.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 150.w,
                  height: 22.h,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                ),
              ],
            ),
            Container(
              width: 56.w,
              height: 56.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeChildrenSectionSkeleton extends StatelessWidget {
  const HomeChildrenSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleSkeleton(titleWidth: 106, pillWidth: 84),
          SizedBox(height: 16.h),
          ...List.generate(
            2,
            (index) => SkeletonCard(
              margin: EdgeInsets.only(bottom: 14.h),
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Container(
                    width: 58.w,
                    height: 58.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 14.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(height: 16, radius: 8),
                        SizedBox(height: 10),
                        SkeletonBox(width: 120, height: 12, radius: 8),
                        SizedBox(height: 10),
                        SkeletonBox(width: 90, height: 12, radius: 8),
                      ],
                    ),
                  ),
                  const SkeletonBox(width: 28, height: 28, radius: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeAnnouncementsSectionSkeleton extends StatelessWidget {
  const HomeAnnouncementsSectionSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitleSkeleton(titleWidth: 96, pillWidth: 62),
          SizedBox(height: 14.h),
          ...List.generate(
            3,
            (index) => SkeletonCard(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  SkeletonBox(width: 140, height: 14, radius: 8),
                  SizedBox(height: 12),
                  SkeletonBox(height: 14, radius: 8),
                  SizedBox(height: 8),
                  SkeletonBox(width: 210, height: 14, radius: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChildDetailLoadingView extends StatelessWidget {
  const ChildDetailLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 24.h, horizontal: 20.w),
              color: const Color(0xFFF0F5FF),
              child: Column(
                children: [
                  Container(
                    width: 84.w,
                    height: 84.w,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  const SkeletonBox(width: 180, height: 18, radius: 8),
                  SizedBox(height: 10.h),
                  const SkeletonBox(width: 132, height: 14, radius: 8),
                  SizedBox(height: 10.h),
                  const SkeletonBox(width: 168, height: 12, radius: 8),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            ...List.generate(
              6,
              (index) => Container(
                margin: EdgeInsets.only(bottom: 1.h),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                color: Colors.white,
                child: Row(
                  children: [
                    const SkeletonBox(width: 38, height: 38, radius: 12),
                    SizedBox(width: 16.w),
                    const Expanded(child: SkeletonBox(height: 16, radius: 8)),
                    SizedBox(width: 12.w),
                    const SkeletonBox(width: 20, height: 20, radius: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfileLoadingView extends StatelessWidget {
  const ProfileLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(height: 16.h),
            const SkeletonBox(width: 120, height: 18, radius: 8),
            SizedBox(height: 10.h),
            const SkeletonBox(width: 96, height: 28, radius: 14),
            SizedBox(height: 28.h),
            const LoadingSectionCard(lines: 3),
            SizedBox(height: 16.h),
            const LoadingSectionCard(lines: 3, hasTrailingSwitch: true),
          ],
        ),
      ),
    );
  }
}

class FinancesLoadingView extends StatelessWidget {
  const FinancesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SkeletonCard(
              color: AppColors.darkBlue,
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 120.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.45),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Container(
                            width: 100.w,
                            height: 12.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                          ),
                        ],
                      ),
                      Container(
                        width: 42.w,
                        height: 42.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 24.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _darkMetricSkeleton(),
                      _darkMetricSkeleton(alignEnd: true),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Container(
                    width: double.infinity,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            const SectionTitleSkeleton(titleWidth: 94, pillWidth: null),
            SizedBox(height: 12.h),
            const CardListLoadingView(itemCount: 3, itemHeight: 76),
            SizedBox(height: 24.h),
            const SectionTitleSkeleton(titleWidth: 132, pillWidth: null),
            SizedBox(height: 12.h),
            const CardListLoadingView(itemCount: 4, itemHeight: 62),
          ],
        ),
      ),
    );
  }

  Widget _darkMetricSkeleton({bool alignEnd = false}) {
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          width: 90.w,
          height: 12.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(8.r),
          ),
        ),
        SizedBox(height: 8.h),
        Container(
          width: 110.w,
          height: 22.h,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
      ],
    );
  }
}

class MessagesLoadingView extends StatelessWidget {
  const MessagesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 12.h),
            child: const SkeletonBox(height: 44, radius: 14),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: const [
                SkeletonBox(width: 58, height: 32, radius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 72, height: 32, radius: 18),
                SizedBox(width: 8),
                SkeletonBox(width: 64, height: 32, radius: 18),
              ],
            ),
          ),
          SizedBox(height: 12.h),
          Expanded(
            child: ListView.builder(
              itemCount: 6,
              padding: EdgeInsets.only(bottom: 96.h),
              itemBuilder: (context, index) {
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: const [
                                SkeletonBox(width: 110, height: 14, radius: 8),
                                SkeletonBox(width: 42, height: 10, radius: 8),
                              ],
                            ),
                            SizedBox(height: 10.h),
                            const SkeletonBox(width: 160, height: 12, radius: 8),
                            SizedBox(height: 8.h),
                            const SkeletonBox(height: 12, radius: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class TeacherSelectorLoading extends StatelessWidget {
  const TeacherSelectorLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: const SkeletonBox(height: 52, radius: 12),
    );
  }
}

class AnnouncementsLoadingView extends StatelessWidget {
  const AnnouncementsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: 5,
        itemBuilder: (context, index) => SkeletonCard(
          margin: EdgeInsets.only(bottom: 12.h),
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              SkeletonBox(width: 130, height: 14, radius: 8),
              SizedBox(height: 12),
              SkeletonBox(height: 14, radius: 8),
              SizedBox(height: 8),
              SkeletonBox(width: 220, height: 14, radius: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class AttendanceLoadingView extends StatelessWidget {
  const AttendanceLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SkeletonCard(
              margin: EdgeInsets.all(16.w),
              padding: EdgeInsets.all(16.w),
              color: const Color(0xFFFFF7ED),
              child: Row(
                children: [
                  const SkeletonBox(width: 28, height: 28, radius: 14),
                  SizedBox(width: 12.w),
                  const Expanded(child: SkeletonBox(height: 14, radius: 8)),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: const SectionTitleSkeleton(titleWidth: 146, pillWidth: 88),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: const [
                  Expanded(child: SkeletonBox(height: 118, radius: 20)),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(height: 118, radius: 20)),
                  SizedBox(width: 12),
                  Expanded(child: SkeletonBox(height: 118, radius: 20)),
                ],
              ),
            ),
            SizedBox(height: 20.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const CardListLoadingView(itemCount: 4, itemHeight: 76),
            ),
          ],
        ),
      ),
    );
  }
}

class GradesLoadingView extends StatelessWidget {
  const GradesLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SkeletonCard(
                padding: EdgeInsets.all(16.w),
                child: Row(
                  children: [
                    Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          SkeletonBox(height: 16, radius: 8),
                          SizedBox(height: 8),
                          SkeletonBox(width: 120, height: 12, radius: 8),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: const [
                  SkeletonBox(width: 90, height: 44, radius: 12),
                  SizedBox(width: 12),
                  SkeletonBox(width: 90, height: 44, radius: 12),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SkeletonCard(
                padding: EdgeInsets.all(18.w),
                color: const Color(0xFFEF4444),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 120.w,
                          height: 14.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Container(
                          width: 96.w,
                          height: 12.h,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.22),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      width: 64.w,
                      height: 40.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.38),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const CardListLoadingView(itemCount: 4, itemHeight: 78),
            ),
          ],
        ),
      ),
    );
  }
}

class TimetableLoadingView extends StatelessWidget {
  const TimetableLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: SkeletonCard(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(
                        5,
                        (index) => const SkeletonBox(width: 44, height: 56, radius: 14),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    const SkeletonBox(width: 180, height: 14, radius: 8),
                  ],
                ),
              ),
            ),
            SizedBox(height: 12.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const CardListLoadingView(itemCount: 4, itemHeight: 88),
            ),
          ],
        ),
      ),
    );
  }
}

class BulletinsLoadingView extends StatelessWidget {
  const BulletinsLoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              child: Row(
                children: const [
                  SkeletonBox(width: 104, height: 40, radius: 10),
                  SizedBox(width: 12),
                  SkeletonBox(width: 104, height: 40, radius: 10),
                  SizedBox(width: 12),
                  SkeletonBox(width: 104, height: 40, radius: 10),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: const [
                  Expanded(child: SkeletonBox(height: 42, radius: 4)),
                  SizedBox(width: 16),
                  Expanded(child: SkeletonBox(height: 42, radius: 4)),
                ],
              ),
            ),
            SizedBox(height: 16.h),
            const DocumentLoadingView(),
          ],
        ),
      ),
    );
  }
}

class DocumentLoadingView extends StatelessWidget {
  final double height;

  const DocumentLoadingView({
    super.key,
    this.height = 420,
  });

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: SkeletonCard(
          padding: EdgeInsets.all(18.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SkeletonBox(width: 130, height: 14, radius: 8),
              SizedBox(height: 16.h),
              ...List.generate(
                8,
                (index) => SkeletonBox(
                  width: index == 7 ? 180.w : double.infinity,
                  height: 12,
                  radius: 8,
                  margin: EdgeInsets.only(bottom: 10.h),
                ),
              ),
              SizedBox(height: 10.h),
              SkeletonBox(height: height, radius: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class ExamListLoadingView extends StatelessWidget {
  final int itemCount;

  const ExamListLoadingView({
    super.key,
    this.itemCount = 4,
  });

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        child: Column(
          children: List.generate(
            itemCount,
            (index) => SkeletonCard(
              margin: EdgeInsets.only(bottom: 12.h),
              padding: EdgeInsets.all(14.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        SkeletonBox(height: 14, radius: 8),
                        SizedBox(height: 10),
                        SkeletonBox(width: 120, height: 12, radius: 8),
                      ],
                    ),
                  ),
                  SizedBox(width: 12.w),
                  const SkeletonBox(width: 20, height: 20, radius: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class CardListLoadingView extends StatelessWidget {
  final int itemCount;
  final double itemHeight;

  const CardListLoadingView({
    super.key,
    this.itemCount = 3,
    this.itemHeight = 82,
  });

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: Column(
        children: List.generate(
          itemCount,
          (index) => SkeletonBox(
            height: itemHeight,
            radius: 18,
            margin: EdgeInsets.only(bottom: 12.h),
          ),
        ),
      ),
    );
  }
}

class LoadingSectionCard extends StatelessWidget {
  final int lines;
  final bool hasTrailingSwitch;

  const LoadingSectionCard({
    super.key,
    this.lines = 3,
    this.hasTrailingSwitch = false,
  });

  @override
  Widget build(BuildContext context) {
    return VisionShimmer(
      child: SkeletonCard(
        padding: EdgeInsets.all(18.w),
        child: Column(
          children: [
            Row(
              children: [
                const SkeletonBox(width: 26, height: 26, radius: 8),
                SizedBox(width: 10.w),
                const Expanded(child: SkeletonBox(height: 15, radius: 8)),
              ],
            ),
            SizedBox(height: 16.h),
            ...List.generate(lines, (index) {
              return Padding(
                padding: EdgeInsets.only(bottom: index == lines - 1 ? 0 : 14.h),
                child: Row(
                  children: [
                    const Expanded(child: SkeletonBox(height: 12, radius: 8)),
                    if (hasTrailingSwitch) ...[
                      SizedBox(width: 14.w),
                      const SkeletonBox(width: 44, height: 24, radius: 12),
                    ],
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class VisionBusyIndicator extends StatelessWidget {
  final double size;
  final Color color;
  final Color trackColor;
  final double strokeWidth;
  final bool showHalo;

  const VisionBusyIndicator({
    super.key,
    this.size = 34,
    this.color = AppColors.primary,
    this.trackColor = const Color(0xFFE6ECF5),
    this.strokeWidth = 3,
    this.showHalo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: showHalo ? color.withValues(alpha: 0.08) : Colors.transparent,
        boxShadow: showHalo
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.12),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      padding: EdgeInsets.all((size * 0.14).w),
      child: CircularProgressIndicator(
        strokeWidth: strokeWidth,
        valueColor: AlwaysStoppedAnimation<Color>(color),
        backgroundColor: trackColor,
      ),
    );
  }
}

class VisionStateView extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color accentColor;
  final bool compact;

  const VisionStateView({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
    this.accentColor = AppColors.primary,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(compact ? 8.w : 20.w),
        child: Container(
          constraints: BoxConstraints(maxWidth: compact ? 420.w : 520.w),
          padding: EdgeInsets.all(compact ? 18.w : 24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22.r),
            border: Border.all(color: accentColor.withValues(alpha: 0.12)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 56.w : 68.w,
                height: compact ? 56.w : 68.w,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: compact ? 26.sp : 30.sp,
                ),
              ),
              SizedBox(height: compact ? 14.h : 18.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 16.sp : 18.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111827),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: compact ? 12.sp : 13.sp,
                  height: 1.55,
                  color: AppColors.textSecondary,
                ),
              ),
              if (onAction != null && actionLabel != null) ...[
                SizedBox(height: 18.h),
                ElevatedButton.icon(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  icon: Icon(Icons.refresh_rounded, size: 18.sp),
                  label: Text(
                    actionLabel!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class VisionEmptySliverFill extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const VisionEmptySliverFill({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: 32.h),
        VisionStateView(
          icon: icon,
          title: title,
          message: message,
          compact: true,
        ),
      ],
    );
  }
}
