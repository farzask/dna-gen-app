class AuthenticationResult {
  final bool isAuthenticated;
  final double? confidenceScore;
  final String? message;
  final String? scanId;

  AuthenticationResult({
    required this.isAuthenticated,
    this.confidenceScore,
    this.message,
    this.scanId,
  });

  // Convert AuthenticationResult to JSON
  Map<String, dynamic> toJson() {
    return {
      'isAuthenticated': isAuthenticated,
      'confidenceScore': confidenceScore,
      'message': message,
      'scanId': scanId,
    };
  }

  // Create AuthenticationResult from JSON
  factory AuthenticationResult.fromJson(Map<String, dynamic> json) {
    return AuthenticationResult(
      isAuthenticated: json['isAuthenticated'] ?? false,
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble(),
      message: json['message'] as String?,
      scanId: json['scanId'] as String?,
    );
  }

  // Copy with method
  AuthenticationResult copyWith({
    bool? isAuthenticated,
    double? confidenceScore,
    String? message,
    String? scanId,
  }) {
    return AuthenticationResult(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      message: message ?? this.message,
      scanId: scanId ?? this.scanId,
    );
  }

  @override
  String toString() {
    return 'AuthenticationResult(isAuthenticated: $isAuthenticated, confidenceScore: $confidenceScore, message: $message, scanId: $scanId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AuthenticationResult &&
        other.isAuthenticated == isAuthenticated &&
        other.confidenceScore == confidenceScore &&
        other.message == message &&
        other.scanId == scanId;
  }

  @override
  int get hashCode {
    return isAuthenticated.hashCode ^
        confidenceScore.hashCode ^
        message.hashCode ^
        scanId.hashCode;
  }
}
