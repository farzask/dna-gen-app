import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/models/user_model.dart';
import '../../core/models/scan_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _scansCollection => _firestore.collection('scans');

  Future<void> createUserProfile({
    required String uid,
    required String name,
    required String email,
  }) async {
    try {
      final user = UserModel(
        uid: uid,
        name: name,
        email: email,
        createdAt: DateTime.now(),
      );

      await _usersCollection.doc(uid).set(user.toJson());
      print('✅ User profile created in Firestore');
    } catch (e) {
      print('❌ Failed to create user profile: $e');
      throw 'Failed to create user profile: $e';
    }
  }

  Future<UserModel?> getUserProfile(String uid) async {
    try {
      final doc = await _usersCollection.doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      throw 'Failed to get user profile';
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    Map<String, dynamic>? data,
  }) async {
    try {
      await _usersCollection.doc(uid).update(data ?? {});
    } catch (e) {
      throw 'Failed to update user profile';
    }
  }

  Future<String> createScanRecord({
    required String userId,
    required String imageUrl,
    required bool isAuthenticated,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      print('💾 Creating scan record...');
      print('   User ID: $userId');
      print('   Image URL: $imageUrl');
      print('   Is Authenticated: $isAuthenticated');

      // Create scan document
      final scanData = {
        'userId': userId,
        'imageUrl': imageUrl,
        'isAuthenticated': isAuthenticated,
        'metadata': metadata,
        'createdAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _scansCollection.add(scanData);
      print('✅ Scan created with ID: ${docRef.id}');

      // Update with ID
      await docRef.update({'id': docRef.id});

      return docRef.id;
    } catch (e) {
      print('❌ Failed to create scan record: $e');
      print('   Error type: ${e.runtimeType}');
      throw 'Failed to create scan record: ${e.toString()}';
    }
  }

  Future<List<ScanModel>> getUserScans(String userId, {int limit = 20}) async {
    try {
      final querySnapshot = await _scansCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return querySnapshot.docs
          .map((doc) => ScanModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting scans: $e');
      throw 'Failed to get scans';
    }
  }

  Stream<List<ScanModel>> getUserScansStream(String userId, {int limit = 20}) {
    return _scansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(
                (doc) => ScanModel.fromJson(doc.data() as Map<String, dynamic>),
              )
              .toList(),
        );
  }

  Future<ScanModel?> getScanById(String scanId) async {
    try {
      final doc = await _scansCollection.doc(scanId).get();
      if (doc.exists) {
        return ScanModel.fromJson(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw 'Failed to get scan';
    }
  }

  Future<void> deleteScan(String scanId) async {
    try {
      await _scansCollection.doc(scanId).delete();
    } catch (e) {
      throw 'Failed to delete scan';
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await _usersCollection.doc(userId).delete();

      final scans = await _scansCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();
      for (var doc in scans.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      throw 'Failed to delete user data';
    }
  }
}
