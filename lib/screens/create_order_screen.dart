import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/order.dart';
import '../providers/orders_provider.dart';
import '../services/api_client.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _emergencyContactController = TextEditingController();
  final _notesController = TextEditingController();

  String _serviceType = 'كهرباء';
  String _orderType = 'standard';
  String _priority = 'normal';
  bool _isSubmitting = false;
  Map<String, dynamic>? _fieldErrors;

  bool get _requiresEmergencyContact => _orderType == 'emergency' || _priority == 'critical';

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _emergencyContactController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
      _fieldErrors = null;
    });

    final payload = <String, dynamic>{
      'title': _titleController.text.trim(),
      'service_type': _serviceType,
      'order_type': _orderType,
      'priority': _priority,
      if (_descriptionController.text.trim().isNotEmpty)
        'description': _descriptionController.text.trim(),
      if (_addressController.text.trim().isNotEmpty) 'address': _addressController.text.trim(),
      if (_emergencyContactController.text.trim().isNotEmpty)
        'emergency_contact': _emergencyContactController.text.trim(),
      if (_notesController.text.trim().isNotEmpty) 'notes': _notesController.text.trim(),
    };

    try {
      await context.read<OrdersProvider>().createOrder(payload);
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الطلب بنجاح.')),
        );
      }
    } on ApiException catch (error) {
      setState(() => _fieldErrors = error.errors);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.message)),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلب صيانة جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'عنوان الطلب'),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'يرجى إدخال عنوان الطلب' : null,
              ),
              _fieldError('title'),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'الوصف'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _serviceType,
                decoration: const InputDecoration(labelText: 'نوع الخدمة'),
                items: const ['كهرباء', 'سباكة', 'تكييف', 'أجهزة منزلية', 'أخرى']
                    .map((value) => DropdownMenuItem(value: value, child: Text(value)))
                    .toList(),
                onChanged: (value) => setState(() => _serviceType = value ?? _serviceType),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _orderType,
                decoration: const InputDecoration(labelText: 'نوع الطلب'),
                items: orderTypeLabels.entries
                    .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                    .toList(),
                onChanged: (value) => setState(() => _orderType = value ?? _orderType),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'الأولوية'),
                items: orderPriorityLabels.entries
                    .map((entry) => DropdownMenuItem(value: entry.key, child: Text(entry.value)))
                    .toList(),
                onChanged: (value) => setState(() => _priority = value ?? _priority),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'العنوان'),
              ),
              if (_requiresEmergencyContact) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emergencyContactController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'رقم تواصل الطوارئ',
                    helperText: 'مطلوب للطلبات الطارئة أو ذات الأولوية الحرجة',
                  ),
                  validator: (value) {
                    if (_requiresEmergencyContact && (value == null || value.trim().isEmpty)) {
                      return 'رقم تواصل الطوارئ مطلوب لهذا النوع من الطلبات';
                    }
                    return null;
                  },
                ),
                _fieldError('emergency_contact'),
              ],
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات إضافية'),
                maxLines: 2,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('إرسال الطلب'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldError(String field) {
    final message = _fieldErrors?[field];
    if (message == null) return const SizedBox.shrink();
    final text = message is List ? message.first.toString() : message.toString();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Text(text, style: const TextStyle(color: Colors.red, fontSize: 12)),
    );
  }
}
