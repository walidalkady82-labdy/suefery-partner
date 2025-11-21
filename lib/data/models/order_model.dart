import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:suefery_partner/data/enums/order_status.dart';

import '../enums/item_status.dart';

/// The main model for an order saved in the database.
/// This replaces `StructuredOrder`.
class OrderModel extends Equatable {
  final String id; 
  final String customerId; 
  final String? partnerId; 
  final String? riderId;
  final double? total;
  final OrderStatus status;
  final List<OrderItemModel> items;
  final DateTime createdAt;
  final DateTime? finishedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    this.partnerId,
    this.riderId,
    this.total,
    required this.status,
    required this.items,
    required this.createdAt,
    this.finishedAt,
  });

  @override
  List<Object?> get props => [id, customerId,partnerId, riderId, status, items, createdAt];

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    // MODIFIED: Parse the 'items' list from Firestore maps
    var itemsList = <OrderItemModel>[];
    if (data['items'] is List) {
      itemsList = (data['items'] as List)
          .map((itemMap) => OrderItemModel.fromMap(itemMap as Map<String, dynamic>))
          .toList();
    }

    return OrderModel(
      id: doc.id,
      customerId: data['customerId'] ?? 'unknown',
      partnerId: data['partnerId'] ?? 'unknown',
      riderId: data['riderId'] ?? 'unknown',
      total: data['total'] as double?, 
      items: itemsList, 
      status: OrderStatusExtension.fromString(data['status'] ?? 'draft'),
      createdAt: data['createdAt'] ?? Timestamp.now(),
      finishedAt: (data['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['customerId'] as String,
      partnerId: map['partnerId'] as String?,
      riderId: map['riderId'] as String?,
      total: map['total'] != null ? (map['total'] as num).toDouble() : 0 ,
      items: map['items'] != null ?(map['items'] as List)
          .map((itemMap) => OrderItemModel.fromMap(itemMap))
          .toList(): [],
      status: OrderStatusExtension.fromString(map['status'] ?? 'draft'),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      finishedAt: (map['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? partnerId,
    String? riderId,
    double? total,
    OrderStatus? status,
    List<OrderItemModel>? items,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      partnerId: partnerId ?? this.partnerId,
      riderId: riderId ?? this.riderId,
      total: total ?? this.total,
      status: status ?? this.status,
      items: items ?? this.items,
      createdAt: createdAt ?? this.createdAt,
      finishedAt: finishedAt ?? this.finishedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerId': customerId,
      'riderId': riderId,
      'total': total,
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
    };
  }

}

/// An item within a confirmed [OrderModel].
class OrderItemModel extends Equatable {
  final String id; // Was 'itemId'
  final String description;
  final String brand;
  final String category;
  final double quantity;
  final double unitPrice;
  final ItemStatus status;
  final String? notes;

  const OrderItemModel({
    required this.id,
    required this.description,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.unitPrice,
    this.notes,
    this.status = ItemStatus.pending,
  });

  @override
  List<Object?> get props => [id, description, brand, category,quantity, unitPrice, notes , status];

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as String,
      description: map['description'] as String,
      brand: map['brand'] as String,
      category: map['category'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
      notes: map['notes'] as String?,
      status: ItemStatusExtension.fromString(map['status'] as String? ?? 'Pending'),
    );
  }

  OrderItemModel copyWith({
    String? id,
    String? description,
    String? brand,
    String? category,
    double? quantity,
    double? unitPrice,
    String? notes,
    ItemStatus? status,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      category: category ?? this.category,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'description': description,
      'brand': brand,
      'category': category,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
      'status': status.name,
    };
  }
}