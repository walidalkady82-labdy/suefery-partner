enum OrderStatus { 
  draft,  // New S1 (AI) order, needs partner quote
  awaitingQuote, // Partner submitted quote, waiting for customer approval
  quoteReady,
  confirmed,
  preparing, // Customer confirmed quote, partner must pack
  readyForPickup, // Partner packed, awaiting rider
  assigned, 
  outForDelivery,
  delivered, // Rider delivered
  cancelled  // Order cancelled by any party
  }

extension OrderStatusExtension on OrderStatus {
  String get name => toString().split('.').last;

  static OrderStatus fromString(String status) {
    return OrderStatus.values.firstWhere(
      (e) => e.name == status,
      orElse: () => OrderStatus.cancelled,
    );
  }
}

