import 'package:uuid/uuid.dart';

enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String description;
  final double amount;
  final TransactionType type;
  final String categoryId;
  final String accountId;
  final DateTime date;
  final String? notes;
  final bool isRecurring;
  final int? installmentNumber;
  final int? totalInstallments;
  final String? installmentGroupId;

  Transaction({
    String? id,
    required this.description,
    required this.amount,
    required this.type,
    required this.categoryId,
    required this.accountId,
    required this.date,
    this.notes,
    this.isRecurring = false,
    this.installmentNumber,
    this.totalInstallments,
    this.installmentGroupId,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'type': type.name,
        'categoryId': categoryId,
        'accountId': accountId,
        'date': date.toIso8601String(),
        'notes': notes,
        'isRecurring': isRecurring,
        'installmentNumber': installmentNumber,
        'totalInstallments': totalInstallments,
        'installmentGroupId': installmentGroupId,
      };

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        type: TransactionType.values.byName(json['type']),
        categoryId: json['categoryId'],
        accountId: json['accountId'],
        date: DateTime.parse(json['date']),
        notes: json['notes'],
        isRecurring: json['isRecurring'] ?? false,
        installmentNumber: json['installmentNumber'],
        totalInstallments: json['totalInstallments'],
        installmentGroupId: json['installmentGroupId'],
      );
}
