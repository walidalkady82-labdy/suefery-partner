import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a condition for filtering documents in a Firestore query.
class QueryCondition {
  final String field;
  final dynamic isEqualTo;
  final dynamic isLessThan;
  final dynamic isLessThanOrEqualTo;
  final dynamic isGreaterThan;
  final dynamic isGreaterThanOrEqualTo;
  final dynamic arrayContains;
  final List<dynamic>? arrayContainsAny;
  final List<dynamic>? whereIn;
  final bool? isNull;

  const QueryCondition(
    this.field, {
    this.isEqualTo,
    this.isLessThan,
    this.isLessThanOrEqualTo,
    this.isGreaterThan,
    this.isGreaterThanOrEqualTo,
    this.arrayContains,
    this.arrayContainsAny,
    this.whereIn,
    this.isNull,
  });
}

/// Represents an ordering clause for documents in a Firestore query.
class OrderBy {
  final String field;
  final bool descending;

  const OrderBy(this.field, {this.descending = false});
}

/// An abstract interface for interacting with Firestore.
/// This allows for easy mocking and swapping of Firestore implementations.
abstract class IRepoFirestore {
  /// Fetches a collection of documents from Firestore.
  ///
  /// [collectionPath] The path to the collection.
  /// [where] Optional list of [QueryCondition] to filter documents.
  /// [orderBy] Optional list of [OrderBy] to sort documents.
  /// Returns a list of [DocumentSnapshot] representing the documents.
  Future<List<DocumentSnapshot>> getCollection(
    String collectionPath, {
    List<QueryCondition>? where,
    List<OrderBy>? orderBy,
    int? limit,
  });

  /// Updates a specific document in a collection.
  Future<void> updateDocument(
      String collectionPath, String documentId, Map<String, dynamic> data);

  Future<void> remove(String path, String id);

  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream(
      String collectionPath, String docId);

  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentSnapShot(
      String collectionPath, String docId);
  
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) ;

  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
    String collectionPath, {
    String? orderBy,
    bool isDescending = false,
  });

  String generateId(String path) ;

}

