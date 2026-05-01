import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vision/presentation/viewmodels/auth_viewmodel.dart';
import 'package:vision/presentation/viewmodels/profile_viewmodel.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';
import 'package:vision/config/constants.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  bool _pushEnabled = true;
  bool _emailEnabled = false;
  bool _securityEnabled = true;

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        title: 'Informations Parents',
        showBackButton: false,
        hasNotification: false,
      ),
      body: _buildBody(profileState),
    );
  }

  Widget _buildBody(ProfileState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a)));
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorOrNull ?? 'Erreur lors du chargement du profil'),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () => ref.read(profileStateProvider.notifier).fetchProfile(),
              child: const Text("Réessayer"),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () async {
                await ref.read(authStateProvider.notifier).logout();
                if (mounted && context.mounted) {
                  context.go('/login');
                }
              },
              child: const Text("Forcer la déconnexion", style: TextStyle(color: Colors.white)),
            )
          ],
        ),
      );
    }

    final user = state.dataOrNull;
    if (user == null) {
      return const Center(child: Text("Utilisateur introuvable."));
    }

    // Extraction du nom de famille simulée si on a un user.name
    // On extrait le dernier mot par exemple. Si c'est "KPADJA Kokoussè Nestor", le nom est "KPADJA".
    // Ou bien on affiche simplement le nom complet trunqué
    String displayName = "Utilisateur";
    if (user.name.isNotEmpty) {
      final nameParts = user.name.split(' ');
      if (nameParts.isNotEmpty && nameParts.last.isNotEmpty) {
        displayName = 'M. ${nameParts.last}';
      } else {
        displayName = user.name;
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
                          backgroundColor: Colors.grey.shade300,
                          backgroundImage: user.avatar != null
                              ? NetworkImage('${AppConstants.storageBaseUrl}/${user.avatar}')
                              : null,
                          child: user.avatar == null
                              ? Icon(Icons.person, size: 40.sp, color: Colors.grey.shade500)
                              : null,
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
                            color: const Color(0xFF1c3672),
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

            // Notifications & alertes
            _buildSectionCard(
              title: 'Notifications & Alertes',
              icon: Icons.notifications_none_outlined,
              children: [
                _buildToggleRow(
                  icon: Icons.phone_android,
                  title: "Notifications Push",
                  subtitle: "Alertes instantanées pour les notes, absences et messages.",
                  value: _pushEnabled,
                  onChanged: (v) => setState(() => _pushEnabled = v),
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

            SizedBox(height: 24.h),

            // Changer de compte
            /*
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.people_outline, size: 20.sp, color: Colors.black87),
                    ),
                    SizedBox(width: 12.w),

                    Expanded(
                      child: Text(
                        "Changer de compte",
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20.sp),
                  ],
                ),
              ),
            ),

             */

            SizedBox(height: 16.h),

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

            SizedBox(height: 32.h),

            // Footer
            Text(
              "Version de l'application : 2.4.0\n© 2026 ITM LA VISION - Tous droits réservés",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade400,
                height: 1.5,
              ),
            ),

            SizedBox(height: 40.h),
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
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
