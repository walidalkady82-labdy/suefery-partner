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
      OrderItemModel(
        id: 'prod-01',
        description: 'Margherita Pizza',
        quantity: 2,
        unitPrice: 50.25, brand: '', category: '',
      ),
      OrderItemModel(
        id: 'prod-02',
        description: 'Pepsi',
        quantity: 4,
        unitPrice: 15.00,
        notes: 'Diet Pepsi if available', brand: '', category: '',
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
      OrderItemModel(
        id: 'prod-03',
        description: 'Chicken Burger',
        quantity: 3,
        unitPrice: 25.00, brand: '', category: '',
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
      OrderItemModel(
        id: 'prod-04',
        description: 'Family Meal',
        quantity: 1,
        unitPrice: 150.00, brand: '', category: '',
      ),
      OrderItemModel(
        id: 'prod-05',
        description: 'Extra Fries',
        quantity: 2,
        unitPrice: 30.00, brand: '', category: '',
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