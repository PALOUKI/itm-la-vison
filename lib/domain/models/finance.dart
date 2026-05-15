import 'package:vision/domain/models/child.dart';

class FinancesResponse {
  final bool success;
  final String message;
  final List<ChildFinance> children;

  FinancesResponse({
    required this.success,
    required this.message,
    required this.children,
  });

  factory FinancesResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as List? ?? [];
    return FinancesResponse(
      success: json['success'] as bool? ?? false,
      message: json['message'] as String? ?? '',
      children: data.map((e) => ChildFinance.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  factory FinancesResponse.fromJsonList(List<dynamic> jsonList) {
    return FinancesResponse(
      success: true,
      message: "Data loaded from list",
      children: jsonList.map((e) => ChildFinance.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class ChildFinance {
  final StudentMinimal student;
  final FinancialSummary summary;
  final List<PaymentRecord> recentPayments;
  final List<PaymentRecord> paymentHistory;
  final List<EcheancierHeader> echeancier;

  ChildFinance({
    required this.student,
    required this.summary,
    required this.recentPayments,
    required this.paymentHistory,
    required this.echeancier,
  });

  factory ChildFinance.fromJson(Map<String, dynamic> json) {
    final recent = json['recent_payements'] as List? ?? [];
    final history = json['paiement_history'] as List? ?? [];
    final ech = json['echeancier'] as List? ?? [];

    return ChildFinance(
      student: StudentMinimal.fromJson(json['student'] as Map<String, dynamic>),
      summary: FinancialSummary.fromJson(json['financial_summary'] as Map<String, dynamic>),
      recentPayments: recent.map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>)).toList(),
      paymentHistory: history.map((e) => PaymentRecord.fromJson(e as Map<String, dynamic>)).toList(),
      echeancier: ech.map((e) => EcheancierHeader.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class StudentMinimal {
  final int id;
  final String matricule;
  final String fullName;
  final String email;
  // Ajout de l'UUID pour la correspondance avec l'enfant sélectionné dans l'app
  // Note: Si l'API ne renvoie pas d'UUID, on utilisera l'ID ou on fera correspondre par matricule
  final String? uuid; 

  StudentMinimal({
    required this.id,
    required this.matricule,
    required this.fullName,
    required this.email,
    this.uuid,
  });

  factory StudentMinimal.fromJson(Map<String, dynamic> json) {
    return StudentMinimal(
      id: json['id'] as int,
      matricule: json['matricule'] as String? ?? '',
      fullName: json['full_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      uuid: json['uuid'] as String?,
    );
  }
}

class FinancialSummary {
  final num totalDue;
  final num totalPaid;
  final num balanceRemaining;
  final num percentagePaid;
  final num totalDiscount;
  final PaymentStatus status;
  final LastPayment? lastPayment;

  FinancialSummary({
    required this.totalDue,
    required this.totalPaid,
    required this.balanceRemaining,
    required this.percentagePaid,
    required this.totalDiscount,
    required this.status,
    this.lastPayment,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) {
    return FinancialSummary(
      totalDue: json['total_due'] ?? 0,
      totalPaid: json['total_paid'] ?? 0,
      balanceRemaining: json['balance_remaining'] ?? 0,
      percentagePaid: json['percentage_paid'] ?? 0,
      totalDiscount: json['total_discount'] ?? 0,
      status: PaymentStatus.fromJson(json['payment_status'] as Map<String, dynamic>),
      lastPayment: json['last_payment'] != null 
          ? LastPayment.fromJson(json['last_payment'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PaymentStatus {
  final int paidCount;
  final int unpaidCount;
  final bool isFullyPaid;

  PaymentStatus({
    required this.paidCount,
    required this.unpaidCount,
    required this.isFullyPaid,
  });

  factory PaymentStatus.fromJson(Map<String, dynamic> json) {
    return PaymentStatus(
      paidCount: json['paid_count'] ?? 0,
      unpaidCount: json['unpaid_count'] ?? 0,
      isFullyPaid: json['is_fully_paid'] ?? false,
    );
  }
}

class LastPayment {
  final num amount;
  final String date;
  final String? reference;

  LastPayment({
    required this.amount,
    required this.date,
    this.reference,
  });

  factory LastPayment.fromJson(Map<String, dynamic> json) {
    return LastPayment(
      amount: json['amount'] ?? 0,
      date: json['date'] as String? ?? '',
      reference: json['reference'] as String?,
    );
  }
}

class PaymentRecord {
  final String id;
  final num amount;
  final String date;
  final String? paymentMethod;
  final String? reference;
  final String? receiptNumber;
  final String? title;

  PaymentRecord({
    required this.id,
    required this.amount,
    required this.date,
    this.paymentMethod,
    this.reference,
    this.receiptNumber,
    this.title,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      id: json['id']?.toString() ?? '',
      amount: json['amount'] ?? 0,
      date: json['date'] as String? ?? '',
      paymentMethod: json['payment_method'] as String?,
      reference: json['reference'] as String?,
      receiptNumber: json['receipt_number'] as String?,
      title: json['title'] as String?,
    );
  }
}

class EcheancierHeader {
  final String title;
  final num total;
  final num paid;
  final num remaining;
  final String? dueDate;
  final String status;
  final List<Installment> installments;

  EcheancierHeader({
    required this.title,
    required this.total,
    required this.paid,
    required this.remaining,
    this.dueDate,
    required this.status,
    required this.installments,
  });

  factory EcheancierHeader.fromJson(Map<String, dynamic> json) {
    final inst = json['installments'] as List? ?? [];
    return EcheancierHeader(
      title: json['title'] as String? ?? '',
      total: json['total'] ?? 0,
      paid: json['paid'] ?? 0,
      remaining: json['remaining'] ?? 0,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String? ?? '',
      installments: inst.map((e) => Installment.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class Installment {
  final int installmentNumber;
  final String title;
  final num amount;
  final num paid;
  final num remaining;
  final String? dueDate;
  final String status;

  Installment({
    required this.installmentNumber,
    required this.title,
    required this.amount,
    required this.paid,
    required this.remaining,
    this.dueDate,
    required this.status,
  });

  factory Installment.fromJson(Map<String, dynamic> json) {
    return Installment(
      installmentNumber: json['installment_number'] ?? 0,
      title: json['title'] as String? ?? '',
      amount: json['amount'] ?? 0,
      paid: json['paid'] ?? 0,
      remaining: json['remaining'] ?? 0,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String? ?? '',
    );
  }
}
