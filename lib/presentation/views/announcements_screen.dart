import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vision/domain/models/announcement.dart';
import 'package:vision/presentation/viewmodels/announcements_viewmodel.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AnnouncementsState announcementsState = ref.watch(announcementsStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Annonces École',
        showBackButton: false,
        hasNotification: false,
      ),
      body: announcementsState.when(
        data: (AnnouncementsStateLoaded state) => _buildList(context, ref, state.announcements),
        loading: () => const AnnouncementsLoadingView(),
        error: (String err, stack) => VisionStateView(
          icon: Icons.campaign_outlined,
          title: 'Erreur',
          message: err,
          actionLabel: 'Réessayer',
          onAction: () => ref.read(announcementsStateProvider.notifier).fetchAnnouncements(),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<Announcement> announcements) {
    if (announcements.isEmpty) {
      return const VisionStateView(
        icon: Icons.campaign_outlined,
        title: 'Aucune annonce',
        message: 'Les communications officielles de l’école apparaîtront ici.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(announcementsStateProvider.notifier).fetchAnnouncements();
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: announcements.length,
        itemBuilder: (context, index) {
          final announcement = announcements[index];
          return _buildAnnouncementCard(announcement);
        },
      ),
    );
  }

  Widget _buildAnnouncementCard(Announcement announcement) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1e3a8a).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              announcement.type == 'info' ? Icons.info_outline : Icons.notifications_none,
              color: const Color(0xFF1e3a8a),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  announcement.title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  announcement.content,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  DateFormat('dd MMM yyyy', 'fr_FR').format(announcement.publishedAt),
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
