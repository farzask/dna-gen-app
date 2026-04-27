import 'package:cloud_firestore/cloud_firestore.dart';

class ScanModel {
  final String id;
  final String userId;
  final bool isAuthentic;
  final double accuracy;
  final double correlationStrength;
  final int matches;
  final int totalBits;
  final String imageUrl;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.userId,
    required this.isAuthentic,
    required this.accuracy,
    required this.correlationStrength,
    required this.matches,
    required this.totalBits,
    required this.imageUrl,
    required this.createdAt,
  });

  factory ScanModel.fromVerifyResponse({
    required String id,
    required String userId,
    required String imageUrl,
    required Map<String, dynamic> json,
  }) {
    return ScanModel(
      id: id,
      userId: userId,
      isAuthentic: json['is_authentic'] as bool,
      accuracy: (json['accuracy'] as num).toDouble(),
      correlationStrength: (json['correlation_strength'] as num).toDouble(),
      matches: json['matches'] as int,
      totalBits: json['total_bits'] as int,
      imageUrl: imageUrl,
      createdAt: DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'isAuthentic': isAuthentic,
      'accuracy': accuracy,
      'correlationStrength': correlationStrength,
      'matches': matches,
      'totalBits': totalBits,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ScanModel.fromFirestore(Map<String, dynamic> json, String id) {
    return ScanModel(
      id: id,
      userId: json['userId'] as String,
      isAuthentic: json['isAuthentic'] as bool,
      accuracy: (json['accuracy'] as num).toDouble(),
      correlationStrength: (json['correlationStrength'] as num).toDouble(),
      matches: json['matches'] as int,
      totalBits: json['totalBits'] as int,
      imageUrl: json['imageUrl'] as String,
      createdAt: json['createdAt'] is Timestamp
          ? (json['createdAt'] as Timestamp).toDate()
          : json['createdAt'] is String
              ? DateTime.parse(json['createdAt'] as String)
              : DateTime.now(),
    );
  }
}