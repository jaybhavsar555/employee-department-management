package com.learning.employeedept.mapper;

import com.learning.employeedept.dto.request.TaskRequest;
import com.learning.employeedept.dto.response.TaskResponse;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.Task;
import com.learning.employeedept.entity.TaskPriority;
import com.learning.employeedept.entity.TaskStatus;
import org.springframework.stereotype.Component;

@Component
public class TaskMapper {

    public Task toEntity(TaskRequest request, Project project, Employee assignee) {
        return Task.builder()
                .title(request.getTitle().trim())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : TaskStatus.TODO)
                .priority(request.getPriority() != null ? request.getPriority() : TaskPriority.MEDIUM)
                .dueDate(request.getDueDate())
                .project(project)
                .assignee(assignee)
                .build();
    }

    public void updateEntity(Task task, TaskRequest request, Project project, Employee assignee) {
        task.setTitle(request.getTitle().trim());
        task.setDescription(request.getDescription());
        task.setStatus(request.getStatus() != null ? request.getStatus() : task.getStatus());
        task.setPriority(request.getPriority() != null ? request.getPriority() : task.getPriority());
        task.setDueDate(request.getDueDate());
        task.setProject(project);
        task.setAssignee(assignee);
    }

    public TaskResponse toResponse(Task task) {
        Employee assignee = task.getAssignee();
        return TaskResponse.builder()
                .id(task.getId())
                .title(task.getTitle())
                .description(task.getDescription())
                .status(task.getStatus())
                .priority(task.getPriority())
                .dueDate(task.getDueDate())
                .projectId(task.getProject().getId())
                .projectName(task.getProject().getName())
                .assigneeId(assignee != null ? assignee.getId() : null)
                .assigneeName(assignee != null ? assignee.getFirstName() + " " + assignee.getLastName() : null)
                .createdAt(task.getCreatedAt())
                .updatedAt(task.getUpdatedAt())
                .build();
    }
}
