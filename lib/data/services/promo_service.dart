import 'package:suefery_partner/data/models/promotion_model.dart';

import '../repositories/i_repo_firestore.dart';
import 'logging_service.dart';

class PromoService  {
  final IRepoFirestore _firestoreRepo;
  final LoggerRepo _log = LoggerRepo('PromoService');
  PromoService(this._firestoreRepo);
  final String _collectionPath = 'promotions';

  // Stream<List<Promotion>> getPromotionsStream(String storeId) {
  //   return _firestore
  //       .collection(_usersCollection)
  //       .doc(storeId)
  //       .collection(_promotionsSubCollection)
  //       .orderBy('endDate', descending: true)
  //       .snapshots()
  //       .map((snapshot) {
  //     return snapshot.docs.map((doc) {
  //       return Promotion.fromMap(doc.data(), doc.id);
  //     }).toList();
  //   });
  // }

  // Future<void> addPromotion(String storeId, Map<String, dynamic> promotionData) async {
  //   await _firestore
  //       .collection(_usersCollection)
  //       .doc(storeId)
  //       .collection(_promotionsSubCollection)
  //       .add(promotionData);
  // }

  /// Fetches the live list of Promotion for a specific partner
  Stream<List<Promotion>> getPromoStream(String storeId) {
    return  _firestoreRepo.getCollectionStream( _collectionPath,
        where: [QueryCondition('storeId', isEqualTo: storeId)],
        orderBy: [OrderBy('endDate')]).map((snapshot) => snapshot.docs
            .map((doc) => Promotion.fromMap(doc.data()))
            .toList());
  }

  /// Fetches the promotion (list of promotions) for a specific partner.
  Future<List<Promotion>> fetchPromos(String partnerId) async {
    _log.i('Fetching promotion for partner: $partnerId');
    try {
      final snapshot = await _firestoreRepo.getCollection(
        _collectionPath,
        where: [QueryCondition('partnerId', isEqualTo: partnerId)],
      );
      final products = snapshot
          .map((doc) => Promotion.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _log.i('Successfully fetched ${products.length} promotion.');
      return products;
    } catch (e, stackTrace) {
      _log.e('Failed to fetch promotion', e, stackTrace);
      throw Exception('An error occurred while fetching your promotion.');
    }
  }

  /// Adds a new product to the inventory.
  Future<void> addPromo(Promotion promo) async {
    _log.i('Adding new promo: ${promo.description}');
    await _firestoreRepo.addDocument(_collectionPath, promo.toMap());
  }

  /// Updates an entire product document in the inventory.
  Future<void> updatePromo(Promotion promo) async {
    _log.i('Updating promo: ${promo.id}');
    await _firestoreRepo.updateDocument(_collectionPath, promo.id, promo.toMap());
  }

  /// Removes a product from the inventory using its ID.
  Future<void> removePromo(String promoId) async {
    _log.i('Removing promo: $promoId');
    await _firestoreRepo.remove(_collectionPath, promoId);
  }

    /// Updates a product's availability.
  Future<void> updatePromoAvailability(String promoId, bool isAvailable) async {
    _log.i('Updating availability for $promoId to $isAvailable');
    await _firestoreRepo.updateDocument(
        _collectionPath, promoId, {'isAvailable': isAvailable});
  }

}