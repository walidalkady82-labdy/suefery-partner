import 'package:cloud_firestore/cloud_firestore.dart';
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
        orderBy: [OrderBy('description')]).map((snapshot) => snapshot.docs
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

  /// NEW: "Harvesting" Logic
  /// Checks if a product exists by name/brand. 
  /// If it exists -> Update Price & set Available.
  /// If new -> Create it.
  Future<void> syncItemFromQuote({
    required String storeId,
    required String description, // Item Name
    required String brand, // If available from order
    required double price,
  }) async {
    try {
      // 1. Normalize text for searching (avoid "Pepsi" vs "pepsi" duplicates)
      final searchKey = description.trim().toLowerCase();

      // 2. Check if this item already exists in this store's inventory
      // Note: This requires a composite index on storeId + description in Firestore console
      final querySnapshot = await _firestoreRepo.getCollection(
          _collectionPath,
          where: [
            QueryCondition('storeId', isEqualTo: storeId),
            QueryCondition('description', isEqualTo: searchKey),
          ],
          limit: 1
          );
      if (querySnapshot.isNotEmpty) {
        // --- UPDATE EXISTING ---
        final docId = querySnapshot.first.id;
        await _firestoreRepo.updateDocument(_collectionPath, docId, {
          'unitPrice': price, // Update to latest quoted price
          'isAvailable': true, // Partner just quoted it, so they definitely have it
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // --- CREATE NEW ---
        final newProduct = ProductModel(
          id: '', // Firestore will gen ID
          storeId: storeId,
          description: description,
          brand: brand.isEmpty ? 'generic' : brand,
          price: price,
          isAvailable: true,
          createdAt: DateTime.now(),
        );
        
        // Add() automatically generates a document ID
        await _firestoreRepo.addDocument(_collectionPath,newProduct.toMap());
      }
    } catch (e) {
      // We generally log this but don't crash the app if inventory sync fails
      _log.e("Inventory Sync Error: $e"); 
    }
  }
}