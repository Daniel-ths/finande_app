import 'package:uuid/uuid.dart';

class Category {
  final String id;
  final String name;
  final String icon;
  final String color;
  final bool isDefault;

  Category({
    String? id,
    required this.name,
    required this.icon,
    this.color = '#4CAF50',
    this.isDefault = false,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'icon': icon,
        'color': color,
        'isDefault': isDefault,
      };

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json['id'],
        name: json['name'],
        icon: json['icon'],
        color: json['color'] ?? '#4CAF50',
        isDefault: json['isDefault'] ?? false,
      );
}
