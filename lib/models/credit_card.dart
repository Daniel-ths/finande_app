import 'package:uuid/uuid.dart';

class CreditCard {
  final String id;
  final String name;
  final double limit;
  double used;
  final int closingDay;
  final int dueDay;
  final String color;

  CreditCard({
    String? id,
    required this.name,
    required this.limit,
    this.used = 0.0,
    required this.closingDay,
    required this.dueDay,
    this.color = '#1565C0',
  }) : id = id ?? const Uuid().v4();

  double get available => limit - used;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'limit': limit,
        'used': used,
        'closingDay': closingDay,
        'dueDay': dueDay,
        'color': color,
      };

  factory CreditCard.fromJson(Map<String, dynamic> json) => CreditCard(
        id: json['id'],
        name: json['name'],
        limit: (json['limit'] as num).toDouble(),
        used: (json['used'] as num).toDouble(),
        closingDay: json['closingDay'],
        dueDay: json['dueDay'],
        color: json['color'] ?? '#1565C0',
      );
}
