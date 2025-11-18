import 'package:suefery_partner/data/enums/order_status.dart';
import 'package:suefery_partner/data/models/order_model.dart';

/// A collection of mock [OrderModel] instances for testing and development.
class MockOrders {
  /// A sample pending order.
  static final order1 = OrderModel(
    id: 'order-001',
    customerId: 'WCtpbkvDN3fDUPVQzRB2y1Wtm7vi',
    partnerId: 'partner-abc',
    riderId: 'rider-xyz',
    total: 160.50,
    status: OrderStatus.draft,
    createdAt: DateTime.now().subtract(const Duration(hours: 1)),
    items: const [
      OrderItem(
        productId: 'prod-01',
        name: 'Margherita Pizza',
        quantity: 2,
        unitPrice: 50.25,
      ),
      OrderItem(
        productId: 'prod-02',
        name: 'Pepsi',
        quantity: 4,
        unitPrice: 15.00,
        notes: 'Diet Pepsi if available',
      ),
    ],
  );

  /// A sample order that is in progress.
  static final order2 = OrderModel(
    id: 'order-002',
    customerId: 'customer-456',
    partnerId: 'partner-abc',
    riderId: 'rider-lmn',
    total: 75.00,
    status: OrderStatus.draft,
    createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    items: const [
      OrderItem(
        productId: 'prod-03',
        name: 'Chicken Burger',
        quantity: 3,
        unitPrice: 25.00,
      ),
    ],
  );

  /// A sample completed order.
  static final order3 = OrderModel(
    id: 'order-003',
    customerId: 'customer-789',
    partnerId: 'partner-def',
    riderId: 'rider-pqr',
    total: 210.00,
    status: OrderStatus.delivered,
    createdAt: DateTime.now().subtract(const Duration(days: 1)),
    finishedAt: DateTime.now().subtract(const Duration(hours: 23)),
    items: const [
      OrderItem(
        productId: 'prod-04',
        name: 'Family Meal',
        quantity: 1,
        unitPrice: 150.00,
      ),
      OrderItem(
        productId: 'prod-05',
        name: 'Extra Fries',
        quantity: 2,
        unitPrice: 30.00,
      ),
    ],
  );

  /// A list containing all mock orders.
  static final List<OrderModel> allOrders = [
    order1,
    order2,
    order3,
  ];
}