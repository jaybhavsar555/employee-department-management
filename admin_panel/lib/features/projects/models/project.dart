import '../../../core/models/page_response.dart';

enum ProjectStatus {
  planned('PLANNED'),
  active('ACTIVE'),
  onHold('ON_HOLD'),
  completed('COMPLETED'),
  cancelled('CANCELLED');

  const ProjectStatus(this.apiValue);
  final String apiValue;

  static ProjectStatus fromApi(String value) {
    return ProjectStatus.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => ProjectStatus.planned,
    );
  }

  String get label {
    switch (this) {
      case ProjectStatus.planned:
        return 'Planned';
      case ProjectStatus.active:
        return 'Active';
      case ProjectStatus.onHold:
        return 'On Hold';
      case ProjectStatus.completed:
        return 'Completed';
      case ProjectStatus.cancelled:
        return 'Cancelled';
    }
  }
}

class Project {
  const Project({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    this.startDate,
    this.endDate,
    required this.departmentId,
    this.departmentName,
    this.leadEmployeeId,
    this.leadEmployeeName,
    required this.taskCount,
    this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: ProjectStatus.fromApi(json['status'] as String),
      startDate: json['startDate'] as String?,
      endDate: json['endDate'] as String?,
      departmentId: json['departmentId'] as int,
      departmentName: json['departmentName'] as String?,
      leadEmployeeId: json['leadEmployeeId'] as int?,
      leadEmployeeName: json['leadEmployeeName'] as String?,
      taskCount: json['taskCount'] as int? ?? 0,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int id;
  final String name;
  final String? description;
  final ProjectStatus status;
  final String? startDate;
  final String? endDate;
  final int departmentId;
  final String? departmentName;
  final int? leadEmployeeId;
  final String? leadEmployeeName;
  final int taskCount;
  final String? createdAt;
  final String? updatedAt;
}

class ProjectRequest {
  const ProjectRequest({
    required this.name,
    this.description,
    this.status,
    this.startDate,
    this.endDate,
    required this.departmentId,
    this.leadEmployeeId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (status != null) 'status': status!.apiValue,
        if (startDate != null) 'startDate': startDate,
        if (endDate != null) 'endDate': endDate,
        'departmentId': departmentId,
        if (leadEmployeeId != null) 'leadEmployeeId': leadEmployeeId,
      };

  final String name;
  final String? description;
  final ProjectStatus? status;
  final String? startDate;
  final String? endDate;
  final int departmentId;
  final int? leadEmployeeId;
}

typedef ProjectPage = PageResponse<Project>;
