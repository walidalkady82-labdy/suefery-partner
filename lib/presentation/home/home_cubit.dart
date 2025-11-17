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
  final String searchQuery;

  List<ProductModel> get filteredProducts {
    if (searchQuery.isEmpty) {
      return products;
    }
    return products
        .where((product) =>
            product.description.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();
  }

  const HomeState({
    this.products = const [],
    this.isLoading = false,
    this.orders = const [],
    this.selectedViewIndex = 0,
    this.error = '',
    this.searchQuery = '',
  });

  HomeState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    List<OrderModel>? orders, // <-- Uses new consolidated OrderModel
    int? selectedViewIndex,
    String? error,
    String? searchQuery,
  }) {
    return HomeState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      orders: orders ?? this.orders,
      selectedViewIndex: selectedViewIndex ?? this.selectedViewIndex,
      error: error ?? this.error,
      searchQuery: searchQuery ?? this.searchQuery,
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
  StreamSubscription? _ordersSubscription;

  // Use getters to access user data directly ---
  String get currentUserId => _authService.currentAppUser?.id ?? '';
  String get currentUserName => _authService.currentAppUser?.name ?? 'Customer';
  
   HomeCubit() : super(const HomeState()) {
    _initialize();
  }

  void _initialize() {
    _listenToOrders();
    fetchInventory();
  }

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

  void _listenToOrders() {
    if (currentUserId.isEmpty) return;
    emit(state.copyWith(isLoading: true, error: ''));
    _ordersSubscription?.cancel();
    _ordersSubscription = _orderService.getOrdersStream(currentUserId).listen(
      (orders) {
        emit(state.copyWith(orders: orders, isLoading: false));
      },
      onError: (e) {
        emit(state.copyWith(error: e.toString(), isLoading: false));
      },
    );
  }
  Future<void> updateDraftOrderWithPrices(
    String orderId, Map<String, double> itemPrices) async {
  final _log = LoggerRepo('CloudFunctions'); // Use your logger
  // Delegate the entire operation to the OrderService
  await _orderService.updateDraftOrderPrices(orderId, itemPrices);
}
  Future<void> acceptOrder(String orderId) async {
    await _orderService.updateOrderStatus(orderId, OrderStatus.preparing);
  }
  
  Future<void> markOrderReady(String orderId) async {
    await _orderService.updateOrderStatus(orderId, OrderStatus.readyForPickup);
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

  void searchInventory(String query) {
    emit(state.copyWith(searchQuery: query));
  }

  @override
  Future<void> close() {
    _ordersSubscription?.cancel();
    return super.close();
  }

}