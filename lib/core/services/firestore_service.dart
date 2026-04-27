import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../core/models/user_model.dart';
import '../../core/models/scan_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _usersCollection => _firestore.collection('users');
  CollectionReference get _scansCollection => _firestore.collection('scans');

  // ─── User Profile ───────────────────────────────────────────────────────────

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
    } catch (e) {
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
      throw 'Failed to get user profile';
    }
  }

  Future<void> updateUserProfile({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _usersCollection.doc(uid).update(data);
    } catch (e) {
      throw 'Failed to update user profile';
    }
  }

  // ─── Scan Records ────────────────────────────────────────────────────────────

  /// Saves a verified scan result from the DNA Gen API response.
  /// Returns the Firestore document ID.
  Future<String> saveScanResult(ScanModel scan) async {
    try {
      final docRef = await _scansCollection.add({
        ...scan.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
      });

      await docRef.update({'id': docRef.id});

      debugPrint('Scan saved: ${docRef.id} | authentic: ${scan.isAuthentic} | accuracy: ${scan.accuracy}');

      return docRef.id;
    } catch (e) {
      debugPrint('Failed to save scan: $e');
      throw 'Failed to save scan result: $e';
    }
  }

  Future<List<ScanModel>> getUserScans(String userId, {int limit = 20}) async {
    try {
      final snapshot = await _scansCollection
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => ScanModel.fromFirestore(
                doc.data() as Map<String, dynamic>,
                doc.id,
              ))
          .toList();
    } catch (e) {
      throw 'Failed to get scans';
    }
  }

  Stream<List<ScanModel>> watchUserScans(String userId, {int limit = 20}) {
    return _scansCollection
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ScanModel.fromFirestore(
                  doc.data() as Map<String, dynamic>,
                  doc.id,
                ))
            .toList());
  }

  Future<ScanModel?> getScanById(String scanId) async {
    try {
      final doc = await _scansCollection.doc(scanId).get();
      if (doc.exists) {
        return ScanModel.fromFirestore(
          doc.data() as Map<String, dynamic>,
          doc.id,
        );
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

  // ─── User Data Cleanup ───────────────────────────────────────────────────────

  Future<void> deleteUserData(String userId) async {
    try {
      final scans = await _scansCollection
          .where('userId', isEqualTo: userId)
          .get();

      final batch = _firestore.batch();

      for (final doc in scans.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(_usersCollection.doc(userId));

      await batch.commit();
    } catch (e) {
      throw 'Failed to delete user data';
    }
  }
}