import 'package:uuid/uuid.dart';

class InstallmentPurchase {
  final String id;
  final String description;
  final double totalAmount;
  final int totalInstallments;
  final int paidInstallments;
  final double installmentValue;
  final DateTime startDate;
  final String? accountId;
  final String? cardId;
  final String? categoryId;
  final String? notes;

  InstallmentPurchase({
    String? id,
    required this.description,
    required this.totalAmount,
    required this.totalInstallments,
    this.paidInstallments = 0,
    required this.installmentValue,
    required this.startDate,
    this.accountId,
    this.cardId,
    this.categoryId,
    this.notes,
  }) : id = id ?? const Uuid().v4();

  int get remainingInstallments => (totalInstallments - paidInstallments).clamp(0, totalInstallments);
  double get remainingAmount => remainingInstallments * installmentValue;
  bool get isCompleted => paidInstallments >= totalInstallments;
  double get progress => totalInstallments > 0 ? paidInstallments / totalInstallments : 0;

  /// Data da próxima parcela
  DateTime? get nextDueDate {
    if (isCompleted) return null;
    return DateTime(startDate.year, startDate.month + paidInstallments, startDate.day);
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'totalAmount': totalAmount,
        'totalInstallments': totalInstallments,
        'paidInstallments': paidInstallments,
        'installmentValue': installmentValue,
        'startDate': startDate.toIso8601String(),
        'accountId': accountId,
        'cardId': cardId,
        'categoryId': categoryId,
        'notes': notes,
      };

  factory InstallmentPurchase.fromJson(Map<String, dynamic> json) => InstallmentPurchase(
        id: json['id'],
        description: json['description'],
        totalAmount: (json['totalAmount'] as num).toDouble(),
        totalInstallments: json['totalInstallments'],
        paidInstallments: json['paidInstallments'] ?? 0,
        installmentValue: (json['installmentValue'] as num).toDouble(),
        startDate: DateTime.parse(json['startDate']),
        accountId: json['accountId'],
        cardId: json['cardId'],
        categoryId: json['categoryId'],
        notes: json['notes'],
      );

  InstallmentPurchase copyWith({int? paidInstallments}) {
    return InstallmentPurchase(
      id: id,
      description: description,
      totalAmount: totalAmount,
      totalInstallments: totalInstallments,
      paidInstallments: paidInstallments ?? this.paidInstallments,
      installmentValue: installmentValue,
      startDate: startDate,
      accountId: accountId,
      cardId: cardId,
      categoryId: categoryId,
      notes: notes,
    );
  }
}
