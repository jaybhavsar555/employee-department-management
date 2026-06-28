package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.request.TaskRequest;
import com.learning.employeedept.dto.response.TaskResponse;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.Task;
import com.learning.employeedept.entity.TaskPriority;
import com.learning.employeedept.entity.TaskStatus;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.TaskMapper;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.repository.ProjectRepository;
import com.learning.employeedept.repository.TaskRepository;
import com.learning.employeedept.service.TaskService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class TaskServiceImpl implements TaskService {

    private final TaskRepository taskRepository;
    private final ProjectRepository projectRepository;
    private final EmployeeRepository employeeRepository;
    private final TaskMapper taskMapper;

    @Override
    @Transactional
    public TaskResponse create(TaskRequest request) {
        Project project = findProject(request.getProjectId());
        Employee assignee = findAssignee(request.getAssigneeId());

        Task task = taskMapper.toEntity(request, project, assignee);
        Task saved = taskRepository.save(task);
        log.info("Created task id={} title={}", saved.getId(), saved.getTitle());
        return taskMapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public TaskResponse getById(Long id) {
        Task task = findTask(id);
        return taskMapper.toResponse(task);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<TaskResponse> getAll(Long projectId, Long assigneeId, TaskStatus status,
                                     TaskPriority priority, String search, Pageable pageable) {
        log.debug("Fetching tasks page={} projectId={} assigneeId={} status={} priority={} search={}",
                pageable.getPageNumber(), projectId, assigneeId, status, priority, search);
        return taskRepository.findWithFilters(projectId, assigneeId, status, priority, search, pageable)
                .map(taskMapper::toResponse);
    }

    @Override
    @Transactional
    public TaskResponse update(Long id, TaskRequest request) {
        Task task = findTask(id);
        Project project = findProject(request.getProjectId());
        Employee assignee = findAssignee(request.getAssigneeId());

        taskMapper.updateEntity(task, request, project, assignee);
        log.info("Updated task id={}", id);
        return taskMapper.toResponse(task);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Task task = findTask(id);
        taskRepository.delete(task);
        log.info("Deleted task id={}", id);
    }

    private Task findTask(Long id) {
        return taskRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Task not found with id: " + id));
    }

    private Project findProject(Long id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found with id: " + id));
    }

    private Employee findAssignee(Long assigneeId) {
        if (assigneeId == null) {
            return null;
        }
        return employeeRepository.findById(assigneeId)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + assigneeId));
    }
}
