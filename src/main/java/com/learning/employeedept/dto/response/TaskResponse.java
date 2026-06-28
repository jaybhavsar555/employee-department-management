package com.learning.employeedept.dto.response;

import com.learning.employeedept.entity.TaskPriority;
import com.learning.employeedept.entity.TaskStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class TaskResponse {

    private final Long id;
    private final String title;
    private final String description;
    private final TaskStatus status;
    private final TaskPriority priority;
    private final LocalDate dueDate;
    private final Long projectId;
    private final String projectName;
    private final Long assigneeId;
    private final String assigneeName;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
}
