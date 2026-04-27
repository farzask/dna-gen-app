import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image
  Future<String> uploadImage({
    required String path,
    required String userId,
    required String fileName,
  }) async {
    try {
      final file = File(path);
      final ref = _storage.ref().child('scans/$userId/$fileName');

      final uploadTask = ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw 'Failed to upload image: ${e.toString()}';
    }
  }

  // Delete image
  Future<void> deleteImage(String imageUrl) async {
    try {
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      throw 'Failed to delete image: ${e.toString()}';
    }
  }

  // Delete user images
  Future<void> deleteUserImages(String userId) async {
    try {
      final ref = _storage.ref().child('scans/$userId');
      final listResult = await ref.listAll();

      for (var item in listResult.items) {
        await item.delete();
      }
    } catch (e) {
      throw 'Failed to delete user images: ${e.toString()}';
    }
  }
}
