class Employee {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String department;
  final String position;
  final String employeeId;
  final DateTime hireDate;
  final double salary;
  final String status; // active, inactive, terminated
  final String? managerId;
  final DateTime? terminationDate;
  final String? address;
  final String? emergencyContact;
  final String? emergencyPhone;
  final DateTime createdAt;
  final DateTime updatedAt;

  Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.department,
    required this.position,
    required this.employeeId,
    required this.hireDate,
    required this.salary,
    required this.status,
    this.managerId,
    this.terminationDate,
    this.address,
    this.emergencyContact,
    this.emergencyPhone,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      department: json['department'] ?? '',
      position: json['position'] ?? '',
      employeeId: json['employee_id'] ?? '',
      hireDate: DateTime.parse(json['hire_date'] ?? DateTime.now().toIso8601String()),
      salary: (json['salary'] ?? 0).toDouble(),
      status: json['status'] ?? 'active',
      managerId: json['manager_id'],
      terminationDate: json['termination_date'] != null 
          ? DateTime.parse(json['termination_date']) 
          : null,
      address: json['address'],
      emergencyContact: json['emergency_contact'],
      emergencyPhone: json['emergency_phone'],
      createdAt: DateTime.parse(json['created_at'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(json['updated_at'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'department': department,
      'position': position,
      'employee_id': employeeId,
      'hire_date': hireDate.toIso8601String(),
      'salary': salary,
      'status': status,
      'manager_id': managerId,
      'termination_date': terminationDate?.toIso8601String(),
      'address': address,
      'emergency_contact': emergencyContact,
      'emergency_phone': emergencyPhone,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  Employee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? department,
    String? position,
    String? employeeId,
    DateTime? hireDate,
    double? salary,
    String? status,
    String? managerId,
    DateTime? terminationDate,
    String? address,
    String? emergencyContact,
    String? emergencyPhone,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Employee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      department: department ?? this.department,
      position: position ?? this.position,
      employeeId: employeeId ?? this.employeeId,
      hireDate: hireDate ?? this.hireDate,
      salary: salary ?? this.salary,
      status: status ?? this.status,
      managerId: managerId ?? this.managerId,
      terminationDate: terminationDate ?? this.terminationDate,
      address: address ?? this.address,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      emergencyPhone: emergencyPhone ?? this.emergencyPhone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get fullName => '$firstName $lastName';
}
