import 'package:suefery_partner/data/models/user_model.dart';

import '../enums/partner_status.dart';
import '../repositories/i_repo_firestore.dart'; // Assuming you have this model

class UserService {
  final IRepoFirestore _firestoreRepo;
  final String _collectionPath = 'users'; // Specific logic!

  UserService(this._firestoreRepo);

  /// Gets a stream of a single user, converting it to an [UserModel] model.
  Stream<UserModel?> getUserStream(String userId) {
    return _firestoreRepo
        .getDocumentStream(_collectionPath, userId)
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      // Business Logic: Handles data conversion
      return UserModel.fromMap(snapshot.data()!);
    });
  }

  Stream<PartnerStatus> getPartnerStatusStream(String userId) {
    return _firestoreRepo
        .getDocumentStream(_collectionPath, userId) 
        .map((snapshot) {
      if (snapshot.exists && snapshot.data() != null) {
        final data = snapshot.data()!;
        // Returns the status from Firestore, defaulting to offline if missing
        return PartnerStatusExtension.fromString(data['status'] ?? 'offline');
      }
      return PartnerStatus.inactive;
    });
  }

  /// Fetches a single user by their ID.
  Future<UserModel?> getUser(String userId) async {
    final snapshot =
        await _firestoreRepo.getDocumentSnapShot(_collectionPath, userId);
    if (!snapshot.exists || snapshot.data() == null) {
      return null;
    }
    return UserModel.fromMap(snapshot.data()!);
  }

  /// Creates a new user in the database from an [UserModel] object.
  Future<void> createUser(UserModel user) {
    // Business Logic: Ensures a new user is created with their ID
    // and handles data conversion.
    return _firestoreRepo.updateDocument(
      _collectionPath,
      user.id, // Use update/set to enforce the ID
      user.toMap(),
    );
  }

  /// Updates specific fields for a user.
  Future<void> updateUser(String userId, {String? name, String? email , String? fcmToken}) {
    final dataToUpdate = <String, dynamic>{};
    if (name != null) {
      dataToUpdate['name'] = name;
    }
    if (email != null) {
      dataToUpdate['email'] = email;
    }
     if (fcmToken != null) {
      dataToUpdate['fcmToken'] = fcmToken;
    }
    return _firestoreRepo.updateDocument(_collectionPath, userId, dataToUpdate);
  }

  /// Deletes a user.
  Future<void> deleteUser(String userId) {
    return _firestoreRepo.remove(_collectionPath, userId);
  }

}