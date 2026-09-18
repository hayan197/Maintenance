import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authService);

  final AuthService _authService;

  AuthStatus status = AuthStatus.unknown;
  CustomerUser? currentUser;
  String? loginError;
  bool isLoading = false;

  /// يحاول استعادة الجلسة عند فتح التطبيق من جديد.
  Future<void> tryAutoLogin() async {
    final token = await _authService.loadPersistedToken();
    if (token == null) {
      status = AuthStatus.unauthenticated;
      notifyListeners();
      return;
    }

    try {
      currentUser = await _authService.fetchMe();
      status = AuthStatus.authenticated;
    } catch (_) {
      status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    loginError = null;
    notifyListeners();

    try {
      currentUser = await _authService.login(email: email, password: password);
      status = AuthStatus.authenticated;
      return true;
    } catch (error) {
      loginError = error.toString();
      status = AuthStatus.unauthenticated;
      return false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    currentUser = null;
    status = AuthStatus.unauthenticated;
    notifyListeners();
  }
}
