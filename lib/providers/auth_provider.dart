import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/services/auth_service.dart';
import '../core/services/firestore_service.dart';
import '../core/models/user_model.dart';
import '../core/models/app_state.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuthService _authService = FirebaseAuthService();
  final FirestoreService _firestoreService = FirestoreService();

  AppState _state = AppState.idle;
  String? _errorMessage;
  UserModel? _currentUser;

  AppState get state => _state;
  String? get errorMessage => _errorMessage;
  UserModel? get currentUser => _currentUser;
  bool get isAuthenticated => _authService.currentUser != null;
  User? get firebaseUser => _authService.currentUser;

  void _setState(AppState newState) {
    _state = newState;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    _setState(AppState.error);
  }

  void clearError() {
    _errorMessage = null;
    _setState(AppState.idle);
  }

  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      _setState(AppState.loading);

      final user = await _authService.signUpWithEmail(
        email: email,
        password: password,
        name: name,
      );

      if (user != null) {
        try {
          await _firestoreService.createUserProfile(
            uid: user.uid,
            name: name,
            email: email,
          );
        } catch (firestoreError) {
          debugPrint('Firestore error (non-critical): $firestoreError');
        }

        try {
          await loadUserProfile();
        } catch (e) {
          debugPrint('Load profile error (non-critical): $e');
        }

        _setState(AppState.success);
        return true;
      }

      _setError('Failed to create account');
      return false;
    } catch (e) {
      debugPrint('Sign up error: $e');
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> signIn({required String email, required String password}) async {
    try {
      _setState(AppState.loading);

      final user = await _authService.signInWithEmail(
        email: email,
        password: password,
      );

      if (user != null) {
        await loadUserProfile();

        _setState(AppState.success);
        return true;
      }

      _setError('Failed to sign in');
      return false;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      _setState(AppState.loading);
      await _authService.signOut();
      _currentUser = null;
      _setState(AppState.idle);
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<bool> resetPassword({required String email}) async {
    try {
      _setState(AppState.loading);
      await _authService.resetPassword(email: email);
      _setState(AppState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> loadUserProfile() async {
    try {
      final uid = _authService.currentUserId;
      if (uid != null) {
        _currentUser = await _firestoreService.getUserProfile(uid);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<bool> updateUserProfile({String? name, String? photoUrl}) async {
    try {
      _setState(AppState.loading);

      final uid = _authService.currentUserId;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      final updateData = <String, dynamic>{};
      if (name != null) updateData['name'] = name;
      if (photoUrl != null) updateData['photoUrl'] = photoUrl;
      updateData['updatedAt'] = DateTime.now();

      await _firestoreService.updateUserProfile(uid: uid, data: updateData);

      await loadUserProfile();

      _setState(AppState.success);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<bool> deleteAccount() async {
    try {
      _setState(AppState.loading);

      final uid = _authService.currentUserId;
      if (uid == null) {
        _setError('User not authenticated');
        return false;
      }

      await _firestoreService.deleteUserData(uid);

      await _authService.deleteAccount();

      _currentUser = null;
      _setState(AppState.idle);
      return true;
    } catch (e) {
      _setError(e.toString());
      return false;
    }
  }

  Future<void> checkAuthState() async {
    final user = _authService.currentUser;
    if (user != null) {
      await loadUserProfile();
    }
  }
}
