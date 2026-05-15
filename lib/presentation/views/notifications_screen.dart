import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:vision/domain/models/message.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/data/repositories/messages_repository.dart';
import 'package:vision/presentation/viewmodels/children_viewmodel.dart';
import 'package:vision/presentation/viewmodels/navigation_viewmodel.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['Tous', 'Scolarité', 'Paiements'];

  @override
  Widget build(BuildContext context) {
    final notificationsState = ref.watch(notificationsListProvider(1));

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: const CustomAppBar(
        title: 'Centre de Notifications',
        showBackButton: false,
        hasNotification: false,
      ),
      body: Column(
        children: [
          // Filtres (Sans fond blanc massif)
          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.h),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                children: List.generate(
                  _filters.length,
                  (index) => Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: _buildFilterChip(
                      title: _filters[index],
                      isSelected: _selectedFilterIndex == index,
                      onTap: () => setState(() => _selectedFilterIndex = index),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Liste
          Expanded(
            child: notificationsState.when(
              data: (NotificationsResponse response) {
                final filteredList = _filterNotifications(response.notifications);
                return _buildList(context, ref, filteredList);
              },
              loading: () => const AnnouncementsLoadingView(),
              error: (err, stack) => VisionStateView(
                icon: Icons.notifications_off_outlined,
                title: 'Erreur',
                message: err.toString(),
                actionLabel: 'Réessayer',
                onAction: () => ref.refresh(notificationsListProvider(1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<AppNotification> _filterNotifications(List<AppNotification> list) {
    if (_selectedFilterIndex == 0) return list;
    
    return list.where((notif) {
      switch (_selectedFilterIndex) {
        case 1: // Scolarité (Notes, Absences, Inscriptions)
          return ['grades_published', 'attendance_recorded', 'enrollment_approved'].contains(notif.type);
        case 2: // Paiements
          return notif.type == 'payment_received';
        default:
          return true;
      }
    }).toList();
  }

  Widget _buildFilterChip({required String title, required bool isSelected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1c3672) : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
          ),
          boxShadow: isSelected ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 12.sp,
          ),
        ),
      ),
    );
  }

  Widget _buildList(BuildContext context, WidgetRef ref, List<AppNotification> notifications) {
    if (notifications.isEmpty) {
      return const VisionStateView(
        icon: Icons.notifications_none_outlined,
        title: 'Aucune notification',
        message: 'Vous n\'avez reçu aucune notification correspondant à ce filtre.',
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(notificationsListProvider(1));
        ref.invalidate(unreadNotificationsCountProvider);
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(context, ref, notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(BuildContext context, WidgetRef ref, AppNotification notif) {
    final bool isUnread = !notif.isRead;

    return GestureDetector(
      onTap: () async {
        if (isUnread && notif.uuid != null) {
          try {
            await ref.read(messagesRepositoryProvider).markAsRead(notif.uuid!);
            ref.invalidate(notificationsListProvider(1));
            ref.invalidate(unreadNotificationsCountProvider);
          } catch (e) {
            debugPrint('Erreur lors du marquage comme lu: $e');
          }
        }
        _handleNavigation(context, ref, notif);
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isUnread ? const Color(0xFF1c3672).withOpacity(0.03) : Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isUnread ? const Color(0xFF1c3672).withOpacity(0.2) : Colors.grey.shade100,
            width: 1,
          ),
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
            _buildIcon(notif.type),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w600,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF1c3672),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    notif.message,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    _formatDate(notif.createdAt),
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, WidgetRef ref, AppNotification notif) {
    try {
      dynamic data = notif.data;
      if (data is String) {
        data = jsonDecode(data);
      }

      final childrenState = ref.read(childrenStateProvider);
      final children = childrenState.dataOrNull?.children ?? [];
      
      final studentId = data != null ? data['student_id'] : null;
      final child = children.where((c) => c.id.toString() == studentId?.toString()).firstOrNull;

      switch (notif.type) {
        case 'announcement':
          ref.read(navigationProvider.notifier).goToTab(1);
          break;

        case 'grades_published':
          if (child != null) {
            context.push('/home/child-detail/${child.uuid}/grades', extra: child);
          } else {
            ref.read(navigationProvider.notifier).goToTab(0);
          }
          break;

        case 'attendance_recorded':
          if (child != null) {
            context.push('/home/child-detail/${child.uuid}/attendances');
          }
          break;

        case 'payment_received':
          if (child != null) {
            context.push('/home/child-detail/${child.uuid}/finances');
          } else {
            ref.read(navigationProvider.notifier).goToTab(0);
          }
          break;

        case 'enrollment_approved':
          if (child != null) {
            context.push('/home/child-detail/${child.uuid}');
          }
          break;

        default:
          debugPrint('Navigation non gérée pour: ${notif.type}');
      }
    } catch (e) {
      debugPrint('Erreur navigation: $e');
    }
  }

  Widget _buildIcon(String type) {
    IconData iconData;
    Color color;

    switch (type) {
      case 'payment_received':
        iconData = Icons.account_balance_wallet_outlined;
        color = Colors.green;
        break;
      case 'grades_published':
        iconData = Icons.assignment_outlined;
        color = Colors.blue;
        break;
      case 'attendance_recorded':
        iconData = Icons.event_busy_outlined;
        color = Colors.orange;
        break;
      case 'announcement':
        iconData = Icons.campaign_outlined;
        color = Colors.purple;
        break;
      case 'enrollment_approved':
        iconData = Icons.check_circle_outline;
        color = Colors.teal;
        break;
      default:
        iconData = Icons.notifications_none_outlined;
        color = Colors.grey;
    }

    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: color, size: 20.sp),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} h';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
}
