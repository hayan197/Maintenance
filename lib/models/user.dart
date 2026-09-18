class CustomerUser {
  final int id;
  final String name;
  final String email;
  final String role;

  CustomerUser({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
  });

  factory CustomerUser.fromJson(Map<String, dynamic> json) {
    return CustomerUser(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'customer',
    );
  }
}
