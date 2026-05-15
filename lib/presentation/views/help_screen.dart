import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: const CustomAppBar(
        title: 'Aide et Assistance',
        hasNotification: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroCard(
              title: 'Vous n’arrivez pas à vous connecter ?',
              description:
                  'Vérifiez vos identifiants, votre connexion internet et contactez l’administration si le problème persiste.',
            ),
            SizedBox(height: 16.h),
            _SectionCard(
              title: 'Étapes recommandées',
              children: const [
                _BulletItem(
                  text: 'Vérifiez que l’adresse email saisie correspond bien au compte parent communiqué par l’établissement.',
                ),
                _BulletItem(
                  text: 'Assurez-vous que votre mot de passe contient les bons caractères, sans espace ajouté par erreur.',
                ),
                _BulletItem(
                  text: 'Si votre connexion réseau est instable, réessayez quelques instants plus tard.',
                ),
                _BulletItem(
                  text: 'Si vous avez oublié votre mot de passe, demandez sa réinitialisation auprès de l’administration scolaire.',
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SectionCard(
              title: 'Quand contacter l’établissement',
              children: const [
                _BulletItem(
                  text: 'Votre compte parent n’est pas encore activé.',
                ),
                _BulletItem(
                  text: 'Vous ne voyez pas les informations de votre enfant après connexion.',
                ),
                _BulletItem(
                  text: 'Les notes, absences, paiements ou bulletins semblent incomplets ou erronés.',
                ),
              ],
            ),
            SizedBox(height: 16.h),
            _SectionCard(
              title: 'Informations utiles',
              children: [
                _InfoRow(
                  label: 'Accès',
                  value: 'Le portail est réservé aux parents autorisés par ITM La Vision.',
                ),
                SizedBox(height: 12.h),
                _InfoRow(
                  label: 'Réinitialisation',
                  value: 'La récupération du mot de passe se fait actuellement via l’administration.',
                ),
                SizedBox(height: 12.h),
                _InfoRow(
                  label: 'Confidentialité',
                  value: 'Ne partagez jamais vos identifiants avec une autre personne.',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  final String title;
  final String description;

  const _HeroCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1C3672), Color(0xFF3155A4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.support_agent,
              color: Colors.white,
              size: 24.sp,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            description,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.92),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 14.h),
          ...children,
        ],
      ),
    );
  }
}

class _BulletItem extends StatelessWidget {
  final String text;

  const _BulletItem({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: 6.h),
            width: 8.w,
            height: 8.w,
            decoration: const BoxDecoration(
              color: Color(0xFF1C3672),
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 13.sp,
                height: 1.5,
                color: const Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1C3672),
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 13.sp,
            height: 1.5,
            color: const Color(0xFF4B5563),
          ),
        ),
      ],
    );
  }
}
