import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vision/presentation/widgets/custom_app_bar.dart';

class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<LegalSection> sections;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  factory LegalDocumentScreen.terms() {
    return LegalDocumentScreen(
      title: 'Conditions d’utilisation',
      subtitle:
          'Ces conditions encadrent l’utilisation du portail parent ITM La Vision et la consultation des données scolaires.',
      sections: const [
        LegalSection(
          heading: '1. Objet du service',
          body:
              'L’application permet aux parents autorisés de consulter les informations scolaires, administratives et financières liées à leurs enfants inscrits dans l’établissement.',
        ),
        LegalSection(
          heading: '2. Accès au compte',
          body:
              'L’accès est personnel. Chaque parent est responsable de la confidentialité de ses identifiants et de toute action réalisée depuis son compte.',
        ),
        LegalSection(
          heading: '3. Usage autorisé',
          body:
              'Les informations affichées doivent être utilisées uniquement dans le cadre du suivi scolaire de l’élève. Toute tentative d’accès non autorisé, de copie massive ou de détournement du service est interdite.',
        ),
        LegalSection(
          heading: '4. Disponibilité des données',
          body:
              'L’établissement s’efforce de publier des informations exactes et à jour. Certaines données peuvent toutefois être mises à jour avec un délai raisonnable selon les processus internes.',
        ),
        LegalSection(
          heading: '5. Suspension d’accès',
          body:
              'L’établissement peut suspendre l’accès au portail en cas d’usage abusif, de risque de sécurité ou de maintenance technique nécessaire.',
        ),
      ],
    );
  }

  factory LegalDocumentScreen.privacy() {
    return LegalDocumentScreen(
      title: 'Politique de confidentialité',
      subtitle:
          'Cette politique décrit la manière dont les données affichées dans le portail parent sont traitées et protégées.',
      sections: const [
        LegalSection(
          heading: '1. Données concernées',
          body:
              'Le portail peut afficher des informations relatives au parent, à l’élève, aux résultats académiques, aux absences, aux paiements et aux communications scolaires.',
        ),
        LegalSection(
          heading: '2. Finalité',
          body:
              'Les données sont utilisées pour assurer le suivi pédagogique, administratif et financier des élèves ainsi que la communication entre l’établissement et les familles.',
        ),
        LegalSection(
          heading: '3. Confidentialité',
          body:
              'L’accès aux informations est limité aux personnes autorisées. Les identifiants ne doivent pas être partagés et l’utilisateur doit sécuriser son appareil.',
        ),
        LegalSection(
          heading: '4. Conservation et mise à jour',
          body:
              'Les données sont conservées selon les besoins administratifs et académiques de l’établissement. Elles peuvent être mises à jour au fil de l’année scolaire.',
        ),
        LegalSection(
          heading: '5. Contact',
          body:
              'Pour toute question relative à la confidentialité, à la correction d’une information ou à l’accès au compte, le parent doit se rapprocher de l’administration de l’établissement.',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: CustomAppBar(
        title: title,
        hasNotification: false,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: 14.sp,
                  height: 1.6,
                  color: const Color(0xFF4B5563),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            ...sections.map((section) => Padding(
                  padding: EdgeInsets.only(bottom: 14.h),
                  child: _LegalSectionCard(section: section),
                )),
          ],
        ),
      ),
    );
  }
}

class LegalSection {
  final String heading;
  final String body;

  const LegalSection({
    required this.heading,
    required this.body,
  });
}

class _LegalSectionCard extends StatelessWidget {
  final LegalSection section;

  const _LegalSectionCard({
    required this.section,
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
            section.heading,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            section.body,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.6,
              color: const Color(0xFF4B5563),
            ),
          ),
        ],
      ),
    );
  }
}
