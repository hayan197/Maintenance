import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/orders_provider.dart';
import '../services/orders_service.dart';
import '../widgets/order_card.dart';
import 'create_order_screen.dart';
import 'order_details_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key, required this.ordersService});

  final OrdersService ordersService;

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final ordersProvider = context.watch<OrdersProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('طلباتي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () => context.read<AuthProvider>().logout(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CreateOrderScreen()),
          );
        },
        label: const Text('طلب جديد'),
        icon: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: () => ordersProvider.loadOrders(page: ordersProvider.currentPage),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (auth.currentUser != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'مرحبًا، ${auth.currentUser!.name}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            _StatsRow(ordersProvider: ordersProvider),
            const SizedBox(height: 16),
            _StatusFilter(ordersProvider: ordersProvider),
            const SizedBox(height: 12),
            if (ordersProvider.isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (ordersProvider.loadError != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text(ordersProvider.loadError!)),
              )
            else if (ordersProvider.orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('لا توجد طلبات مطابقة حتى الآن.')),
              )
            else
              ...ordersProvider.orders.map(
                (order) => OrderCard(
                  order: order,
                  onTap: () => _openDetails(order),
                  onCancel: () => _confirmCancel(order),
                ),
              ),
            if (ordersProvider.lastPage > 1) _Pagination(ordersProvider: ordersProvider),
          ],
        ),
      ),
    );
  }

  Future<void> _openDetails(ServiceOrder order) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => OrderDetailsScreen(orderId: order.id, ordersService: widget.ordersService),
      ),
    );
    if (mounted) {
      context.read<OrdersProvider>().loadOrders(page: context.read<OrdersProvider>().currentPage);
    }
  }

  Future<void> _confirmCancel(ServiceOrder order) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإلغاء'),
        content: Text('هل تريد إلغاء الطلب "${order.title}"؟'),
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

    if (confirmed == true && mounted) {
      try {
        await context.read<OrdersProvider>().cancelOrder(order.id);
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
      }
    }
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.ordersProvider});

  final OrdersProvider ordersProvider;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _StatCard(label: 'مفتوحة', value: ordersProvider.openCount)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'قيد التنفيذ', value: ordersProvider.inProgressCount)),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(label: 'مكتملة', value: ordersProvider.completedCount)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
            const SizedBox(height: 6),
            Text('$value', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _StatusFilter extends StatelessWidget {
  const _StatusFilter({required this.ordersProvider});

  final OrdersProvider ordersProvider;

  @override
  Widget build(BuildContext context) {
    final options = <String, String>{'': 'كل الحالات', ...orderStatusLabels};

    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: options.entries.map((entry) {
          final isSelected = (ordersProvider.statusFilter ?? '') == entry.key;
          return Padding(
            padding: const EdgeInsets.only(left: 8),
            child: ChoiceChip(
              label: Text(entry.value),
              selected: isSelected,
              onSelected: (_) => ordersProvider.setStatusFilter(entry.key.isEmpty ? null : entry.key),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _Pagination extends StatelessWidget {
  const _Pagination({required this.ordersProvider});

  final OrdersProvider ordersProvider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Wrap(
        alignment: WrapAlignment.center,
        spacing: 8,
        children: List.generate(ordersProvider.lastPage, (index) {
          final page = index + 1;
          final isCurrent = page == ordersProvider.currentPage;
          return OutlinedButton(
            onPressed: isCurrent ? null : () => ordersProvider.loadOrders(page: page),
            child: Text('$page'),
          );
        }),
      ),
    );
  }
}
