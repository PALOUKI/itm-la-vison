import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:vision/config/themes/app_colors.dart';
import 'package:vision/domain/models/finance.dart';
import 'package:vision/presentation/viewmodels/finances_viewmodel.dart';
import 'package:vision/presentation/viewmodels/children_viewmodel.dart';
import 'package:vision/presentation/widgets/shimmer_loaders.dart';

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
        centerTitle: true,
        title: Text(
          'Paiements',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
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
      return const FinancesLoadingView();
    }

    if (state.isError) {
      return VisionStateView(
        icon: Icons.account_balance_wallet_outlined,
        title: 'Paiements indisponibles',
        message: state.errorOrNull ?? 'Impossible de charger les données financières.',
        actionLabel: 'Réessayer',
        onAction: () => ref.read(financesStateProvider.notifier).fetchFinances(),
        accentColor: const Color(0xFFDC2626),
      );
    }

    final data = state.dataOrNull;
    if (data == null || data.response.children.isEmpty) {
      return const VisionStateView(
        icon: Icons.receipt_long_outlined,
        title: 'Aucune donnée financière',
        message: 'Les informations de paiement seront affichées ici dès qu’elles seront disponibles.',
      );
    }

    // Retrouver le matricule de l'enfant à partir de son UUID
    final childrenState = ref.watch(childrenStateProvider);
    String? childMatricule;
    if (childrenState is ChildrenStateLoaded) {
      try {
        childMatricule = childrenState.data.children.firstWhere((c) => c.uuid == childUuid).matricule;
      } catch (e) {}
    }

    // Trouver les données spécifiques à l'enfant (par matricule ou par défaut)
    final childFinance = data.response.children.firstWhere(
      (c) => c.student.matricule == childMatricule || c.student.uuid == childUuid,
      orElse: () => data.response.children.first,
    );

    final summary = childFinance.summary;
    final history = childFinance.paymentHistory;
    final echeancier = childFinance.echeancier;

    return RefreshIndicator(
      onRefresh: () => ref.read(financesStateProvider.notifier).fetchFinances(),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Situation Globale
            _buildSituationGlobale(summary),

            SizedBox(height: 24.h),

            // 2. Échéancier
            _buildSectionHeader('Échéancier', Icons.calendar_month_outlined),
            SizedBox(height: 12.h),
            if (echeancier.isEmpty)
              _buildEmptyState(
                Icons.event_note_outlined,
                'Aucun échéancier disponible',
                'Aucune échéance n’a été publiée pour le moment.',
              )
            else
              ...echeancier.expand((h) => h.installments).map(_buildInstallmentItem),

            SizedBox(height: 24.h),

            // 3. Derniers paiements
            _buildSectionHeader('Derniers paiements', Icons.history),
            SizedBox(height: 12.h),
            _buildDerniersPaiementsList(history),

            SizedBox(height: 24.h),

            // 4. Note Importante
            _buildImportantNote(),

            SizedBox(height: 48.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSituationGlobale(FinancialSummary summary) {
    final double percentage = summary.percentagePaid.toDouble();
    final formatter = NumberFormat("#,###", "fr_FR");

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: AppColors.darkBlue,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1c3672).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Situation Globale',
                style: TextStyle(color: Colors.white, fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              Container(
                height: 40.h,
                width: 40.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    Icons.credit_card_outlined,
                    color: Colors.white.withOpacity(0.5),
                    size: 22.sp,
                  ),
                ),
              ),

            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _buildAmountField('TOTAL PAYÉ', summary.totalPaid, Colors.white),
              ),
              Container(width: 1, height: 40.h, color: Colors.white.withOpacity(0.1)),
              Expanded(
                child: _buildAmountField('RESTE À PAYER', summary.balanceRemaining, const Color(0xFFFB7185), isRight: true),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Progression', style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 11.sp)),
              Text('${percentage.toStringAsFixed(1)}%', style: TextStyle(color: Colors.white, fontSize: 12.sp, fontWeight: FontWeight.bold)),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: LinearProgressIndicator(
              value: percentage / 100,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8.h,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Total Scolarité', style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12.sp)),
              Text('${formatter.format(summary.totalDue)} FCFA', style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAmountField(String label, num amount, Color color, {bool isRight = false}) {
    final formatter = NumberFormat("#,###", "fr_FR");
    return Column(
      crossAxisAlignment: isRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 10.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 4.h),
        FittedBox(
          child: Text(
            '${formatter.format(amount)} F',
            style: TextStyle(color: color, fontSize: 20.sp, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: const Color(0xFF1e3a8a)),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1E293B)),
        ),
      ],
    );
  }

  Widget _buildInstallmentItem(Installment installment) {
    final formatter = NumberFormat("#,###", "fr_FR");
    final bool isPaid = installment.status == 'paid';
    final bool isPartial = installment.status == 'partial';

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: isPartial ? const Color(0xFFFEF3C7) : Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: isPaid ? const Color(0xFFF0FDF4) : (isPartial ? const Color(0xFFFFFBEB) : const Color(0xFFF1F5F9)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isPaid ? Icons.check_circle : (isPartial ? Icons.pending_actions : Icons.schedule),
              color: isPaid ? const Color(0xFF10B981) : (isPartial ? const Color(0xFFF59E0B) : Colors.grey.shade500),
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(installment.title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF334155))),
                SizedBox(height: 2.h),
                if (installment.dueDate != null)
                  Text(
                    'Échéance: ${DateFormat('dd MMM yyyy', 'fr_FR').format(DateTime.parse(installment.dueDate!))}',
                    style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500),
                  ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${formatter.format(installment.amount)} F', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF1e3a8a))),
              SizedBox(height: 4.h),
              _buildStatusBadge(installment.status),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color bgColor;
    Color textColor;
    String label;

    switch (status) {
      case 'paid':
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        label = 'PAYÉ';
        break;
      case 'partial':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFF92400E);
        label = 'PARTIEL';
        break;
      case 'overdue':
        bgColor = const Color(0xFFFEE2E2);
        textColor = const Color(0xFF991B1B);
        label = 'RETARD';
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = Colors.grey.shade600;
        label = 'EN ATTENTE';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.sp,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildDerniersPaiementsList(List<PaymentRecord> payments) {
    if (payments.isEmpty) {
      return _buildEmptyState(Icons.history_toggle_off_rounded, 'Aucun paiement', 'L’historique apparaîtra ici.');
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        children: [
          ...payments.take(5).map((p) => _buildPaiementRow(p)),
          if (payments.length > 5)
            Padding(
              padding: EdgeInsets.all(12.h),
              child: Text('Voir tout l’historique', style: TextStyle(fontSize: 12.sp, color: const Color(0xFF1e3a8a), fontWeight: FontWeight.w600)),
            ),
        ],
      ),
    );
  }

  Widget _buildPaiementRow(PaymentRecord payment) {
    final formatter = NumberFormat("#,###", "fr_FR");
    DateTime date = DateTime.tryParse(payment.date) ?? DateTime.now();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10.r)),
                child: Icon(Icons.receipt_long_outlined, size: 18.sp, color: const Color(0xFF475569)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(DateFormat('dd MMMM yyyy', 'fr_FR').format(date), style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: const Color(0xFF1E293B))),
                    Text(payment.paymentMethod ?? 'Paiement', style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade500)),
                  ],
                ),
              ),
              Text(
                '${formatter.format(payment.amount)} F',
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: const Color(0xFF10B981)),
              ),
            ],
          ),
        ),
        Divider(height: 1, color: Colors.grey.shade50),
      ],
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String msg) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16.r)),
      child: Column(
        children: [
          Icon(icon, size: 40.sp, color: Colors.grey.shade300),
          SizedBox(height: 12.h),
          Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
          SizedBox(height: 4.h),
          Text(msg, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400)),
        ],
      ),
    );
  }

  Widget _buildImportantNote() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: const Color(0xFF1e3a8a), size: 18.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              "Les paiements s'effectuent directement à la comptabilité de l'école. Cette application sert uniquement au suivi de votre situation financière.",
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF475569), height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
