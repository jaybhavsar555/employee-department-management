// Maps GET /departments response item
class Department {
  const Department({
    required this.id,
    required this.name,
    this.description,
    required this.employeeCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      employeeCount: json['employeeCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int id;
  final String name;
  final String? description;
  final int employeeCount; // How many employees belong to this department
  final String? createdAt;
  final String? updatedAt;
}

// Body sent to POST /departments and PUT /departments/{id}
class DepartmentRequest {
  const DepartmentRequest({required this.name, this.description});

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null && description!.isNotEmpty)
          'description': description,
      };

  final String name;
  final String? description;
}
