import 'package:uuid/uuid.dart';

enum AccountType { checking, digital, savings, cash, digitalWallet }

class Account {
  final String id;
  final String name;
  final AccountType type;
  double balance;
  final String color;
  final bool isActive;

  Account({
    String? id,
    required this.name,
    required this.type,
    this.balance = 0.0,
    this.color = '#1B5E20',
    this.isActive = true,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type.name,
        'balance': balance,
        'color': color,
        'isActive': isActive,
      };

  factory Account.fromJson(Map<String, dynamic> json) => Account(
        id: json['id'],
        name: json['name'],
        type: AccountType.values.byName(json['type']),
        balance: (json['balance'] as num).toDouble(),
        color: json['color'] ?? '#1B5E20',
        isActive: json['isActive'] ?? true,
      );
}
