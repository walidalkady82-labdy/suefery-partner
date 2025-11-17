import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/services/inventory_service.dart';
import 'package:suefery_partner/data/models/order_model.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/data/services/order_service.dart';
import 'package:suefery_partner/locator.dart';

import '../../data/enums/order_status.dart';
import '../../data/models/product_model.dart';
import '../../data/services/logging_service.dart';

/// --- STATE ---
class HomeState {
  final List<ProductModel> products;
  final bool isLoading;
  final List<OrderModel> orders; // <-- Uses new consolidated OrderModel
  final int selectedViewIndex;
  final String error;

  const HomeState({
    this.products = const [],
    this.isLoading = false,
    this.orders = const [],
    this.selectedViewIndex = 0,
    this.error = ''
  });

  HomeState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    List<OrderModel>? orders, // <-- Uses new consolidated OrderModel
    int? selectedViewIndex,
    String? error,
  }) {
    return HomeState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedViewIndex: selectedViewIndex ?? this.selectedViewIndex,
      error: error ?? this.error,
    );
  }
}
// --- END OF STATE ---

/// --- CUBIT ---
class HomeCubit extends Cubit<HomeState> {
  final _log = LoggerRepo('HomeCubit');

  // --- Dependencies ---
  final OrderService _orderService = sl<OrderService>();
  final AuthService _authService = sl<AuthService>();
  final InventoryService _inventoryService = sl<InventoryService>();
  // final PaymentService _paymentService; // Uncomment when ready

  StreamSubscription? _chatSubscription;

  // Use getters to access user data directly ---
  String get currentUserId => _authService.currentAppUser?.id ?? '';
  String get currentUserName => _authService.currentAppUser?.name ?? 'Customer';
  
   HomeCubit() : super(const HomeState());

  Future<void> fetchOrders() async {
    if (currentUserId.isEmpty) return;
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final orders = await _orderService.getOrders(currentUserId);
      emit(state.copyWith(orders: orders, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> updateDraftOrderWithPrices(
    String orderId, Map<String, double> itemPrices) async {
  final _log = LoggerRepo('CloudFunctions'); // Use your logger
  try {
    _log.i('Updating draft order $orderId with prices: $itemPrices');

    // 1. Get the draft order from Firestore.
    final orderDoc = await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .get();

    if (!orderDoc.exists) {
      throw Exception('Order not found: $orderId');
    }

    final orderData = orderDoc.data() as Map<String, dynamic>;
    final order = OrderModel.fromMap(orderData);

    if (order.status != OrderStatus.draft) {
      throw Exception('Order is not a draft: $orderId');
    }

    // 2. Apply price updates.
    double newTotal = 0.0;
    final updatedItems = order.items.map((item) {
      if (itemPrices.containsKey(item.name)) {
        final newPrice = itemPrices[item.name]!;
        newTotal += newPrice * item.quantity;
        return item.copyWith(unitPrice: newPrice);
      } else {
        newTotal += item.unitPrice * item.quantity;
        return item; // Price not updated
      }
    }).toList();

    // 3. Update the order with the new prices and total.
    final updatedOrder = order.copyWith(
      items: updatedItems,
      total: newTotal,
      status: OrderStatus.quoteReady, // Or a similar status
    );

    // 4. Save the updated order back to Firestore.
    await FirebaseFirestore.instance
        .collection('orders')
        .doc(orderId)
        .update(updatedOrder.toMap());

    _log.i('Successfully updated order $orderId with prices.');
  } catch (e) {
    _log.e('Error updating order $orderId: $e');
    rethrow; // Propagate the error
  }
}

  Future<void> acceptOrder(String orderId) async {
    await _orderService.updateOrderStatus(orderId, OrderStatus.preparing);
    fetchOrders(); // Refresh the list
  }
  
  Future<void> markOrderReady(String orderId) async {
    await _orderService.updateOrderStatus(orderId, OrderStatus.readyForPickup);
    fetchOrders(); // Refresh the list
  }

  Future<void> fetchInventory() async {
    if (currentUserId.isEmpty) return;
    emit(state.copyWith(isLoading: true, error: ''));
    try {
      final products = await _inventoryService.fetchInventory(currentUserId);
      emit(state.copyWith(products: products, isLoading: false));
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    await _inventoryService.updateProductAvailability(productId, isAvailable);
    fetchInventory(); // Refetch to get the updated list
  }

  Future<void> addProduct(ProductModel product) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _inventoryService.addProduct(product);
      await fetchInventory(); // Refresh the list
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    emit(state.copyWith(isLoading: true));
    try {
      await _inventoryService.updateProduct(product);
      await fetchInventory(); // Refresh the list
    } catch (e) {
      emit(state.copyWith(error: e.toString(), isLoading: false));
    }
  }

  void changeView(int index) {
    emit(state.copyWith(selectedViewIndex: index));
  }

}