// Product model (what the partner manages)
class ProductModel {
  final String productId;
  final String partnerId; 
  final String description;
  final double price;
  bool isAvailable; // The partner controls this

  ProductModel({
    required this.productId,
    required this.partnerId,
    required this.description,
    required this.price,
    this.isAvailable = true,
  });
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] as String,
      partnerId: map['partnerId'] as String,
      description: map['name'] as String,
      price: (map['price'] as num).toDouble(),
      isAvailable: map['isAvailable'] as bool,
    );
  }
  // Helper for toggling
  ProductModel copyWith({
    String? productId,
    String? partnerId,
    String? description,
    double? price,
    bool? isAvailable,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      partnerId: partnerId ?? this.partnerId,
      description: description ?? this.description,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
  Map<String, dynamic> toMap() {
        return {
      'productId': productId,
      'partnerId': partnerId,
      'name': description,
      'price': price,
      'isAvailable': isAvailable
    };
  }
}