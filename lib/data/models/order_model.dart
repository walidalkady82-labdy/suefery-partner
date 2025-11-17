import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'package:suefery_partner/data/enums/order_status.dart';

/// The main model for an order saved in the database.
/// This replaces `StructuredOrder`.
class OrderModel extends Equatable {
  final String id; 
  final String customerId; 
  final String? riderId;
  final double total;
  final OrderStatus status;
  final List<OrderItem> items;
  final DateTime createdAt;
  final DateTime? finishedAt;

  const OrderModel({
    required this.id,
    required this.customerId,
    this.riderId,
    required this.total,
    required this.status,
    required this.items,
    required this.createdAt,
    this.finishedAt,
  });

  @override
  List<Object?> get props => [id, customerId, riderId, status, items, createdAt];

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] as String,
      customerId: map['userId'] as String,
      riderId: map['riderId'] as String?,
      total: (map['estimatedTotal'] as num).toDouble(),
      status: OrderStatus.values
          .firstWhere((e) => e.name == map['status'], orElse: () => OrderStatus.draft),
      items: (map['items'] as List)
          .map((itemMap) => OrderItem.fromMap(itemMap))
          .toList(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      finishedAt: (map['finishedAt'] as Timestamp?)?.toDate(),
    );
  }

  OrderModel copyWith({
    String? id,
    String? customerId,
    String? riderId,
    double? total,
    OrderStatus? status,
    List<OrderItem>? items,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
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
      'userId': customerId,
      'riderId': riderId,
      'estimatedTotal': total,
      'status': status.name,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': Timestamp.fromDate(createdAt),
      'finishedAt': finishedAt != null ? Timestamp.fromDate(finishedAt!) : null,
    };
  }

  

}

/// An item within a confirmed [OrderModel].
class OrderItem extends Equatable {
  final String productId; // Was 'itemId'
  final String name;
  final double quantity;
  final double unitPrice;
  final String? notes;

  const OrderItem({
    required this.productId,
    required this.name,
    required this.quantity,
    required this.unitPrice,
    this.notes,
  });

  @override
  List<Object?> get props => [productId, name, quantity, unitPrice, notes];

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] as String,
      name: map['name'] as String,
      quantity: (map['quantity'] as num).toDouble(),
      unitPrice: (map['unitPrice'] as num).toDouble(),
      notes: map['notes'] as String?,
    );
  }

  OrderItem copyWith({
    String? productId,
    String? name,
    double? quantity,
    double? unitPrice,
    String? notes,
  }) {
    return OrderItem(
      productId: productId ?? this.productId,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'notes': notes,
    };
  }
}