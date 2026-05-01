import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/presentation/viewmodels/announcements_viewmodel.dart';
import 'package:vision/presentation/widgets/announcement_card.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';

class AnnouncementsScreen extends ConsumerWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final announcementsState = ref.watch(announcementsStateProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Annonces',
        showBackButton: false,
      ),
      body: Consumer(
        builder: (context, ref, _) {
          if (announcementsState is AnnouncementsStateLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (announcementsState is AnnouncementsStateError) {
            return Center(child: Text('Error: ${announcementsState.message}'));
          } else if (announcementsState is AnnouncementsStateLoaded) {
            final announcements = announcementsState.announcements;
            if (announcements.isEmpty) {
              return const Center(child: Text('Aucune annonce disponible.'));
            }
            return ListView.builder(
              padding: EdgeInsets.all(16.w),
              itemCount: announcements.length,
              itemBuilder: (context, index) {
                return AnnouncementCard(announcement: announcements[index]);
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

