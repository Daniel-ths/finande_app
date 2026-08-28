import 'package:uuid/uuid.dart';

class FutureExpense {
  final String id;
  final String description;
  final double amount;
  final DateTime dueDate;
  final String? categoryId;
  final String? accountId;
  final bool isPaid;

  FutureExpense({
    String? id,
    required this.description,
    required this.amount,
    required this.dueDate,
    this.categoryId,
    this.accountId,
    this.isPaid = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'description': description,
        'amount': amount,
        'dueDate': dueDate.toIso8601String(),
        'categoryId': categoryId,
        'accountId': accountId,
        'isPaid': isPaid,
      };

  factory FutureExpense.fromJson(Map<String, dynamic> json) => FutureExpense(
        id: json['id'],
        description: json['description'],
        amount: (json['amount'] as num).toDouble(),
        dueDate: DateTime.parse(json['dueDate']),
        categoryId: json['categoryId'],
        accountId: json['accountId'],
        isPaid: json['isPaid'] ?? false,
      );
}
