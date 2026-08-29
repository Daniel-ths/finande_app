import 'package:uuid/uuid.dart';

enum MoneyItemType {
  streaming,
  fixedExpense,
  extraExpense,
  loanToReceive,
  monthlyNeed,
}

class MoneyItem {
  final String id;
  final MoneyItemType type;
  final String name;
  final double amount;
  final bool isPaidOrReceived;
  final DateTime? dueDate;
  final String? notes;
  final DateTime createdAt;

  MoneyItem({
    String? id,
    required this.type,
    required this.name,
    required this.amount,
    this.isPaidOrReceived = false,
    this.dueDate,
    this.notes,
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  MoneyItem copyWith({bool? isPaidOrReceived}) {
    return MoneyItem(
      id: id,
      type: type,
      name: name,
      amount: amount,
      isPaidOrReceived: isPaidOrReceived ?? this.isPaidOrReceived,
      dueDate: dueDate,
      notes: notes,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'name': name,
        'amount': amount,
        'isPaidOrReceived': isPaidOrReceived,
        'dueDate': dueDate?.toIso8601String(),
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
      };

  factory MoneyItem.fromJson(Map<String, dynamic> json) => MoneyItem(
        id: json['id'],
        type: MoneyItemType.values.byName(json['type']),
        name: json['name'],
        amount: (json['amount'] as num).toDouble(),
        isPaidOrReceived: json['isPaidOrReceived'] ?? false,
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        notes: json['notes'],
        createdAt: DateTime.parse(json['createdAt']),
      );
}
