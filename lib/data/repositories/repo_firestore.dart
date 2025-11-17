import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:suefery_partner/core/extensions/future_extension.dart';
import 'package:suefery_partner/data/enums/query_operator.dart';


import 'i_repo_firestore.dart';
import 'repo_log.dart'; 
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kDebugMode, kIsWeb, TargetPlatform;

// Import your enum
// import 'package:suefery/data/enums/query_operator.dart'; 

class RepoFirestore implements IRepoFirestore {
  final _log = RepoLog('FirestoreRepository');
  final FirebaseFirestore _firestore;
  
  /// The [FirebaseFirestore] instance is injected.
  /// This allows for easy testing and emulator configuration.
  RepoFirestore._({required FirebaseFirestore firestore})  : _firestore = firestore;
  /// Creates and initializes a new [RepoFirestore] instance.
  ///
  /// If [useEmulator] is true, it will connect to the local
  /// Firebase Auth emulator on localhost:9099.
  ///
  /// Note: Emulators should only be used in debug builds.
  factory RepoFirestore.create({bool useEmulator = false}) {
    final instance = FirebaseFirestore.instance;
    final log = RepoLog('AuthRepo');
    // Check for a Dart-defined environment variable to decide on using the emulator.

    // Use emulator only in debug mode and if requested
    if (kDebugMode && useEmulator) {
      try {
        log.i('Connecting to Firebase FirebaseFirestore Emulator...');
        final emulatorHost =(!kIsWeb && defaultTargetPlatform == TargetPlatform.android)?  dotenv.get('local_device_ip'): 'localhost';
        instance.useFirestoreEmulator(emulatorHost, 8080);
        log.i('Connected to FirebaseFirestore Emulator on localhost:8080');
      } catch (e) {
        log.e('*** FAILED TO CONNECT TO FirebaseFirestore EMULATOR: $e ***');
        log.e(
            '*** Make sure the emulator is running: firebase emulators:start ***');
      }
    }
        // Enable offline persistence for better performance, especially on mobile
    if (!kIsWeb) {
      instance.settings = const Settings(persistenceEnabled: true);
    }
    return RepoFirestore._(
      firestore: instance,
    );
  }

  @override
  String generateId(String path) {
    final ref = _firestore.collection(path).doc();
    return ref.id;
  }

  @override
  Future<List<DocumentSnapshot>> getCollection(
    String collectionPath, {
    List<QueryCondition>? where,
    List<OrderBy>? orderBy,
    int? limit,
  }) async {
    Query query = _firestore.collection(collectionPath);

    // Apply where clauses
    if (where != null) {
      for (var condition in where) {
        if (condition.isEqualTo != null) {
          query = query.where(condition.field, isEqualTo: condition.isEqualTo);
        } else if (condition.isLessThan != null) {
          query = query.where(condition.field, isLessThan: condition.isLessThan);
        } else if (condition.isLessThanOrEqualTo != null) {
          query = query.where(condition.field, isLessThanOrEqualTo: condition.isLessThanOrEqualTo);
        } else if (condition.isGreaterThan != null) {
          query = query.where(condition.field, isGreaterThan: condition.isGreaterThan);
        } else if (condition.isGreaterThanOrEqualTo != null) {
          query = query.where(condition.field, isGreaterThanOrEqualTo: condition.isGreaterThanOrEqualTo);
        } else if (condition.arrayContains != null) {
          query = query.where(condition.field, arrayContains: condition.arrayContains);
        } else if (condition.arrayContainsAny != null) {
          query = query.where(condition.field, arrayContainsAny: condition.arrayContainsAny);
        } else if (condition.whereIn != null) {
          query = query.where(condition.field, whereIn: condition.whereIn);
        } else if (condition.isNull != null) {
          query = query.where(condition.field, isNull: condition.isNull);
        }
      }
    }

    // Apply orderBy clauses
    if (orderBy != null) {
      for (var order in orderBy) {
        query = query.orderBy(order.field, descending: order.descending);
      }
    }

    // Apply limit clause
    if (limit != null) {
      query = query.limit(limit);
    }

    final querySnapshot = await query.get();
    return querySnapshot.docs;
  }
  
  @override
  Stream<QuerySnapshot<Map<String, dynamic>>> getCollectionStream(
    String collectionPath, {
    String? orderBy,
    bool isDescending = false,
  }) {
    // Start with the basic query
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    // Add sorting if provided
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: isDescending);
    }

    // Return the stream of snapshots
    return query.snapshots();
  }

  @override
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocumentSnapShot(
      String collectionPath, String docId) async {
    return await _firestore.collection(collectionPath).doc(docId).get();
  }

  @override
  Stream<DocumentSnapshot<Map<String, dynamic>>> getDocumentStream(
      String collectionPath, String docId) {
    return _firestore.collection(collectionPath).doc(docId).snapshots();
  }

  @override
  Future<void> addDocument(String collectionPath, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).add(data);
  }
  @override
  Future<void> updateDocument(
      String collectionPath, String documentId, Map<String, dynamic> data) async {
    await _firestore.collection(collectionPath).doc(documentId).update(data);
  }
  
  @override
  Future<void> remove(String path, String id) async {
    try {
      await _firestore.collection(path).doc(id).delete().withDefaultTimeout();
    } catch (e) {
      _log.e("Error removing document in $path with ID $id: $e");
      rethrow;
    }
  }

}