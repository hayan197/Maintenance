import 'dart:io' show Platform;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  static const _tokenKey = 'fixflow_auth_token';

  /// يحاول استرجاع توكن محفوظ من تشغيل سابق للتطبيق (تسجيل دخول تلقائي).
  Future<String?> loadPersistedToken() async {
    final token = await _storage.read(key: _tokenKey);
    if (token != null) {
      _apiClient.setToken(token);
    }
    return token;
  }

  Future<CustomerUser> login({required String email, required String password}) async {
    final payload = await _apiClient.post('/login', {
      'email': email,
      'password': password,
      'device_name': _deviceName(),
    });

    final data = payload['data'] as Map<String, dynamic>;
    final token = data['token'] as String;

    await _storage.write(key: _tokenKey, value: token);
    _apiClient.setToken(token);

    return CustomerUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/logout');
    } catch (_) {
      // نتجاهل خطأ الشبكة هنا: حتى لو فشل استدعاء السيرفر، نحذف التوكن محليًا
      // حتى لا يبقى المستخدم "عالقًا" بجلسة لا يقدر يخرج منها.
    }
    await _storage.delete(key: _tokenKey);
    _apiClient.setToken(null);
  }

  Future<CustomerUser> fetchMe() async {
    final payload = await _apiClient.get('/me');
    return CustomerUser.fromJson(payload['data'] as Map<String, dynamic>);
  }

  String _deviceName() {
    try {
      if (Platform.isAndroid) return 'android-app';
      if (Platform.isIOS) return 'ios-app';
    } catch (_) {
      // Platform غير متاحة على الويب؛ الافتراضي كافٍ.
    }
    return 'mobile-app';
  }
}
