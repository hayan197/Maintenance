/// إعدادات الاتصال بالـ API.
///
/// غيّر [baseUrl] ليشير إلى دومين الباكيند الفعلي عند النشر.
/// أثناء التطوير المحلي على المحاكي:
///  - محاكي أندرويد: استخدم http://10.0.2.2:8000/api/v1
///  - جهاز آيفون/محاكي iOS أو جهاز حقيقي على نفس الشبكة: استخدم عنوان IP
///    الفعلي لجهاز التطوير، مثل http://192.168.1.10:8000/api/v1
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://10.0.2.2:8000/api/v1',
  );

  static const Duration timeout = Duration(seconds: 20);
}
