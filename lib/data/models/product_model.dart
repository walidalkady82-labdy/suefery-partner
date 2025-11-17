// Product model (what the partner manages)
class ProductModel {
  final String productId;
  final String partnerId; 
  final String description;
  final String brand;
  final double price;
  bool isAvailable; // The partner controls this

  ProductModel({
    required this.productId,
    required this.partnerId,
    required this.description,
    required this.brand,
    required this.price,
    this.isAvailable = true,
  });
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      productId: map['productId'] as String,
      partnerId: map['partnerId'] as String,
      description: map['description'] as String,
      brand: map['brand'] as String,
      price: (map['price'] as num).toDouble(),
      isAvailable: map['isAvailable'] as bool,
    );
  }
  // Helper for toggling
  ProductModel copyWith({
    String? productId,
    String? partnerId,
    String? description,
    String? brand,
    double? price,
    bool? isAvailable,
  }) {
    return ProductModel(
      productId: productId ?? this.productId,
      partnerId: partnerId ?? this.partnerId,
      description: description ?? this.description,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
  Map<String, dynamic> toMap() {
        return {
      'productId': productId,
      'partnerId': partnerId,
      'description': description,
      'brand': brand,
      'price': price,
      'isAvailable': isAvailable
    };
  }
}