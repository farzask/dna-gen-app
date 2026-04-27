import 'dart:io';
import 'package:cloudinary_public/cloudinary_public.dart';

class CloudinaryService {
  late CloudinaryPublic _cloudinary;

  // Initialize with your Cloudinary credentials
  CloudinaryService() {
    _cloudinary = CloudinaryPublic(
      'dzsi6mmmp',
      'dna_gen_uploads',
      cache: false,
    );
  }

  // Upload image to Cloudinary
  Future<String> uploadImage({
    required String imagePath,
    required String userId,
  }) async {
    try {
      final file = File(imagePath);

      // Generate unique public ID
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final publicId = 'dna_gen/$userId/$timestamp';

      // Upload to Cloudinary
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'dna_gen/$userId',
          publicId: publicId,
        ),
      );

      // Return secure URL
      return response.secureUrl;
    } catch (e) {
      throw 'Failed to upload image to Cloudinary: ${e.toString()}';
    }
  }

  // Upload image with transformation (resize, compress)
  Future<String> uploadImageOptimized({
    required String imagePath,
    required String userId,
  }) async {
    try {
      final file = File(imagePath);
      final timestamp = DateTime.now().millisecondsSinceEpoch;

      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          file.path,
          resourceType: CloudinaryResourceType.Image,
          folder: 'dna_gen/$userId',
          publicId: 'scan_$timestamp',
        ),
      );

      return response.secureUrl.replaceFirst(
        '/upload/',
        '/upload/q_auto,f_auto/',
      );
    } catch (e) {
      throw 'Failed to upload image: ${e.toString()}';
    }
  }

  Future<void> deleteImage(String publicId) async {
    throw UnimplementedError('File deletion requires Admin API credentials');
  }

  // Extract public ID from Cloudinary URL
  String getPublicIdFromUrl(String imageUrl) {
    final uri = Uri.parse(imageUrl);
    final pathSegments = uri.pathSegments;

    // Find 'dna_gen' folder and extract everything after
    final index = pathSegments.indexOf('dna_gen');
    if (index != -1 && index + 2 < pathSegments.length) {
      final publicIdWithExtension = pathSegments.sublist(index).join('/');
      // Remove file extension
      return publicIdWithExtension.split('.').first;
    }

    return '';
  }
}
