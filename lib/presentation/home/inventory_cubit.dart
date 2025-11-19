
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/locator.dart';

import '../../data/models/product_model.dart';
import '../../data/services/inventory_service.dart';

class InventoryState {

  final List<ProductModel> products; 
  final bool isLoading;
  final String error;


  const InventoryState({
    this.products = const [],
    this.isLoading = false,
    this.error = '',
  });

  InventoryState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    String? error,
  }) {
    return InventoryState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class InventoryCubit extends Cubit<InventoryState> {
  final AuthService _authService = sl<AuthService>();
  final InventoryService _inventoryService = sl<InventoryService>();
  StreamSubscription? _productsSubscription;
  String? _currentStoreId;

  InventoryCubit() : super(InventoryState());

  void fetchInventory(String storeId) {
    _currentStoreId = storeId;
    emit(state.copyWith(isLoading: true));
    _productsSubscription?.cancel();
    _productsSubscription = _inventoryService.getProductsStream(storeId).listen(
      (products) {
        emit(state.copyWith(products: products, isLoading: false, error: ''));
      },
      onError: (e) => emit(state.copyWith(error: e.toString(), isLoading: false)),
    );
  }

  Future<void> addProduct(String description ,String brand, double price) async {
    if (_currentStoreId == null) return;
    try {

      await _inventoryService.addProduct(
        ProductModel(
          id: '', 
          storeId: _authService.currentAppUser!.storeId, 
          description: description, 
          brand: brand,
          price: price,
          isAvailable: true,
          createdAt: DateTime.now()
        )
      );
      // No need to emit, stream will update
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  Future<void> updateProduct(
    String productId, 
    String description, 
    String brand, 
    double price, 
    bool isAvailable
    ) async {
    if (_currentStoreId == null) return;
    try {

      await _inventoryService.updateProduct(ProductModel(
        id: productId, storeId: _authService.currentFirebaseUser!.uid, description: description, brand: brand, price: price
        )
      );
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }
  
  Future<void> toggleAvailability(String productId, bool isAvailable) async {
    try {
      await _inventoryService.updateProductAvailability(productId, isAvailable);
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  Future<void> deleteProduct(String productId) async {
    try {
      await _inventoryService.removeProduct(productId);
    } catch (e) {
      emit(state.copyWith(error:  e.toString()));
    }
  }

  @override
  Future<void> close() {
    _productsSubscription?.cancel();
    return super.close();
  }
}