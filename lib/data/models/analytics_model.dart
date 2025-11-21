class AnalyticsModel {
  final double totalRevenue;
  final int totalOrders;
  final double fulfillmentRate; // 0.0 to 1.0
  final double averageOrderValue;
  final List<TopItem> topItems;
  final int partnerScore; // 0 to 100

  AnalyticsModel({
    required this.totalRevenue,
    required this.totalOrders,
    required this.fulfillmentRate,
    required this.averageOrderValue,
    required this.topItems,
    required this.partnerScore,
  });

  // Empty state
  factory AnalyticsModel.empty() {
    return AnalyticsModel(
      totalRevenue: 0,
      totalOrders: 0,
      fulfillmentRate: 0,
      averageOrderValue: 0,
      topItems: [],
      partnerScore: 100, // Innocent until proven guilty
    );
  }
}

class TopItem {
  final String name;
  final double count;
  final double revenue;

  TopItem({required this.name, required this.count, required this.revenue});
}