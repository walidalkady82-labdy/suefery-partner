// Product model (what the partner manages)
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String id;
  final String storeId; 
  final String description;
  final String brand;
  final double price;
  bool isAvailable; // The partner controls this
  final DateTime? createdAt;

  ProductModel({
    required this.id,
    required this.storeId,
    required this.description,
    required this.brand,
    required this.price,
    this.isAvailable = true,
    this.createdAt,
  });
  factory ProductModel.fromMap(Map<String, dynamic> map) {
     DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.tryParse(timestamp); // Fallback if stored as string
      }
      return null;
    }
    return ProductModel(
      id: map['id'] as String,
      storeId: map['storeId'] as String,
      description: map['description'] as String,
      brand: map['brand'] as String,
      price: (map['price'] as num).toDouble(),
      isAvailable: map['isAvailable'] as bool,
      createdAt: parseTimestamp(map['createdAt']),
    );
  }
  
  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;

    // Helper to safely parse timestamps, as they might be null or server timestamps pending write
    DateTime? parseTimestamp(dynamic timestamp) {
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is String) {
        return DateTime.tryParse(timestamp); // Fallback if stored as string
      }
      return null;
    }

    return ProductModel(
      id: doc.id,
      storeId: data?['partnerId'] ?? '',
      description: data?['description'] ?? 'Unnamed Product',
      brand: data?['brand'] ?? 'Unknown Brand',
      // Safely handle price if it's stored as int or double
      price: (data?['price'] is int)
          ? (data?['price'] as int).toDouble()
          : (data?['price'] as double?) ?? 0.0,
      isAvailable: data?['isAvailable'] ?? false,
      createdAt: parseTimestamp(data?['createdAt']),
    );
  }
  // Helper for toggling
  ProductModel copyWith({
    String? id,
    String? storeId,
    String? description,
    String? brand,
    double? price,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      storeId: storeId ?? this.storeId,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
  Map<String, dynamic> toMap() {
        return {
      'id': id,
      'storeId': storeId,
      'description': description,
      'brand': brand,
      'price': price,
      'isAvailable': isAvailable,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }
}