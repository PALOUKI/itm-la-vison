import 'package:vision/domain/models/child.dart';
import 'package:vision/domain/models/children_response.dart';

class FinancesResponse {
  final AcademicYear? currentYear;
  final FinanceSummary summary;
  final List<ChildFinance> children;

  FinancesResponse({
    this.currentYear,
    required this.summary,
    required this.children,
  });

  factory FinancesResponse.fromJson(Map<String, dynamic> json) {
    final childrenData = json['children'];
    final childrenList = childrenData is List ? childrenData : [];

    return FinancesResponse(
      currentYear: json['current_year'] != null
          ? AcademicYear.fromJson(json['current_year'] as Map<String, dynamic>)
          : null,
      summary: FinanceSummary.fromJson(json['summary'] as Map<String, dynamic>),
      children: childrenList.map((e) => ChildFinance.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }

  /// Factory method to handle API response that returns a direct list of child finances
  factory FinancesResponse.fromJsonList(List<dynamic> jsonList) {
    final children = jsonList.map((e) => ChildFinance.fromJson(e as Map<String, dynamic>)).toList();

    // Calculate summary from children data
    num totalPaid = 0;
    for (var child in children) {
      final paid = num.tryParse(child.totalPaid) ?? 0;
      totalPaid += paid;
    }

    final summary = FinanceSummary(
      totalDue: 0,
      totalPaid: totalPaid,
      remainingBalance: 0,
      paymentPercentage: 0,
    );

    return FinancesResponse(
      currentYear: null,
      summary: summary,
      children: children,
    );
  }
}

class FinanceSummary {
  final num totalDue;
  final num totalPaid;
  final num remainingBalance;
  final num paymentPercentage;

  FinanceSummary({
    required this.totalDue,
    required this.totalPaid,
    required this.remainingBalance,
    required this.paymentPercentage,
  });

  factory FinanceSummary.fromJson(Map<String, dynamic> json) {
    return FinanceSummary(
      totalDue: json['total_due'] ?? 0,
      totalPaid: json['total_paid'] ?? 0,
      remainingBalance: json['remaining_balance'] ?? 0,
      paymentPercentage: json['payment_percentage'] ?? 0,
    );
  }
}

class ChildFinance {
  final Child student;
  final Enrollment? enrollment;
  final FinanceSummary summary;
  final List<FinanceRecord> records;
  final String totalPaid;
  final List<PaymentData> recentPayments;

  ChildFinance({
    required this.student,
    this.enrollment,
    required this.summary,
    required this.records,
    required this.totalPaid,
    required this.recentPayments,
  });

  factory ChildFinance.fromJson(Map<String, dynamic> json) {
    // Handle both the old format (with summary/records) and new format (with total_paid/recent_payments)
    final recordsData = json['records'];
    final recordsList = recordsData is List ? recordsData : [];

    final recentPaymentsData = json['recent_payments'];
    final recentPaymentsList = recentPaymentsData is List ? recentPaymentsData : [];

    final summary = json['summary'] != null
        ? FinanceSummary.fromJson(json['summary'] as Map<String, dynamic>)
        : FinanceSummary(
            totalDue: 0,
            totalPaid: num.tryParse(json['total_paid']?.toString() ?? '0') ?? 0,
            remainingBalance: 0,
            paymentPercentage: 0,
          );

    return ChildFinance(
      student: Child.fromJson(json['student'] as Map<String, dynamic>),
      enrollment: json['enrollment'] != null ? Enrollment.fromJson(json['enrollment'] as Map<String, dynamic>) : null,
      summary: summary,
      records: recordsList.map((e) => FinanceRecord.fromJson(e as Map<String, dynamic>)).toList(),
      totalPaid: json['total_paid']?.toString() ?? '0.00',
      recentPayments: recentPaymentsList.map((e) => PaymentData.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}

class FinanceRecord {
  final int id;
  final String uuid;
  final String refNo;
  final String year;
  final bool paid;
  final String amtPaid;
  final String lastPaymentAmount;
  final String? lastPaymentDate;
  final String balance;
  final List<PaymentHistory> paymentHistory;
  final Payment payment;

  FinanceRecord({
    required this.id,
    required this.uuid,
    required this.refNo,
    required this.year,
    required this.paid,
    required this.amtPaid,
    required this.lastPaymentAmount,
    this.lastPaymentDate,
    required this.balance,
    required this.paymentHistory,
    required this.payment,
  });

  factory FinanceRecord.fromJson(Map<String, dynamic> json) {
    final historyData = json['payment_history'];
    final historyList = historyData is List ? historyData : [];

    return FinanceRecord(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      refNo: json['ref_no'] as String,
      year: json['year'] as String,
      paid: json['paid'] as bool? ?? false,
      amtPaid: json['amt_paid'] as String? ?? '0',
      lastPaymentAmount: json['last_payment_amount'] as String? ?? '0',
      lastPaymentDate: json['last_payment_date'] as String?,
      balance: json['balance'] as String? ?? '0',
      paymentHistory: historyList.map((e) => PaymentHistory.fromJson(e as Map<String, dynamic>)).toList(),
      payment: Payment.fromJson(json['payment'] as Map<String, dynamic>),
    );
  }
}

class PaymentHistory {
  final String id;
  final num amount;
  final String paymentDate;
  final String? receiptNumber;
  final String paymentMethod;
  final String? reference;

  PaymentHistory({
    required this.id,
    required this.amount,
    required this.paymentDate,
    this.receiptNumber,
    required this.paymentMethod,
    this.reference,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) {
    return PaymentHistory(
      id: json['id'] as String,
      amount: json['amount'] ?? 0,
      paymentDate: json['payment_date'] as String,
      receiptNumber: json['receipt_number'] as String?,
      paymentMethod: json['payment_method'] as String,
      reference: json['reference'] as String?,
    );
  }
}

class Payment {
  final int id;
  final String uuid;
  final String title;
  final String amount;
  final String year;
  final String? reference;
  final String method;
  final String? description;

  Payment({
    required this.id,
    required this.uuid,
    required this.title,
    required this.amount,
    required this.year,
    this.reference,
    required this.method,
    this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      title: json['title'] as String,
      amount: json['amount'] as String? ?? '0',
      year: json['year'] as String,
      reference: json['reference'] as String?,
      method: json['method'] as String? ?? 'Cash',
      description: json['description'] as String?,
    );
  }
}

class PaymentData {
  final int id;
  final String uuid;
  final String? title;
  final String? amount;
  final String year;
  final String? reference;
  final String? method;
  final String? description;

  PaymentData({
    required this.id,
    required this.uuid,
    this.title,
    this.amount,
    required this.year,
    this.reference,
    this.method,
    this.description,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(
      id: json['id'] as int,
      uuid: json['uuid'] as String,
      title: json['title'] as String?,
      amount: json['amount'] as String?,
      year: json['year'] as String,
      reference: json['reference'] as String?,
      method: json['method'] as String?,
      description: json['description'] as String?,
    );
  }
}
