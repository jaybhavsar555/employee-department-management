package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.TaskRequest;
import com.learning.employeedept.dto.response.TaskResponse;
import com.learning.employeedept.entity.TaskPriority;
import com.learning.employeedept.entity.TaskStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface TaskService {

    TaskResponse create(TaskRequest request);

    TaskResponse getById(Long id);

    Page<TaskResponse> getAll(Long projectId, Long assigneeId, TaskStatus status,
                              TaskPriority priority, String search, Pageable pageable);

    TaskResponse update(Long id, TaskRequest request);

    void delete(Long id);
}
