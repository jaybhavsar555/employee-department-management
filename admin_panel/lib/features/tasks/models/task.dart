import '../../../core/models/page_response.dart';

enum TaskStatus {
  todo('TODO'),
  inProgress('IN_PROGRESS'),
  inReview('IN_REVIEW'),
  done('DONE'),
  cancelled('CANCELLED');

  const TaskStatus(this.apiValue);
  final String apiValue;

  static TaskStatus fromApi(String value) {
    return TaskStatus.values.firstWhere(
      (s) => s.apiValue == value,
      orElse: () => TaskStatus.todo,
    );
  }

  bool get isPending => this != done && this != cancelled;

  String get label {
    switch (this) {
      case TaskStatus.todo:
        return 'Pending';
      case TaskStatus.inProgress:
        return 'In Progress';
      case TaskStatus.inReview:
        return 'In Review';
      case TaskStatus.done:
        return 'Completed';
      case TaskStatus.cancelled:
        return 'Cancelled';
    }
  }
}

enum TaskPriority {
  low('LOW'),
  medium('MEDIUM'),
  high('HIGH'),
  critical('CRITICAL');

  const TaskPriority(this.apiValue);
  final String apiValue;

  static TaskPriority fromApi(String value) {
    return TaskPriority.values.firstWhere(
      (p) => p.apiValue == value,
      orElse: () => TaskPriority.medium,
    );
  }
}

class TaskItem {
  const TaskItem({
    required this.id,
    required this.title,
    this.description,
    required this.status,
    required this.priority,
    this.dueDate,
    required this.projectId,
    this.projectName,
    this.assigneeId,
    this.assigneeName,
    this.createdAt,
    this.updatedAt,
  });

  factory TaskItem.fromJson(Map<String, dynamic> json) {
    return TaskItem(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String?,
      status: TaskStatus.fromApi(json['status'] as String),
      priority: TaskPriority.fromApi(json['priority'] as String),
      dueDate: json['dueDate'] as String?,
      projectId: json['projectId'] as int,
      projectName: json['projectName'] as String?,
      assigneeId: json['assigneeId'] as int?,
      assigneeName: json['assigneeName'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final int id;
  final String title;
  final String? description;
  final TaskStatus status;
  final TaskPriority priority;
  final String? dueDate;
  final int projectId;
  final String? projectName;
  final int? assigneeId;
  final String? assigneeName;
  final String? createdAt;
  final String? updatedAt;
}

class TaskRequest {
  const TaskRequest({
    required this.title,
    this.description,
    this.status,
    this.priority,
    this.dueDate,
    required this.projectId,
    this.assigneeId,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null && description!.isNotEmpty)
          'description': description,
        if (status != null) 'status': status!.apiValue,
        if (priority != null) 'priority': priority!.apiValue,
        if (dueDate != null) 'dueDate': dueDate,
        'projectId': projectId,
        if (assigneeId != null) 'assigneeId': assigneeId,
      };

  final String title;
  final String? description;
  final TaskStatus? status;
  final TaskPriority? priority;
  final String? dueDate;
  final int projectId;
  final int? assigneeId;
}

typedef TaskPage = PageResponse<TaskItem>;

/// UI filter: pending vs completed tasks.
enum TaskCompletionFilter { pending, completed, all }
