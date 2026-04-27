import 'package:cloud_firestore/cloud_firestore.dart';

class ScanModel {
  final String id;
  final String userId;
  final String imageUrl;
  final bool isAuthenticated;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;

  ScanModel({
    required this.id,
    required this.userId,
    required this.imageUrl,
    required this.isAuthenticated,
    this.metadata,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'imageUrl': imageUrl,
      'isAuthenticated': isAuthenticated,
      'metadata': metadata,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    // Handle both Timestamp and null for createdAt
    DateTime createdAt;
    try {
      if (json['createdAt'] is Timestamp) {
        createdAt = (json['createdAt'] as Timestamp).toDate();
      } else if (json['createdAt'] is String) {
        createdAt = DateTime.parse(json['createdAt']);
      } else {
        createdAt = DateTime.now();
      }
    } catch (e) {
      createdAt = DateTime.now();
    }

    return ScanModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String,
      imageUrl: json['imageUrl'] as String,
      isAuthenticated: json['isAuthenticated'] as bool,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: createdAt,
    );
  }

  ScanModel copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    bool? isAuthenticated,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return ScanModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      imageUrl: imageUrl ?? this.imageUrl,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'ScanModel(id: $id, userId: $userId, imageUrl: $imageUrl, isAuthenticated: $isAuthenticated, metadata: $metadata, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is ScanModel &&
        other.id == id &&
        other.userId == userId &&
        other.imageUrl == imageUrl &&
        other.isAuthenticated == isAuthenticated &&
        other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        userId.hashCode ^
        imageUrl.hashCode ^
        isAuthenticated.hashCode ^
        createdAt.hashCode;
  }
}
