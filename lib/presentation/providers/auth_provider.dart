import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/services/auth_service.dart';

/// Authentication state
enum AuthState {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

/// AuthProvider manages authentication state and user session
class AuthProvider with ChangeNotifier {
  final AuthService _authService;

  AuthState _state = AuthState.initial;
  User? _user;
  String? _error;
  bool _initialized = false;

  AuthProvider(this._authService) {
    _initialize();
  }

  // Getters
  AuthState get state => _state;
  User? get user => _user;
  String? get error => _error;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  bool get isInitialized => _initialized;
  String? get displayName => _user?.displayName;
  String? get email => _user?.email;
  String? get photoURL => _user?.photoURL;
  String? get uid => _user?.uid;

  /// Initialize auth state listener
  void _initialize() {
    // Check current user immediately
    _user = _authService.currentUser;
    if (_user != null) {
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    _initialized = true;
    
    // Listen to auth state changes
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      if (user != null) {
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
      }
      notifyListeners();
    });
    
    notifyListeners();
  }

  /// Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setState(AuthState.loading);
    _error = null;

    try {
      final user = await _authService.signInWithGoogle();
      if (user != null) {
        _user = user;
        _setState(AuthState.authenticated);
        return true;
      } else {
        _setState(AuthState.unauthenticated);
        return false;
      }
    } on FirebaseAuthException catch (e) {
      _error = _getErrorMessage(e.code);
      _setState(AuthState.error);
      return false;
    } catch (e) {
      _error = 'Giriş yapılırken bir hata oluştu: ${e.toString()}';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _setState(AuthState.loading);
    try {
      await _authService.signOut();
      _user = null;
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _error = 'Çıkış yapılırken bir hata oluştu.';
      _setState(AuthState.error);
    }
  }

  /// Delete account
  Future<bool> deleteAccount() async {
    _setState(AuthState.loading);
    try {
      await _authService.deleteAccount();
      _user = null;
      _setState(AuthState.unauthenticated);
      return true;
    } catch (e) {
      _error = 'Hesap silinirken bir hata oluştu.';
      _setState(AuthState.error);
      return false;
    }
  }

  /// Clear error
  void clearError() {
    _error = null;
    if (_state == AuthState.error) {
      _state = _user != null ? AuthState.authenticated : AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Set state and notify listeners
  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  /// Get user-friendly error message
  String _getErrorMessage(String code) {
    switch (code) {
      case 'user-disabled':
        return 'Bu hesap devre dışı bırakılmış.';
      case 'user-not-found':
        return 'Kullanıcı bulunamadı.';
      case 'wrong-password':
        return 'Yanlış şifre.';
      case 'invalid-email':
        return 'Geçersiz e-posta adresi.';
      case 'email-already-in-use':
        return 'Bu e-posta adresi zaten kullanılıyor.';
      case 'operation-not-allowed':
        return 'Bu işlem şu anda izin verilmiyor.';
      case 'weak-password':
        return 'Şifre çok zayıf.';
      case 'network-request-failed':
        return 'İnternet bağlantısını kontrol edin.';
      case 'popup-closed-by-user':
        return 'Giriş penceresi kapatıldı.';
      case 'cancelled-popup-request':
        return 'Giriş işlemi iptal edildi.';
      default:
        return 'Bir hata oluştu. Lütfen tekrar deneyin.';
    }
  }
}
