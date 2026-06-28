import '../../../core/models/page_response.dart';

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

typedef EmployeePage = PageResponse<Employee>;
