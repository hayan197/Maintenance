import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// استثناء موحّد لكل أخطاء الـ API، يحمل رسالة عربية جاهزة للعرض
/// وأخطاء التحقق الحقلية (إن وجدت) لعرضها تحت كل حقل في النموذج.
class ApiException implements Exception {
  final String message;
  final int statusCode;
  final Map<String, dynamic>? errors;

  ApiException(this.message, this.statusCode, {this.errors});

  /// أول رسالة خطأ لحقل معيّن، مفيدة لعرضها تحت حقل النموذج مباشرة.
  String? errorFor(String field) {
    final value = errors?[field];
    if (value is List && value.isNotEmpty) return value.first.toString();
    return null;
  }

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;
  String? _token;

  void setToken(String? token) => _token = token;

  Map<String, String> get _headers => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  Uri _uri(String path, [Map<String, dynamic>? query]) {
    final cleanQuery = query?.map((key, value) => MapEntry(key, value.toString()));
    return Uri.parse('${ApiConfig.baseUrl}$path').replace(queryParameters: cleanQuery);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, dynamic>? query}) async {
    final response = await _client
        .get(_uri(path, query), headers: _headers)
        .timeout(ApiConfig.timeout);
    return _handle(response);
  }

  Future<Map<String, dynamic>> post(String path, [Map<String, dynamic>? body]) async {
    final response = await _client
        .post(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _handle(response);
  }

  Future<Map<String, dynamic>> put(String path, [Map<String, dynamic>? body]) async {
    final response = await _client
        .put(_uri(path), headers: _headers, body: jsonEncode(body ?? {}))
        .timeout(ApiConfig.timeout);
    return _handle(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client
        .delete(_uri(path), headers: _headers)
        .timeout(ApiConfig.timeout);
    return _handle(response);
  }

  Map<String, dynamic> _handle(http.Response response) {
    Map<String, dynamic> decoded = {};
    if (response.body.isNotEmpty) {
      try {
        decoded = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {
        decoded = {};
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    if (response.statusCode == 401) {
      throw ApiException('انتهت الجلسة، يرجى تسجيل الدخول مرة أخرى.', 401);
    }

    if (response.statusCode == 403) {
      throw ApiException(
        decoded['message']?.toString() ?? 'غير مصرح لك بهذا الإجراء.',
        403,
      );
    }

    throw ApiException(
      decoded['message']?.toString() ?? 'حدث خطأ غير متوقع، حاول مرة أخرى.',
      response.statusCode,
      errors: decoded['errors'] as Map<String, dynamic>?,
    );
  }
}
