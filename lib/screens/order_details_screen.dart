import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/orders_service.dart';
import '../widgets/status_pill.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key, required this.orderId, required this.ordersService});

  final int orderId;
  final OrdersService ordersService;

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  OrderDetails? _details;
  bool _isLoading = true;
  String? _error;
  bool _isCancelling = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final details = await widget.ordersService.fetchOrderDetails(widget.orderId);
      setState(() => _details = details);
    } catch (error) {
      setState(() => _error = 'تعذر تحميل تفاصيل الطلب.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _cancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: const Text('هل تريد إلغاء هذا الطلب؟'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('تراجع')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('نعم، إلغاء'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isCancelling = true);
    try {
      await context.read<OrdersProvider>().cancelOrder(widget.orderId);
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إلغاء الطلب.')),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تعذر إلغاء الطلب، حاول مرة أخرى.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isCancelling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الطلب')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final order = _details!.order;
    final dateFormat = DateFormat('d MMM yyyy - HH:mm', 'ar');

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(order.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ),
              StatusPill(status: order.status),
            ],
          ),
          const SizedBox(height: 6),
          Text(order.orderCode, style: TextStyle(color: Colors.grey.shade600)),
          const SizedBox(height: 16),
          if (order.description != null && order.description!.isNotEmpty) ...[
            Text(order.description!),
            const SizedBox(height: 16),
          ],
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _infoRow('نوع الخدمة', order.serviceType),
                  _infoRow('نوع الطلب', labelFor(orderTypeLabels, order.orderType)),
                  _infoRow('الأولوية', labelFor(orderPriorityLabels, order.priority)),
                  _infoRow('الفني', order.technicianName ?? 'لم يُسند بعد'),
                  _infoRow('العنوان', order.address ?? '—'),
                  _infoRow(
                    'الموعد',
                    order.scheduledAt != null ? dateFormat.format(order.scheduledAt!) : '—',
                  ),
                  if (order.totalAmount != null)
                    _infoRow('المبلغ', order.totalAmount.toString()),
                ],
              ),
            ),
          ),
          if (_details!.items.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text('تفاصيل الفاتورة', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Card(
              child: Column(
                children: _details!.items
                    .map(
                      (item) => ListTile(
                        title: Text(item['item_name']?.toString() ?? ''),
                        trailing: Text('${item['quantity']} × ${item['price']}'),
                      ),
                    )
                    .toList(),
              ),
            ),
          ],
          if (order.isCancellable) ...[
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: _isCancelling ? null : _cancel,
              style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
              child: _isCancelling ? const Text('جارٍ الإلغاء...') : const Text('إلغاء الطلب'),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Flexible(child: Text(value, textAlign: TextAlign.left)),
        ],
      ),
    );
  }
}
