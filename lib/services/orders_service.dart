import '../models/order.dart';
import 'api_client.dart';

class OrdersPage {
  final List<ServiceOrder> orders;
  final int currentPage;
  final int lastPage;
  final int total;

  OrdersPage({
    required this.orders,
    required this.currentPage,
    required this.lastPage,
    required this.total,
  });
}

class OrderDetails {
  final ServiceOrder order;
  final List<Map<String, dynamic>> items;

  OrderDetails({required this.order, required this.items});
}

class OrdersService {
  OrdersService(this._apiClient);

  final ApiClient _apiClient;

  Future<OrdersPage> fetchOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    final payload = await _apiClient.get('/customer/orders', query: {
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
    });

    final data = (payload['data'] as List<dynamic>? ?? [])
        .map((item) => ServiceOrder.fromJson(item as Map<String, dynamic>))
        .toList();

    final meta = payload['meta'] as Map<String, dynamic>? ?? {};

    return OrdersPage(
      orders: data,
      currentPage: meta['current_page'] as int? ?? 1,
      lastPage: meta['last_page'] as int? ?? 1,
      total: meta['total'] as int? ?? data.length,
    );
  }

  Future<OrderDetails> fetchOrderDetails(int orderId) async {
    final payload = await _apiClient.get('/customer/orders/$orderId');
    final order = ServiceOrder.fromJson(payload['data'] as Map<String, dynamic>);
    final meta = payload['meta'] as Map<String, dynamic>? ?? {};
    final items = (meta['items'] as List<dynamic>? ?? [])
        .map((item) => item as Map<String, dynamic>)
        .toList();
    return OrderDetails(order: order, items: items);
  }

  Future<ServiceOrder> createOrder(Map<String, dynamic> payload) async {
    final response = await _apiClient.post('/customer/orders', payload);
    return ServiceOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ServiceOrder> updateOrder(int orderId, Map<String, dynamic> payload) async {
    final response = await _apiClient.put('/customer/orders/$orderId', payload);
    return ServiceOrder.fromJson(response['data'] as Map<String, dynamic>);
  }

  Future<ServiceOrder> cancelOrder(int orderId) async {
    final response = await _apiClient.post('/customer/orders/$orderId/cancel');
    return ServiceOrder.fromJson(response['data'] as Map<String, dynamic>);
  }
}
