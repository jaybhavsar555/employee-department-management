package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.response.ActivityItemResponse;
import com.learning.employeedept.dto.response.ActivityType;
import com.learning.employeedept.dto.response.DashboardStatsResponse;
import com.learning.employeedept.entity.BaseEntity;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.Task;
import com.learning.employeedept.entity.TaskStatus;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.repository.ProjectRepository;
import com.learning.employeedept.repository.TaskRepository;
import com.learning.employeedept.service.DashboardService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.ArrayList;
import java.util.Comparator;
import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DashboardServiceImpl implements DashboardService {

    private static final List<TaskStatus> PENDING_EXCLUDED = List.of(TaskStatus.DONE, TaskStatus.CANCELLED);

    private final DepartmentRepository departmentRepository;
    private final EmployeeRepository employeeRepository;
    private final ProjectRepository projectRepository;
    private final TaskRepository taskRepository;

    @Override
    @Transactional(readOnly = true)
    public DashboardStatsResponse getStats() {
        return DashboardStatsResponse.builder()
                .departments(departmentRepository.count())
                .employees(employeeRepository.count())
                .projects(projectRepository.count())
                .tasks(taskRepository.count())
                .pendingTasks(taskRepository.countByStatusNotIn(PENDING_EXCLUDED))
                .completedTasks(taskRepository.countByStatus(TaskStatus.DONE))
                .build();
    }

    @Override
    @Transactional(readOnly = true)
    public List<ActivityItemResponse> getRecentActivity(int limit) {
        int fetchSize = Math.max(limit, 1);
        Sort sort = Sort.by(Sort.Direction.DESC, "updatedAt");
        PageRequest pageRequest = PageRequest.of(0, fetchSize, sort);

        List<ActivityItemResponse> activity = new ArrayList<>();
        departmentRepository.findAll(pageRequest).forEach(d -> activity.add(toDepartmentActivity(d)));
        employeeRepository.findAll(pageRequest).forEach(e -> activity.add(toEmployeeActivity(e)));
        projectRepository.findAll(pageRequest).forEach(p -> activity.add(toProjectActivity(p)));
        taskRepository.findAll(pageRequest).forEach(t -> activity.add(toTaskActivity(t)));

        activity.sort(Comparator.comparing(ActivityItemResponse::getTimestamp).reversed());
        if (activity.size() <= limit) {
            return activity;
        }
        return activity.subList(0, limit);
    }

    private ActivityItemResponse toDepartmentActivity(Department department) {
        ActivityType type = isNewlyCreated(department)
                ? ActivityType.DEPARTMENT_CREATED
                : ActivityType.DEPARTMENT_UPDATED;
        String message = type == ActivityType.DEPARTMENT_CREATED
                ? "Department \"" + department.getName() + "\" was created"
                : "Department \"" + department.getName() + "\" was updated";
        return buildActivity(type, message, department);
    }

    private ActivityItemResponse toEmployeeActivity(Employee employee) {
        ActivityType type = isNewlyCreated(employee)
                ? ActivityType.EMPLOYEE_CREATED
                : ActivityType.EMPLOYEE_UPDATED;
        String fullName = employee.getFirstName() + " " + employee.getLastName();
        String message = type == ActivityType.EMPLOYEE_CREATED
                ? "Employee " + fullName + " was created"
                : "Employee " + fullName + " was updated";
        return buildActivity(type, message, employee);
    }

    private ActivityItemResponse toProjectActivity(Project project) {
        ActivityType type = isNewlyCreated(project)
                ? ActivityType.PROJECT_CREATED
                : ActivityType.PROJECT_UPDATED;
        String message = type == ActivityType.PROJECT_CREATED
                ? "Project \"" + project.getName() + "\" was created"
                : "Project \"" + project.getName() + "\" was updated";
        return buildActivity(type, message, project);
    }

    private ActivityItemResponse toTaskActivity(Task task) {
        if (task.getStatus() == TaskStatus.DONE) {
            return buildActivity(ActivityType.TASK_COMPLETED,
                    "Task \"" + task.getTitle() + "\" was completed", task);
        }
        String message = isNewlyCreated(task)
                ? "Task \"" + task.getTitle() + "\" was created"
                : "Task \"" + task.getTitle() + "\" was updated";
        return buildActivity(ActivityType.TASK_CREATED, message, task);
    }

    private ActivityItemResponse buildActivity(ActivityType type, String message, BaseEntity entity) {
        return ActivityItemResponse.builder()
                .type(type)
                .message(message)
                .entityId(entity.getId())
                .timestamp(entity.getUpdatedAt())
                .build();
    }

    private boolean isNewlyCreated(BaseEntity entity) {
        return entity.getCreatedAt().equals(entity.getUpdatedAt());
    }
}
