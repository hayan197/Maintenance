import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/api_client.dart';
import '../services/orders_service.dart';

class OrdersProvider extends ChangeNotifier {
  OrdersProvider(this._ordersService);

  final OrdersService _ordersService;

  List<ServiceOrder> orders = [];
  bool isLoading = false;
  String? loadError;

  int currentPage = 1;
  int lastPage = 1;
  String? statusFilter;

  int get openCount =>
      orders.where((o) => ['pending', 'assigned'].contains(o.status)).length;
  int get inProgressCount =>
      orders.where((o) => ['in_progress', 'on_hold'].contains(o.status)).length;
  int get completedCount =>
      orders.where((o) => o.status == 'completed').length;

  Future<void> loadOrders({int page = 1}) async {
    isLoading = true;
    loadError = null;
    notifyListeners();

    try {
      final result = await _ordersService.fetchOrders(
        page: page,
        status: statusFilter,
      );
      orders = result.orders;
      currentPage = result.currentPage;
      lastPage = result.lastPage;
    } on ApiException catch (error) {
      loadError = error.message;
    } catch (_) {
      loadError = 'تعذر الاتصال بالسيرفر. تحقق من الإنترنت وحاول مرة أخرى.';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  void setStatusFilter(String? status) {
    statusFilter = status;
    loadOrders(page: 1);
  }

  Future<ServiceOrder> createOrder(Map<String, dynamic> payload) async {
    final order = await _ordersService.createOrder(payload);
    await loadOrders(page: 1);
    return order;
  }

  Future<void> cancelOrder(int orderId) async {
    await _ordersService.cancelOrder(orderId);
    await loadOrders(page: currentPage);
  }
}
