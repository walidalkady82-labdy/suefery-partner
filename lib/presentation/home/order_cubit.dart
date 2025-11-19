import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:suefery_partner/data/services/inventory_service.dart';
import 'package:suefery_partner/data/models/order_model.dart';
import 'package:suefery_partner/data/services/auth_service.dart';
import 'package:suefery_partner/data/services/order_service.dart';
import 'package:suefery_partner/locator.dart';

import '../../data/enums/item_status.dart';
import '../../data/enums/order_status.dart';
import '../../data/enums/partner_status.dart';
import '../../data/models/product_model.dart';
import '../../data/models/quoted_item.dart';
import '../../data/services/logging_service.dart';
import '../../data/services/user_service.dart';

/// --- STATE ---
class OrderState {

  final List<OrderModel> draftOrders;
  final List<OrderModel> confirmedOrders;
  final PartnerStatus partnerStatus;
  
  final bool isLoading;
  final String error;


  const OrderState({
    this.draftOrders = const [],
    this.confirmedOrders = const [],
    this.partnerStatus = PartnerStatus.inactive,
    this.isLoading = false,
    this.error = '',
  });

  OrderState copyWith({
    List<OrderModel>? draftOrders,
    List<OrderModel>? confirmedOrders,
    PartnerStatus? partnerStatus,
    bool? isLoading,
    String? error,
  }) {
    return OrderState(
      draftOrders: draftOrders ?? this.draftOrders,
      confirmedOrders: confirmedOrders ?? this.confirmedOrders,
      partnerStatus: partnerStatus ?? this.partnerStatus,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}
// --- END OF STATE ---

/// --- CUBIT ---
class OrderCubit extends Cubit<OrderState> {
  final _log = LoggerRepo('OrderCubit');
  // --- Dependencies ---
  final OrderService _orderService = sl<OrderService>();
  final UserService _userService = sl<UserService>();
  // final PaymentService _paymentService; // Uncomment when ready

  StreamSubscription? _draftOrdersSubscription;
  StreamSubscription? _confirmedOrdersSubscription;
  StreamSubscription? _statusSubscription;

  OrderCubit() : super(const OrderState());
  
  void loadOrders(String storeId) {
    emit(state.copyWith(isLoading: true));
    
    // Listen to Draft Orders
    _draftOrdersSubscription?.cancel();
    _draftOrdersSubscription = _orderService.getPendingOrdersStream(storeId).listen((draftOrders) {
      if (!state.isLoading) {
        emit(state.copyWith(draftOrders: draftOrders));
      } else {
        emit(state.copyWith(
          draftOrders: draftOrders,
          confirmedOrders: [],
          partnerStatus: PartnerStatus.inactive, // Default
        ));
      }
    }, onError: (e) => emit(state.copyWith(error:  e.toString())));

    // Listen to Confirmed Orders
    _confirmedOrdersSubscription?.cancel();
    _confirmedOrdersSubscription = _orderService.getConfirmedOrdersStream(storeId).listen((confirmedOrders) {
      if (!state.isLoading) {
        emit(state.copyWith(confirmedOrders: confirmedOrders));
      } else {
        emit(state.copyWith(
          draftOrders: [],
          confirmedOrders: confirmedOrders,
          partnerStatus: PartnerStatus.inactive,
        ));
      }
    }, onError: (e) => emit(state.copyWith(error:  e.toString())));

    
    // Listen to Partner Status
    _statusSubscription?.cancel();
    _statusSubscription = _userService.getPartnerStatusStream(storeId).listen((partnerStatus) {
      if (!state.isLoading) {
        emit(state.copyWith(partnerStatus: partnerStatus));
      } else {
        emit(state.copyWith(
          draftOrders: [],
          confirmedOrders: [],
          partnerStatus: partnerStatus,
        ));
      }
    }, onError: (e) => emit(state.copyWith(error:  e.toString())));
  }
  // NEW: Submit Quote (S1 Logic)
  Future<void> submitQuote(String orderId, List<QuotedItem> quotedItems) async {
    try {
      // 1. Convert List<QuotedItem> to List<OrderItemModel> with updated prices
      final updatedOrderItems = quotedItems.map((quotedItem) {
        return quotedItem.item.copyWith(
          unitPrice: quotedItem.quotedPrice,
          // Mark as available if a price is entered, otherwise pending
          status: quotedItem.quotedPrice > 0 ? ItemStatus.available : ItemStatus.pending,
        );
      }).toList();

      // Calculate total based on partner's quote
      final newTotal = updatedOrderItems.fold<double>(0.0, (sum, item) => sum + (item.unitPrice * item.quantity));

      // 2. Call the service with the correctly typed list
      await _orderService.submitQuote(orderId, updatedOrderItems, newTotal);
    
      // No need to fetch, stream will update
    } catch (e) {
      emit(state.copyWith(error:e.toString()));
    }
  }
    
  Future<void> markOrderReady(String orderId) async {
     try {
      await _orderService.markOrderReady(orderId);
    } catch (e) {
      emit(state.copyWith(error:e.toString()));
    }
  }

    @override
    Future<void> close() {
      _draftOrdersSubscription?.cancel();
      _confirmedOrdersSubscription?.cancel();
      _statusSubscription?.cancel();
      return super.close();
    }

}


class QuoteState{
  final List<QuotedItem> quotedItems;
  final double totalQuote;

  const QuoteState({
    required this.quotedItems,
    required this.totalQuote,
  });

  /// Factory constructor to create the initial state from an OrderModel.
  factory QuoteState.initial(OrderModel order) {
    final initialQuotedItems = order.items
        .map((item) => QuotedItem(item: item, quotedPrice: 0.0))
        .toList();
    return QuoteState(
      quotedItems: initialQuotedItems,
      totalQuote: _calculateTotal(initialQuotedItems),
    );
  }

  QuoteState copyWith({
    List<QuotedItem>? quotedItems,
    double? totalQuote,
  }) {
    return QuoteState(
      quotedItems: quotedItems ?? this.quotedItems,
      totalQuote: totalQuote ?? this.totalQuote,
    );
  }

  /// Helper method to calculate the total quote from a list of QuotedItems.
  static double _calculateTotal(List<QuotedItem> items) {
    return items.fold(0.0, (sum, item) => sum + (item.quotedPrice * item.item.quantity));
  }

  @override
  List<Object> get props => [quotedItems, totalQuote];
}

class QuoteCubit extends Cubit<QuoteState> {
  QuoteCubit(OrderModel order) : super(QuoteState.initial(order));

  /// Updates the quoted price for a specific order item.
  void updateQuotedPrice(OrderItemModel itemToUpdate, double newPrice) {
    final updatedItems = state.quotedItems.map((quotedItem) {
      // Assuming OrderItemModel has a unique identifier like 'id'
      // If not, you might need to compare by description or another unique property
      if (quotedItem.item.id == itemToUpdate.id) {
        return quotedItem.copyWith(quotedPrice: newPrice);
      }
      return quotedItem;
    }).toList();

    emit(state.copyWith(
      quotedItems: updatedItems,
      totalQuote: QuoteState._calculateTotal(updatedItems),
    ));
  }

  /// Returns the current list of quoted items.
  List<QuotedItem> getFinalQuotedItems() {
    return state.quotedItems;
  }
}