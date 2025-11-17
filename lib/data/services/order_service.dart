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

  /// Updates the status of a specific order in Firestore.
  ///
  /// [orderId] The ID of the order to update.
  /// [status] The new [OrderStatus] to set.
  Future<void> updateOrderStatus(String orderId, OrderStatus status) async {
    _log.i('Updating order $orderId to status: ${status.name}');
    await _firestoreRepo.updateDocument(
        _collectionPath, orderId, {'status': status.name});
  }
}