import '../enums/order_status.dart';
import '../models/analytics_model.dart';
import '../models/order_model.dart';
import '../repositories/i_repo_firestore.dart';

class AnalyticsService {
  final IRepoFirestore _firestoreRepo; 

  AnalyticsService(this._firestoreRepo);

  /// Fetches orders for the last 30 days and calculates metrics locally.
  /// (In a production app at scale, this aggregation should happen on the backend).
  Future<AnalyticsModel> getMonthlyAnalytics(String storeId) async {
    try {
      final now = DateTime.now();
      final startOfMonth = DateTime(now.year, now.month, 1);

      // Fetch all orders for this store created this month
      final snapshot = await _firestoreRepo.getCollection(
            'orders', 
            where: [
              QueryCondition('storeId', isEqualTo: storeId),
              QueryCondition('createdAt', isGreaterThanOrEqualTo: startOfMonth.millisecondsSinceEpoch),
            ]);

      final orders = snapshot.map((doc) => OrderModel.fromFirestore(doc)).toList();

      return _calculateMetrics(orders);
    } catch (e) {
      throw Exception("Failed to calculate analytics: $e");
    }
  }

  AnalyticsModel _calculateMetrics(List<OrderModel> orders) {
    if (orders.isEmpty) return AnalyticsModel.empty();

    double revenue = 0.0;
    int completedCount = 0;
    int cancelledCount = 0;
    final Map<String, double> itemFrequency = {};
    final Map<String, double> itemRevenue = {};

    for (var order in orders) {
      // 1. Revenue & Counts
      if (order.status == OrderStatus.delivered || order.status == OrderStatus.readyForPickup) {
        revenue += (order.total ?? 0.0);
        completedCount++;

        // 2. Top Items Calculation
        for (var item in order.items) {
          itemFrequency[item.description] = (itemFrequency[item.description] ?? 0) + item.quantity;
          
          // Approx item revenue based on unit price if available
          final unitPrice = item.unitPrice;
          itemRevenue[item.description] = (itemRevenue[item.description] ?? 0) + (unitPrice * item.quantity);
        }
      } else if (order.status == OrderStatus.cancelled) {
        cancelledCount++;
      }
    }

    // 3. Fulfillment Rate
    final totalRelevant = completedCount + cancelledCount;
    final double rate = totalRelevant == 0 ? 1.0 : (completedCount / totalRelevant);

    // 4. Partner Score (Simple weighted algorithm)
    // Base 100, deduct for cancellations.
    int score = (rate * 100).round();
    
    // 5. Sort Top Items
    final sortedKeys = itemFrequency.keys.toList()
      ..sort((a, b) => itemFrequency[b]!.compareTo(itemFrequency[a]!));
    
    final topItems = sortedKeys.take(5).map((key) {
      return TopItem(
        name: key,
        count: itemFrequency[key]!,
        revenue: itemRevenue[key] ?? 0.0,
      );
    }).toList();

    return AnalyticsModel(
      totalRevenue: revenue,
      totalOrders: orders.length,
      fulfillmentRate: rate,
      averageOrderValue: completedCount == 0 ? 0 : revenue / completedCount,
      topItems: topItems,
      partnerScore: score,
    );
  }
}