import 'package:flutter/foundation.dart';
import 'package:suefery_partner/data/enums/order_status.dart';
import 'package:suefery_partner/data/models/order_model.dart';
import 'package:suefery_partner/data/services/logging_service.dart';

import '../repositories/i_repo_firestore.dart';
import 'remote_config_service.dart';

/// Service class to manage order-related Firestore operations.
class OrderService {
  final IRepoFirestore _firestoreRepo;
  final RemoteConfigService _configService;
  final LoggerRepo _log = LoggerRepo('OrderService');
  final String _collectionPath = 'orders';

  OrderService(this._firestoreRepo, this._configService);
  
  /// Fetches a list of orders for a specific partner from Firestore.
  ///
  /// [partnerId] The ID of the partner/store to fetch orders for.
  /// Returns a list of [OrderModel].
  Future<List<OrderModel>> getOrders(String partnerId) async {
    _log.i('Fetching orders for partner: $partnerId');
    try {
      final querySnapshot = await _firestoreRepo.getCollection(
        _collectionPath,
        where: [QueryCondition('partnerId', isEqualTo: partnerId)],
        orderBy: [const OrderBy('createdAt', descending: true)],
      );
      if (querySnapshot.isEmpty) {
        _log.i('No orders found for partner: $partnerId');
        return [];
      }

      final orders = querySnapshot.map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>)).toList();
      _log.i('Successfully fetched ${orders.length} orders.');
      return orders;
    } catch (e, stackTrace) {
      _log.e('Failed to fetch orders', e, stackTrace);
      // Re-throw the exception to be handled by the Cubit
      throw Exception('An error occurred while fetching orders.');
    }
  }

  /// Provides a real-time stream of pending orders for a specific partner.
  ///
  /// [partnerId] The ID of the partner/store to fetch orders for.
  /// Returns a stream of a list of [OrderModel].
  Stream<List<OrderModel>> getPendingOrdersStream(String partnerId) {
    // if(kDebugMode){
    //   return Stream.value(MockOrders.allOrders);
    // }
    _log.i('Streaming orders for partner: $partnerId');
    try {
      return _firestoreRepo
          .getCollectionStream(
        _collectionPath,
        where: [
          QueryCondition('partnerId', isEqualTo: partnerId),
          QueryCondition('status', isEqualTo: OrderStatus.draft.name)
        ],
        orderBy: [const OrderBy('createdAt', descending: true)],
      )
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
        _log.i('Stream emitted ${orders.length} orders.');
        return orders;
      });
    } catch (e, stackTrace) {
      _log.e('Failed to set up order stream', e, stackTrace);
      throw Exception('An error occurred while setting up the order stream.');
    }
  }
  
    /// Provides a real-time stream of confirmed orders for a specific partner.
  ///
  /// [partnerId] The ID of the partner/store to fetch orders for.
  /// Returns a stream of a list of [OrderModel].
  Stream<List<OrderModel>> getConfirmedOrdersStream(String partnerId) {
    // if(kDebugMode){
    //   return Stream.value(MockOrders.allOrders);
    // }
    _log.i('Streaming orders for partner: $partnerId');
    try {
      return _firestoreRepo
          .getCollectionStream(
        _collectionPath,
        where: [
          QueryCondition('partnerId', isEqualTo: partnerId),
          QueryCondition('status', isEqualTo: OrderStatus.preparing.name)
        ],
        orderBy: [const OrderBy('createdAt', descending: true)],
      )
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
        _log.i('Stream emitted ${orders.length} orders.');
        return orders;
      });
    } catch (e, stackTrace) {
      _log.e('Failed to set up order stream', e, stackTrace);
      throw Exception('An error occurred while setting up the order stream.');
    }
  }
  
    /// Provides a real-time stream of quoted orders for a specific partner.
  /// These are orders for which the partner has submitted a quote, and are
  /// now awaiting customer confirmation.
  ///
  /// [partnerId] The ID of the partner/store to fetch orders for.
  /// Returns a stream of a list of [OrderModel].
  Stream<List<OrderModel>> getQuotedOrdersStream(String partnerId) {
    // if(kDebugMode){
    //   // You might want to filter MockOrders here to only include quoted ones
    //   return Stream.value(MockOrders.allOrders.where((order) => order.status == OrderStatus.quoteReady).toList());
    // }
    _log.i('Streaming quoted orders for partner: $partnerId');
    try {
      return _firestoreRepo
          .getCollectionStream(
        _collectionPath,
        where: [
          QueryCondition('partnerId', isEqualTo: partnerId),
          QueryCondition('status', isEqualTo: OrderStatus.quoteReady.name)
        ],
        orderBy: [const OrderBy('createdAt', descending: true)],
      )
          .map((snapshot) {
        final orders = snapshot.docs.map((doc) => OrderModel.fromMap(doc.data())).toList();
        _log.i('Stream emitted ${orders.length} quoted orders.');
        return orders;
      });
    } catch (e, stackTrace) {
      _log.e('Failed to set up quoted order stream', e, stackTrace);
      throw Exception('An error occurred while setting up the quoted order stream.');
    }
  }
  
  /// Updates the status of a specific order in Firestore.
  ///
  /// [orderId] The ID of the order to update.
  /// [status] The new [OrderStatus] to set.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _log.i('Updating order $orderId to status: ${status.name}');
    await _firestoreRepo.updateDocument(
        _collectionPath, orderId, {'status': status.name});
  }

  /// Fetches a single order by its ID from Firestore.
  ///
  /// [orderId] The ID of the order to fetch.
  /// Returns an [OrderModel].
  Future<OrderModel> getOrder(String orderId) async {
    _log.i('Fetching order: $orderId');
    try {
      final doc = await _firestoreRepo.getDocumentSnapShot(_collectionPath, orderId);
      if (!doc.exists) {
        _log.w('Order not found: $orderId');
        throw Exception('Order with ID $orderId not found.');
      }
      final order = OrderModel.fromMap(doc.data() as Map<String, dynamic>);
      _log.i('Successfully fetched order: $orderId');
      return order;
    } catch (e, stackTrace) {
      _log.e('Failed to fetch order $orderId', e, stackTrace);
      throw Exception('An error occurred while fetching the order.');
    }
  }

  /// Updates an entire order document in Firestore using an [OrderModel].
  ///
  /// [order] The [OrderModel] containing the updated data.
  Future<void> updateOrder(OrderModel order) async {
    _log.i('Updating order document: ${order.id}');
    try {
      await _firestoreRepo.updateDocument(
          _collectionPath, order.id, order.toMap());
      _log.i('Successfully updated order document: ${order.id}');
    } catch (e, stackTrace) {
      _log.e('Failed to update order ${order.id}', e, stackTrace);
      throw Exception('An error occurred while updating the order.');
    }
  }

    Future<void> updateOrderMap(String id,Map<String,dynamic> orderValues) async {
    _log.i('Updating order document specified values');
    try {
      await _firestoreRepo.updateDocument(_collectionPath, id, orderValues);
      _log.i('Successfully updated order document: $id');
    } catch (e, stackTrace) {
      _log.e('Failed to update order $id', e, stackTrace);
      throw Exception('An error occurred while updating the order.');
    }
  }

  Future<void> submitQuote(String orderId, List<OrderItemModel> quotedItems, double newTotal) async {
    try {
      await _firestoreRepo.updateDocument(_collectionPath, orderId, {
        'items': quotedItems.map((item) => item.toMap()).toList(),
        'total': newTotal,
        'status': OrderStatus.quoteReady.name, // Now waits for customer
      });
    } catch (e) {
      throw Exception('Failed to submit quote: $e');
    }
  }


  // Future<void> submitQuote(String orderId, List<OrderItemModel> quotedItems, double newTotal) async {
  //   try {
  //     _log.i('Submitting quote for order $orderId');
  //     await _firestoreRepo.updateDocument(_collectionPath, orderId, 
  //     {
  //       'items': quotedItems.map((item) => item.toMap()).toList(),
  //       'total': newTotal,
  //       'status': OrderStatus.quoteReady.name, // Now waits for customer
  //     });
  //   } catch (e) {
  //     throw Exception('Failed to submit quote: $e');
  //   }
  // }
  Future<void> markOrderReady(String orderId) async {
    try {
      await updateOrderMap( orderId,  {'status': OrderStatus.readyForPickup.name,}
      );
    } catch (e) {
      throw Exception('Failed to update order status: $e');
    }
  }
}