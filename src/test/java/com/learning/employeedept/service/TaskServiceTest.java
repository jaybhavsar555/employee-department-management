package com.learning.employeedept.service;

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
import com.learning.employeedept.service.impl.TaskServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.eq;
import static org.mockito.ArgumentMatchers.isNull;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class TaskServiceTest {

    @Mock
    private TaskRepository taskRepository;

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private TaskMapper taskMapper;

    @InjectMocks
    private TaskServiceImpl taskService;

    @Test
    void create_shouldReturnTaskResponse() {
        TaskRequest request = buildRequest();
        Project project = Project.builder().name("Portal").build();
        project.setId(1L);
        Employee assignee = Employee.builder().firstName("Jane").build();
        assignee.setId(10L);
        Task entity = Task.builder().title("Setup CI").build();
        Task saved = Task.builder().title("Setup CI").build();
        saved.setId(20L);
        TaskResponse response = TaskResponse.builder().id(20L).title("Setup CI").build();

        when(projectRepository.findById(1L)).thenReturn(Optional.of(project));
        when(employeeRepository.findById(10L)).thenReturn(Optional.of(assignee));
        when(taskMapper.toEntity(request, project, assignee)).thenReturn(entity);
        when(taskRepository.save(entity)).thenReturn(saved);
        when(taskMapper.toResponse(saved)).thenReturn(response);

        TaskResponse result = taskService.create(request);

        assertThat(result.getTitle()).isEqualTo("Setup CI");
        verify(taskRepository).save(entity);
    }

    @Test
    void create_shouldThrowWhenProjectNotFound() {
        TaskRequest request = buildRequest();
        when(projectRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> taskService.create(request))
                .isInstanceOf(ResourceNotFoundException.class);
        verify(taskRepository, never()).save(any());
    }

    @Test
    void getById_shouldThrowWhenNotFound() {
        when(taskRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> taskService.getById(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void getAll_shouldReturnPaginatedResults() {
        Task task = Task.builder().title("Setup CI").build();
        task.setId(1L);
        TaskResponse response = TaskResponse.builder().id(1L).title("Setup CI").build();
        Page<Task> page = new PageImpl<>(List.of(task));

        when(taskRepository.findWithFilters(
                eq(1L), isNull(), eq(TaskStatus.TODO), isNull(), isNull(), eq(PageRequest.of(0, 10))))
                .thenReturn(page);
        when(taskMapper.toResponse(task)).thenReturn(response);

        Page<TaskResponse> result = taskService.getAll(
                1L, null, TaskStatus.TODO, null, null, PageRequest.of(0, 10));

        assertThat(result.getContent()).hasSize(1);
    }

    @Test
    void update_shouldReturnUpdatedTask() {
        TaskRequest request = buildRequest();
        request.setTitle("Setup CI pipeline");
        Project project = Project.builder().name("Portal").build();
        project.setId(1L);
        Employee assignee = Employee.builder().firstName("Jane").build();
        assignee.setId(10L);
        Task existing = Task.builder().title("Setup CI").build();
        existing.setId(20L);
        TaskResponse response = TaskResponse.builder().id(20L).title("Setup CI pipeline").build();

        when(taskRepository.findById(20L)).thenReturn(Optional.of(existing));
        when(projectRepository.findById(1L)).thenReturn(Optional.of(project));
        when(employeeRepository.findById(10L)).thenReturn(Optional.of(assignee));
        when(taskMapper.toResponse(existing)).thenReturn(response);

        TaskResponse result = taskService.update(20L, request);

        assertThat(result.getTitle()).isEqualTo("Setup CI pipeline");
        verify(taskMapper).updateEntity(existing, request, project, assignee);
    }

    @Test
    void delete_shouldRemoveTask() {
        Task task = Task.builder().title("Setup CI").build();
        task.setId(20L);
        when(taskRepository.findById(20L)).thenReturn(Optional.of(task));

        taskService.delete(20L);

        verify(taskRepository).delete(task);
    }

    private TaskRequest buildRequest() {
        TaskRequest request = new TaskRequest();
        request.setTitle("Setup CI");
        request.setProjectId(1L);
        request.setAssigneeId(10L);
        request.setStatus(TaskStatus.TODO);
        request.setPriority(TaskPriority.MEDIUM);
        return request;
    }
}
