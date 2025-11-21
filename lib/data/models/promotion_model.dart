import 'package:cloud_firestore/cloud_firestore.dart';

import '../enums/promotion_type.dart';


class Promotion {
  final String id;
  final String storeId;
  final String title;
  final String description;
  final PromotionType type;
  final double value;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  Promotion({
    required this.id,
    required this.storeId,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  factory Promotion.fromMap(Map<String, dynamic> map) {
    return Promotion(
      id: map['id'] as String,
      storeId: map['storeId'] as String,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      type: (map['type'] == 'percentage') ? PromotionType.percentage : PromotionType.fixedAmount,
      value: (map['value'] as num?)?.toDouble() ?? 0.0,
      startDate: (map['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate: (map['endDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id,
      'title': title,
      'storeId' : storeId,
      'description': description,
      'type': type == PromotionType.percentage ? 'percentage' : 'fixedAmount',
      'value': value,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'isActive': isActive,
    };
  }

  String get typeAsString {
    return type == PromotionType.percentage ? 'Percentage' : 'Fixed Amount';
  }

  String get valueAsString {
    if (type == PromotionType.percentage) {
      return '${value.toStringAsFixed(0)}%';
    }
    // Assuming a currency format. You can adapt this.
    return '\$${value.toStringAsFixed(2)}';
  }
}