import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vision/config/themes/app_colors.dart';
import 'package:vision/domain/models/finance.dart';
import 'package:vision/presentation/viewmodels/finances_viewmodel.dart';


class FinancesScreen extends ConsumerWidget {
  final String childUuid;
  const FinancesScreen({super.key, required this.childUuid});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(financesStateProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text('Paiements', style: TextStyle(color: Colors.black, fontSize: 18.sp, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20.sp),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, FinancesState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator(color: Color(0xFF1e3a8a)));
    }

    if (state.isError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorOrNull ?? 'Erreur lors du chargement des finances'),
            TextButton(
              onPressed: () => ref.read(financesStateProvider.notifier).fetchFinances(),
              child: const Text("Réessayer"),
            )
          ],
        ),
      );
    }

    final data = state.dataOrNull;
    if (data == null) {
      return const Center(child: Text("Aucune donnée financière trouvée."));
    }

    // Retrouver l'enfant sélectionné
    final childFinance = data.response.children.firstWhere(
      (c) => c.student.uuid == childUuid,
      orElse: () => data.response.children.first,
    );
    final summary = childFinance.summary;

    final records = childFinance.records;
    List<PaymentHistory> allPayments = [];
    for (var r in records) {
      allPayments.addAll(r.paymentHistory);
    }
    // Sort payments descending
    allPayments.sort((a, b) => b.paymentDate.compareTo(a.paymentDate));

    return RefreshIndicator(
      onRefresh: () => ref.read(financesStateProvider.notifier).fetchFinances(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Situation Globale Card
            _buildSituationGlobale(summary),

            SizedBox(height: 24.h),

            // 2. Échéancier
            _buildSectionHeader('Échéancier', null),
            SizedBox(height: 12.h),
            ...records.map(_buildEcheancierItem),

            SizedBox(height: 24.h),

            // 3. Derniers paiements
            _buildSectionHeader('Derniers paiements', null),
            SizedBox(height: 12.h),
            _buildDerniersPaiementsList(allPayments),

            SizedBox(height: 24.h),

            // 4. Note Importante
            _buildImportantNote(),

            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationGlobale(FinanceSummary summary) {
    // Determine progress bar length
    final double total = summary.totalDue.toDouble();
    final double paid = summary.totalPaid.toDouble();
    final double percentage = summary.paymentPercentage.toDouble();

    final formatter = NumberFormat("#,###", "fr_FR");

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkBlue, // Dark blue
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1c3672).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Situation Globale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Année Académique 2023-2024',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12.sp,
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_outlined,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'TOTAL PAYÉ',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${formatter.format(paid)} F',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'RESTE À PAYER',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${formatter.format(summary.remainingBalance)} F',
                    style: TextStyle(
                      color: const Color(0xFFEF4444), // Red
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Progression des paiements',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 11.sp,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withOpacity(0.2),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 6.h,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Montant total scolarité',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12.sp,
                ),
              ),
              Text(
                '${formatter.format(total)} FCFA',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Icon(
              title == 'Échéancier' ? Icons.calendar_month_outlined : Icons.history,
              size: 20.sp,
              color: const Color(0xFF1c3672),
            ),
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        if (actionText != null)
          TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              actionText,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFF1c3672),
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEcheancierItem(FinanceRecord record) {
    final formatter = NumberFormat("#,###", "fr_FR");
    final num amt = num.tryParse(record.payment.amount) ?? 0;

    // Détermination du statut et des couleurs à partir de record.paid
    // Dans un vrai scénario, "À venir" ou "En retard" nécessiterait une date d'échéance.
    // On simule pour coller à la maquette.
    bool estPaye = record.paid;
    bool estRetard = !estPaye && (record.balance != "0" && amt > 150000); // simulation arbitraire
    
    IconData iconData = Icons.account_balance_wallet_outlined;
    Color iconColor = Colors.grey.shade600;
    Color iconBgColor = Colors.grey.shade100;
    String statusStr = 'À venir';
    Color statusBgColor = Colors.grey.shade100;
    Color statusTextColor = Colors.black87;

    if (estPaye) {
      iconData = Icons.check_circle_outline;
      iconColor = Colors.black87;
      iconBgColor = Colors.white;
      statusStr = 'Payé';
    } else if (estRetard) {
      iconData = Icons.error_outline;
      iconColor = const Color(0xFFEF4444);
      iconBgColor = const Color(0xFFFEF2F2);
      statusStr = 'En retard';
      statusBgColor = const Color(0xFFFCA5A5);
      statusTextColor = Colors.white;
    }

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: estRetard ? const Color(0xFFFFF5F5) : Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: estRetard ? const Color(0xFFFECACA) : Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: iconBgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.payment.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Échéance: ${record.year}', // Idealement une vraie date
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${formatter.format(amt)} FCFA',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4.h),
              if (estPaye)
                Text(
                  'Payé',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: statusBgColor,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    statusStr,
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: statusTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDerniersPaiementsList(List<PaymentHistory> payments) {
    if (payments.isEmpty) {
      return Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: const Center(child: Text("Aucun historique récent.")),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Text(
                    'DATE',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Text(
                    'MONTANT',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
                Text(
                  'REÇU',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Afficher les 3 derniers par exemple
          ...payments.take(3).map((p) => _buildPaiementRow(p)),

          // Bouton Télécharger tout
          const Divider(height: 1),
          InkWell(
            onTap: () {},
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              alignment: Alignment.center,
              child: Text(
                "Télécharger l'historique complet (PDF)",
                style: TextStyle(
                  fontSize: 12.sp,
                  color: const Color(0xFF1c3672),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaiementRow(PaymentHistory history) {
    final formatter = NumberFormat("#,###", "fr_FR");
    DateTime date = DateTime.tryParse(history.paymentDate) ?? DateTime.now();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd MMM\nyyyy', 'fr_FR').format(date).toUpperCase(),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  history.paymentMethod,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              '${formatter.format(history.amount)} FCFA',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.download_outlined,
              color: const Color(0xFF1c3672),
              size: 20.sp,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildImportantNote() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F6FB), // Light blue-grey background
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: const Color(0xFF475569),
            size: 20.sp,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTE IMPORTANTE',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF334155),
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  "Les paiements s'effectuent directement à la comptabilité de l'école ou par virement bancaire. Aucun paiement en ligne n'est requis sur cette application.",
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: const Color(0xFF64748B),
                    height: 1.4,
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
