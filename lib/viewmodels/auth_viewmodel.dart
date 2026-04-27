import 'package:flutter/material.dart';
import '../providers/auth_provider.dart';
import '../core/models/app_state.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthProvider _authProvider = AuthProvider();

  AuthProvider get authProvider => _authProvider;
  AppState get state => _authProvider.state;
  String? get errorMessage => _authProvider.errorMessage;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  bool get isLoading => _authProvider.state == AppState.loading;

  AuthViewModel() {
    _authProvider.addListener(_onAuthProviderUpdate);
  }

  void _onAuthProviderUpdate() {
    notifyListeners();
  }

  // Sign up
  Future<bool> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    return await _authProvider.signUp(
      name: name,
      email: email,
      password: password,
    );
  }

  // Sign in
  Future<bool> signIn({required String email, required String password}) async {
    return await _authProvider.signIn(email: email, password: password);
  }

  // Sign out
  Future<void> signOut() async {
    await _authProvider.signOut();
  }

  // Reset password
  Future<bool> resetPassword({required String email}) async {
    return await _authProvider.resetPassword(email: email);
  }

  // Clear error
  void clearError() {
    _authProvider.clearError();
  }

  // Check authentication state
  Future<void> checkAuthState() async {
    await _authProvider.checkAuthState();
  }

  @override
  void dispose() {
    _authProvider.removeListener(_onAuthProviderUpdate);
    _authProvider.dispose();
    super.dispose();
  }
}
