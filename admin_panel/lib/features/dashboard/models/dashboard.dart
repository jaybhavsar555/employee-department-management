import 'package:flutter/material.dart';

class DashboardStats {
  const DashboardStats({
    required this.departments,
    required this.employees,
    required this.projects,
    required this.tasks,
    required this.pendingTasks,
    required this.completedTasks,
  });

  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    return DashboardStats(
      departments: json['departments'] as int,
      employees: json['employees'] as int,
      projects: json['projects'] as int,
      tasks: json['tasks'] as int,
      pendingTasks: json['pendingTasks'] as int,
      completedTasks: json['completedTasks'] as int,
    );
  }

  final int departments;
  final int employees;
  final int projects;
  final int tasks;
  final int pendingTasks;
  final int completedTasks;
}

class ActivityItem {
  const ActivityItem({
    required this.type,
    required this.message,
    required this.entityId,
    required this.timestamp,
  });

  factory ActivityItem.fromJson(Map<String, dynamic> json) {
    return ActivityItem(
      type: json['type'] as String,
      message: json['message'] as String,
      entityId: json['entityId'] as int,
      timestamp: json['timestamp'] as String,
    );
  }

  IconData get icon {
    switch (type) {
      case 'EMPLOYEE_CREATED':
      case 'EMPLOYEE_UPDATED':
        return Icons.person_outline;
      case 'DEPARTMENT_CREATED':
      case 'DEPARTMENT_UPDATED':
        return Icons.business_outlined;
      case 'PROJECT_CREATED':
      case 'PROJECT_UPDATED':
        return Icons.folder_outlined;
      case 'TASK_CREATED':
      case 'TASK_COMPLETED':
        return Icons.task_alt_outlined;
      default:
        return Icons.history;
    }
  }

  final String type;
  final String message;
  final int entityId;
  final String timestamp;
}
