import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class ImageHelper {
  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from gallery: $e');
      return null;
    }
  }

  static Future<File?> pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      debugPrint('Error picking image from camera: $e');
      return null;
    }
  }

  static Future<String?> saveImageLocally(String imagePath) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = path.basename(imagePath);
      final savedPath = path.join(directory.path, fileName);

      final imageFile = File(imagePath);
      await imageFile.copy(savedPath);

      return savedPath;
    } catch (e) {
      debugPrint('Error saving image locally: $e');
      return null;
    }
  }

  static Future<bool> deleteLocalImage(String imagePath) async {
    try {
      final file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error deleting image: $e');
      return false;
    }
  }

  static Future<double> getImageSize(String imagePath) async {
    try {
      final file = File(imagePath);
      final bytes = await file.length();
      return bytes / (1024 * 1024);
    } catch (e) {
      debugPrint('Error getting image size: $e');
      return 0.0;
    }
  }

  static String generateFileName({String extension = 'jpg'}) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return 'IMG_$timestamp.$extension';
  }

  static Future<bool> fileExists(String path) async {
    try {
      return await File(path).exists();
    } catch (e) {
      return false;
    }
  }
}
