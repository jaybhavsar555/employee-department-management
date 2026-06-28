class Employee {
  const Employee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.salary,
    required this.hireDate,
    required this.departmentId,
    this.departmentName,
    this.createdAt,
    this.updatedAt,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'] as int,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      email: json['email'] as String,
      salary: (json['salary'] as num).toDouble(),
      hireDate: json['hireDate'] as String,
      departmentId: json['departmentId'] as int,
      departmentName: json['departmentName'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  String get fullName => '$firstName $lastName';

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final double salary;
  final String hireDate;
  final int departmentId;
  final String? departmentName;
  final String? createdAt;
  final String? updatedAt;
}

class EmployeeRequest {
  const EmployeeRequest({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.salary,
    required this.hireDate,
    required this.departmentId,
  });

  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'salary': salary,
        'hireDate': hireDate,
        'departmentId': departmentId,
      };

  final String firstName;
  final String lastName;
  final String email;
  final double salary;
  final String hireDate;
  final int departmentId;
}

class PageResponse<T> {
  const PageResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.size,
    required this.number,
  });

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final content = (json['content'] as List<dynamic>)
        .map((item) => fromJsonT(item as Map<String, dynamic>))
        .toList();

    return PageResponse(
      content: content,
      totalElements: json['totalElements'] as int,
      totalPages: json['totalPages'] as int,
      size: json['size'] as int,
      number: json['number'] as int,
    );
  }

  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int size;
  final int number;
}
