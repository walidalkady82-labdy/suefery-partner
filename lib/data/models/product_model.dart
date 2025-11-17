// Product model (what the partner manages)
class ProductModel {
  final String productId;
  final String storeId; 
  final String name;
  final double price;
  bool isAvailable; // The partner controls this

  ProductModel({
    required this.productId,
    required this.storeId,
    required this.name,
    required this.price,
    this.isAvailable = true,
  });
  
  // Helper for toggling
  ProductModel copyWith({bool? isAvailable}) {
    return ProductModel(
      productId: productId,
      storeId: storeId,
      name: name,
      price: price,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}