import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/announcement.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/viewmodels/home_viewmodel.dart';
import 'package:vision/presentation/viewmodels/children_viewmodel.dart';
import 'package:vision/presentation/viewmodels/announcements_viewmodel.dart';
import 'package:vision/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:vision/presentation/widgets/child_card.dart';
import 'package:vision/presentation/widgets/home_header.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(childrenStateProvider.notifier).fetchChildren();
      ref.read(announcementsStateProvider.notifier).fetchAnnouncements();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final homeState = ref.watch(homeStateProvider);
    final selectedChild = ref.watch(selectedChildProvider);
    final announcementsState = ref.watch(announcementsStateProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: _buildBody(context, ref, authState, homeState, selectedChild, announcementsState),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AuthState authState,
    HomeState homeState,
    Child? selectedChild,
    AnnouncementsState announcementsState,
  ) {
    if (authState is! AuthStateAuthenticated) {
      return const Center(child: CircularProgressIndicator());
    }

    final user = authState.user;

    return Column(
      children: [
        // 1. TOPBAR SIMPLE (Logo + Notification)
        HomeHeader(
          onNotificationTap: () {},
        ),
        
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              await ref.read(homeStateProvider.notifier).fetchChildrenAndDashboard();
              await ref.read(announcementsStateProvider.notifier).fetchAnnouncements();
            },
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              children: [
                // 2. GREETING TEXT
                _buildGreeting(user.name),
                
                SizedBox(height: 24.h),

                // 3. STATS CARD (Inscrits)
                _buildStatsCard(homeState),

                SizedBox(height: 32.h),

                // 4. MES ENFANTS SECTION
                _buildChildrenSection(homeState, selectedChild),

                SizedBox(height: 12.h),

                // 5. ANNOUNCEMENTS SECTION
                _buildAnnouncementsSection(announcementsState),

                // Padding for floating navbar
                SizedBox(height: 120.h),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGreeting(String name) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Bonjour, ',
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            Text(
              name.split(" ").take(2).join(" "),
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1e3a8a),
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'Ravi de vous revoir sur votre portail parent.',
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard(HomeState state) {
    int count = 0;
    if (state is HomeStateData) {
      count = state.dashboardResponse.childrenCount;
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFF1e3a8a),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1e3a8a).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'INSCRIPTIONS',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.white.withOpacity(0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                '$count ${count > 1 ? 'Enfants  Inscrits' : 'Enfant Inscrit'}',
                style: TextStyle(
                  fontSize: 22.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.people_alt_rounded,
              color: Colors.white,
              size: 32.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenSection(HomeState state, Child? selectedChild) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.isError) {
      return Center(child: Text(state.errorOrNull ?? 'Erreur'));
    }

    final data = state.dataOrNull;
    if (data == null || data.childrenResponse.children.isEmpty) {
      return const Center(child: Text('Aucun enfant trouvé'));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'MES ENFANTS',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              child: Text(
                'Année ${data.dashboardResponse.currentYear?.name ?? 'N/A'}',

                style: TextStyle(
                  fontSize: 10.sp,
                  color:  Colors.grey,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        ...data.childrenResponse.children.map((child) => ChildCard(
              child: child,
              isSelected: selectedChild?.id == child.id,
              onTap: () {
                ref.read(selectedChildProvider.notifier).setChild(child);
                context.push('/home/child-detail/${child.uuid}');
              },
            )),
      ],
    );
  }

  Widget _buildAnnouncementsSection(AnnouncementsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'ANNONCES',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade500,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(navigationProvider.notifier).goToTab(1);
              },
              child: Text(
                'Tout voir',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: const Color(0xFF1e3a8a),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        if (state.isLoading)
          const Center(child: CircularProgressIndicator())
        else if (state.isError)
          Center(child: Text(state.errorOrNull ?? 'Erreur lors du chargement des annonces'))
        else if (state.announcementsOrNull == null || state.announcementsOrNull!.isEmpty)
          const Center(child: Text('Aucune annonce pour le moment'))
        else
          ...state.announcementsOrNull!.take(5).map((announcement) => _buildAnnouncementCard(announcement)),
      ],
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
            color: Colors.black.withOpacity(0.03),
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
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  _formatDate(announcement.publishedAt),
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

  String _formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy', 'fr_FR').format(date);
  }
}
