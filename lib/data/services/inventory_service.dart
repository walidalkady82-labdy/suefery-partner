import 'package:suefery_partner/data/models/product_model.dart';
import 'package:suefery_partner/data/repositories/i_repo_firestore.dart';
import 'package:suefery_partner/data/services/logging_service.dart';

/// Service class to manage inventory (product) related Firestore operations.
class InventoryService {
  final IRepoFirestore _firestoreRepo;
  final LoggerRepo _log = LoggerRepo('InventoryService');
  final String _collectionPath = 'products';

  InventoryService(this._firestoreRepo);

  /// Fetches the live list of products for a specific store
  Stream<List<ProductModel>> getProductsStream(String storeId) {
    return  _firestoreRepo.getCollectionStream( _collectionPath,
        where: [QueryCondition('storeId', isEqualTo: storeId)],
        orderBy: [OrderBy('name')]).map((snapshot) => snapshot.docs
            .map((doc) => ProductModel.fromMap(doc.data()))
            .toList());
  }

  /// Fetches the inventory (list of products) for a specific partner.
  Future<List<ProductModel>> fetchInventory(String partnerId) async {
    _log.i('Fetching inventory for partner: $partnerId');
    try {
      final snapshot = await _firestoreRepo.getCollection(
        _collectionPath,
        where: [QueryCondition('partnerId', isEqualTo: partnerId)],
      );
      final products = snapshot
          .map((doc) => ProductModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList();
      _log.i('Successfully fetched ${products.length} products.');
      return products;
    } catch (e, stackTrace) {
      _log.e('Failed to fetch inventory', e, stackTrace);
      throw Exception('An error occurred while fetching your inventory.');
    }
  }

  /// Adds a new product to the inventory.
  Future<void> addProduct(ProductModel product) async {
    _log.i('Adding new product: ${product.description}');
    await _firestoreRepo.addDocument(_collectionPath, product.toMap());
  }

  /// Updates an entire product document in the inventory.
  Future<void> updateProduct(ProductModel product) async {
    _log.i('Updating product: ${product.id}');
    await _firestoreRepo.updateDocument(_collectionPath, product.id, product.toMap());
  }

  /// Removes a product from the inventory using its ID.
  Future<void> removeProduct(String productId) async {
    _log.i('Removing product: $productId');
    await _firestoreRepo.remove(_collectionPath, productId);
  }

  /// Updates a product's availability.
  Future<void> updateProductAvailability(String productId, bool isAvailable) async {
    _log.i('Updating availability for $productId to $isAvailable');
    await _firestoreRepo.updateDocument(
        _collectionPath, productId, {'isAvailable': isAvailable});
  }

  /// Updates a list of products in a single batch operation.
  /// This is highly efficient for updating multiple items at once.
  Future<void> batchUpdateInventory(List<ProductModel> productsToUpdate) async {
    _log.i('Starting batch update for ${productsToUpdate.length} products.');
    try {
      // This assumes your IRepoFirestore has a batchWrite method.
      // If not, you would implement it in FirestoreRepo using `_firestore.batch()`.
      // await _firestoreRepo.batchWrite((batch) {
      //   for (var product in productsToUpdate) {
      //     final docRef = _firestoreRepo.doc(_collectionPath, product.productId);
      //     batch.update(docRef, product.toMap());
      //   }
      // });
    } catch (e, stackTrace) {
      _log.e('Batch update failed', e, stackTrace);
      throw Exception('An error occurred during the bulk update.');
    }
  }
}