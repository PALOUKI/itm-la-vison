import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/viewmodels/profile_viewmodel.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';
import 'package:vision/config/constants.dart';
import 'package:vision/core/services/notification_service.dart';
import 'package:vision/core/utils/image_utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _emailEnabled = false;
  bool _securityEnabled = true;

  Widget _buildAvatarPlaceholder(String fullName) {
    String initials = '';
    if (fullName.isNotEmpty) {
      final names = fullName.trim().split(' ');
      if (names.length >= 2) {
        initials = '${names[0][0]}${names[names.length - 1][0]}';
      } else if (names.isNotEmpty && names[0].isNotEmpty) {
        initials = names[0][0];
      }
    }

    return Center(
      child: Text(
        initials.toUpperCase(),
        style: TextStyle(
          color: const Color(0xFF1c3672),
          fontWeight: FontWeight.bold,
          fontSize: 24.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateProvider);
    final pushEnabled = ref.watch(notificationServiceProvider).isEnabled();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        title: 'Informations Parents',
        showBackButton: false,
        hasNotification: false,
      ),
      body: _buildBody(profileState, pushEnabled),
    );
  }

  Widget _buildBody(ProfileState state, bool pushEnabled) {
    if (state.isLoading) {
      return const ProfileLoadingView();
    }

    if (state.isError) {
      return VisionStateView(
        icon: Icons.person_off_outlined,
        title: 'Profil indisponible',
        message: state.errorOrNull ?? 'Impossible de charger les informations du parent pour le moment.',
        actionLabel: 'Réessayer',
        onAction: () => ref.read(profileStateProvider.notifier).fetchProfile(),
        accentColor: const Color(0xFFDC2626),
      );
    }

    final user = state.dataOrNull;
    if (user == null) {
      return const VisionStateView(
        icon: Icons.person_search_outlined,
        title: 'Utilisateur introuvable',
        message: 'Les informations du compte parent ne sont pas encore disponibles.',
      );
    }

    String displayName = user.name;
    if (user.name.isNotEmpty) {
      final nameParts = user.name.split(' ');
      if (nameParts.isNotEmpty && nameParts.last.isNotEmpty) {
        displayName = 'M. ${nameParts.last}';
      }
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          children: [
            // Avatar & Name
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFFE2E8F0),
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 40.r,
                          backgroundColor: const Color(0xFF1c3672).withOpacity(0.1),
                          child: ClipOval(
                            child: ImageUtils.getImageUrl(user.avatar) != null
                                ? Image.network(
                                    ImageUtils.getImageUrl(user.avatar)!,
                                    fit: BoxFit.cover,
                                    width: 80.r,
                                    height: 80.r,
                                    errorBuilder: (context, error, stackTrace) => _buildAvatarPlaceholder(user.name),
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Center(
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: const Color(0xFF1c3672).withOpacity(0.3),
                                        ),
                                      );
                                    },
                                  )
                                : _buildAvatarPlaceholder(user.name),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: EdgeInsets.all(2.w),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.check_circle,
                            color: const Color(0xFF10B981),
                            size: 20.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    displayName,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1c3672).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      "Parent d'élève",
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: const Color(0xFF1c3672),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 32.h),

            // Coordonnées de contact
            _buildSectionCard(
              title: 'Coordonnées de Contact',
              icon: Icons.person_outline,
              children: [
                _buildInfoRow(Icons.mail_outline, "ADRESSE EMAIL", user.email),
                _buildDivider(),
                _buildInfoRow(Icons.phone_outlined, "NUMÉRO DE TÉLÉPHONE", user.phone ?? 'Non défini'),
                _buildDivider(),
                _buildInfoRow(Icons.language, "LANGUE DE L'INTERFACE", "Français (FR)"),
              ],
            ),

            SizedBox(height: 16.h),

            // Notifications & alertes (Rendu fonctionnel)
            _buildSectionCard(
              title: 'Notifications & Alertes',
              icon: Icons.notifications_none_outlined,
              children: [
                _buildToggleRow(
                  icon: Icons.phone_android,
                  title: "Notifications Push",
                  subtitle: "Alertes instantanées pour les notes, absences et messages.",
                  value: pushEnabled,
                  onChanged: (v) async {
                    await ref.read(notificationServiceProvider).toggleNotifications(v);
                    setState(() {});
                  },
                ),
                _buildDivider(),
                _buildToggleRow(
                  icon: Icons.mail_outline,
                  title: "Alertes Email",
                  subtitle: "Recevez un résumé hebdomadaire des activités scolaires.",
                  value: _emailEnabled,
                  onChanged: (v) => setState(() => _emailEnabled = v),
                ),
                _buildDivider(),
                _buildToggleRow(
                  icon: Icons.shield_outlined,
                  title: "Sécurité du Compte",
                  subtitle: "Alertes en cas de connexion depuis un nouvel appareil.",
                  value: _securityEnabled,
                  onChanged: (v) => setState(() => _securityEnabled = v),
                ),
              ],
            ),

            SizedBox(height: 26.h),

            // Déconnexion
            InkWell(
              onTap: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (mounted && context.mounted) {
                  context.go('/login');
                }
              },
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout, color: Colors.white, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      "Se déconnecter",
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 26.h),

            // Footer
            Text(
              "Version de l'application : 2.4.0\n© 2026 ITM LA VISION",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),

            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Icon(icon, size: 20.sp, color: const Color(0xFF1c3672)),
                SizedBox(width: 8.w),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFF1c3672).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: const Color(0xFF1c3672)),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 20.sp, color: Colors.grey.shade600),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade500,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          CupertinoSwitch(
            value: value,
            activeColor: const Color(0xFF1c3672),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      color: Colors.grey.shade100,
      indent: 16.w,
      endIndent: 16.w,
    );
  }
}
