import 'package:uuid/uuid.dart';

class Goal {
  final String id;
  final String name;
  final double targetAmount;
  double currentAmount;
  final DateTime? deadline;
  final String icon;
  final DateTime createdAt;

  Goal({
    String? id,
    required this.name,
    required this.targetAmount,
    this.currentAmount = 0.0,
    this.deadline,
    this.icon = '🎯',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  double get progress =>
      targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;

  double get remaining =>
      (targetAmount - currentAmount).clamp(0.0, double.infinity);

  bool get isCompleted => currentAmount >= targetAmount;

  /// Quanto precisa guardar por mês até o prazo
  double get monthlyNeeded {
    if (deadline == null || isCompleted) return 0;
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return remaining;
    final monthsLeft = (daysLeft / 30).ceil().clamp(1, 999);
    return remaining / monthsLeft;
  }

  /// Quanto precisa guardar por dia até o prazo
  double get dailyNeeded {
    if (deadline == null || isCompleted) return 0;
    final daysLeft = deadline!.difference(DateTime.now()).inDays;
    if (daysLeft <= 0) return remaining;
    return remaining / daysLeft;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'targetAmount': targetAmount,
        'currentAmount': currentAmount,
        'deadline': deadline?.toIso8601String(),
        'icon': icon,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Goal.fromJson(Map<String, dynamic> json) => Goal(
        id: json['id'],
        name: json['name'],
        targetAmount: (json['targetAmount'] as num).toDouble(),
        currentAmount: (json['currentAmount'] as num).toDouble(),
        deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
        icon: json['icon'] ?? '🎯',
        createdAt: DateTime.parse(json['createdAt']),
      );
}
