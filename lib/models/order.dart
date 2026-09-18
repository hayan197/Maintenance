class ServiceOrder {
  final int id;
  final String orderCode;
  final String title;
  final String? description;
  final String serviceType;
  final String orderType; // standard | urgent | emergency
  final String priority; // low | normal | high | critical
  final String status; // pending | assigned | in_progress | on_hold | completed | cancelled
  final bool isEmergency;
  final String? address;
  final DateTime? scheduledAt;
  final DateTime? completedAt;
  final num? totalAmount;
  final String? customerName;
  final String? technicianName;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ServiceOrder({
    required this.id,
    required this.orderCode,
    required this.title,
    this.description,
    required this.serviceType,
    required this.orderType,
    required this.priority,
    required this.status,
    required this.isEmergency,
    this.address,
    this.scheduledAt,
    this.completedAt,
    this.totalAmount,
    this.customerName,
    this.technicianName,
    this.createdAt,
    this.updatedAt,
  });

  factory ServiceOrder.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value.toString());
    }

    return ServiceOrder(
      id: json['id'] as int,
      orderCode: json['order_code']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString(),
      serviceType: json['service_type']?.toString() ?? '',
      orderType: json['order_type']?.toString() ?? 'standard',
      priority: json['priority']?.toString() ?? 'normal',
      status: json['status']?.toString() ?? 'pending',
      isEmergency: json['is_emergency'] == true,
      address: json['address']?.toString(),
      scheduledAt: parseDate(json['scheduled_at']),
      completedAt: parseDate(json['completed_at']),
      totalAmount: json['total_amount'] == null
          ? null
          : num.tryParse(json['total_amount'].toString()),
      customerName: json['customer_name']?.toString(),
      technicianName: json['technician_name']?.toString(),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  bool get isCancellable =>
      ['pending', 'assigned', 'in_progress', 'on_hold'].contains(status);
}

/// تسميات عربية مطابقة تمامًا لما تعرضه لوحة العميل على الويب.
const Map<String, String> orderStatusLabels = {
  'pending': 'قيد الانتظار',
  'assigned': 'تم الإسناد',
  'in_progress': 'قيد التنفيذ',
  'on_hold': 'معلق',
  'completed': 'مكتمل',
  'cancelled': 'ملغي',
};

const Map<String, String> orderTypeLabels = {
  'standard': 'عادي',
  'urgent': 'عاجل',
  'emergency': 'طارئ',
};

const Map<String, String> orderPriorityLabels = {
  'low': 'منخفضة',
  'normal': 'عادية',
  'high': 'عالية',
  'critical': 'حرجة',
};

String labelFor(Map<String, String> map, String key) => map[key] ?? key;
