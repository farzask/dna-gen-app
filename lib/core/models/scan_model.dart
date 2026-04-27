import 'package:cloud_firestore/cloud_firestore.dart';

// class ScanModel {
//   final String id;
//   final String userId;
//   final String imageUrl;
//   final bool isAuthenticated;
//   final Map<String, dynamic>? metadata;
//   final DateTime createdAt;

//   ScanModel({
//     required this.id,
//     required this.userId,
//     required this.imageUrl,
//     required this.isAuthenticated,
//     this.metadata,
//     required this.createdAt,
//   });

//   Map<String, dynamic> toJson() {
//     return {
//       'id': id,
//       'userId': userId,
//       'imageUrl': imageUrl,
//       'isAuthenticated': isAuthenticated,
//       'metadata': metadata,
//       'createdAt': Timestamp.fromDate(createdAt),
//     };
//   }

//   factory ScanModel.fromJson(Map<String, dynamic> json) {
//     // Handle both Timestamp and null for createdAt
//     DateTime createdAt;
//     try {
//       if (json['createdAt'] is Timestamp) {
//         createdAt = (json['createdAt'] as Timestamp).toDate();
//       } else if (json['createdAt'] is String) {
//         createdAt = DateTime.parse(json['createdAt']);
//       } else {
//         createdAt = DateTime.now();
//       }
//     } catch (e) {
//       createdAt = DateTime.now();
//     }

//     return ScanModel(
//       id: json['id'] as String? ?? '',
//       userId: json['userId'] as String,
//       imageUrl: json['imageUrl'] as String,
//       isAuthenticated: json['isAuthenticated'] as bool,
//       metadata: json['metadata'] as Map<String, dynamic>?,
//       createdAt: createdAt,
//     );
//   }

//   ScanModel copyWith({
//     String? id,
//     String? userId,
//     String? imageUrl,
//     bool? isAuthenticated,
//     Map<String, dynamic>? metadata,
//     DateTime? createdAt,
//   }) {
//     return ScanModel(
//       id: id ?? this.id,
//       userId: userId ?? this.userId,
//       imageUrl: imageUrl ?? this.imageUrl,
//       isAuthenticated: isAuthenticated ?? this.isAuthenticated,
//       metadata: metadata ?? this.metadata,
//       createdAt: createdAt ?? this.createdAt,
//     );
//   }

//   @override
//   String toString() {
//     return 'ScanModel(id: $id, userId: $userId, imageUrl: $imageUrl, isAuthenticated: $isAuthenticated, metadata: $metadata, createdAt: $createdAt)';
//   }

//   @override
//   bool operator ==(Object other) {
//     if (identical(this, other)) return true;

//     return other is ScanModel &&
//         other.id == id &&
//         other.userId == userId &&
//         other.imageUrl == imageUrl &&
//         other.isAuthenticated == isAuthenticated &&
//         other.createdAt == createdAt;
//   }

//   @override
//   int get hashCode {
//     return id.hashCode ^
//         userId.hashCode ^
//         imageUrl.hashCode ^
//         isAuthenticated.hashCode ^
//         createdAt.hashCode;
//   }
// }

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