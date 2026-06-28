package com.learning.employeedept.service;

import com.learning.employeedept.dto.response.ActivityItemResponse;
import com.learning.employeedept.dto.response.ActivityType;
import com.learning.employeedept.dto.response.DashboardStatsResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.Task;
import com.learning.employeedept.entity.TaskStatus;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.repository.ProjectRepository;
import com.learning.employeedept.repository.TaskRepository;
import com.learning.employeedept.service.impl.DashboardServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;

import java.time.LocalDateTime;
import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class DashboardServiceTest {

    @Mock
    private DepartmentRepository departmentRepository;

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private TaskRepository taskRepository;

    @InjectMocks
    private DashboardServiceImpl dashboardService;

    @Test
    void getStats_shouldReturnCounts() {
        when(departmentRepository.count()).thenReturn(2L);
        when(employeeRepository.count()).thenReturn(10L);
        when(projectRepository.count()).thenReturn(3L);
        when(taskRepository.count()).thenReturn(15L);
        when(taskRepository.countByStatusNotIn(any())).thenReturn(8L);
        when(taskRepository.countByStatus(TaskStatus.DONE)).thenReturn(5L);

        DashboardStatsResponse stats = dashboardService.getStats();

        assertThat(stats.getDepartments()).isEqualTo(2L);
        assertThat(stats.getEmployees()).isEqualTo(10L);
        assertThat(stats.getProjects()).isEqualTo(3L);
        assertThat(stats.getTasks()).isEqualTo(15L);
        assertThat(stats.getPendingTasks()).isEqualTo(8L);
        assertThat(stats.getCompletedTasks()).isEqualTo(5L);
    }

    @Test
    void getRecentActivity_shouldSortAndLimitResults() {
        LocalDateTime oldest = LocalDateTime.of(2026, 1, 1, 10, 0);
        LocalDateTime middle = LocalDateTime.of(2026, 3, 1, 10, 0);
        LocalDateTime newest = LocalDateTime.of(2026, 6, 1, 10, 0);

        Department department = department(1L, "Engineering", oldest);
        Employee employee = employee(2L, "Jane", "Doe", newest);
        Project project = project(3L, "Portal", middle);
        Task task = task(4L, "Setup CI", TaskStatus.TODO, middle);

        when(departmentRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(department)));
        when(employeeRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(employee)));
        when(projectRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(project)));
        when(taskRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(task)));

        List<ActivityItemResponse> activity = dashboardService.getRecentActivity(2);

        assertThat(activity).hasSize(2);
        assertThat(activity.get(0).getTimestamp()).isEqualTo(newest);
        assertThat(activity.get(1).getTimestamp()).isEqualTo(middle);
    }

    @Test
    void getRecentActivity_shouldMarkCreatedAndCompletedEvents() {
        LocalDateTime timestamp = LocalDateTime.of(2026, 6, 1, 10, 0);

        Department created = department(1L, "Engineering", timestamp);
        created.setUpdatedAt(timestamp);

        Task completed = task(2L, "Deploy", TaskStatus.DONE, timestamp);
        completed.setCreatedAt(timestamp.minusDays(1));
        completed.setUpdatedAt(timestamp);

        when(departmentRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(created)));
        when(employeeRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of()));
        when(projectRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of()));
        when(taskRepository.findAll(any(Pageable.class)))
                .thenReturn(new PageImpl<>(List.of(completed)));

        List<ActivityItemResponse> activity = dashboardService.getRecentActivity(5);

        assertThat(activity).extracting(ActivityItemResponse::getType)
                .containsExactlyInAnyOrder(
                        ActivityType.DEPARTMENT_CREATED,
                        ActivityType.TASK_COMPLETED);
    }

    private Department department(Long id, String name, LocalDateTime timestamp) {
        Department department = Department.builder().name(name).build();
        department.setId(id);
        department.setCreatedAt(timestamp);
        department.setUpdatedAt(timestamp);
        return department;
    }

    private Employee employee(Long id, String firstName, String lastName, LocalDateTime timestamp) {
        Employee employee = Employee.builder().firstName(firstName).lastName(lastName).build();
        employee.setId(id);
        employee.setCreatedAt(timestamp.minusDays(1));
        employee.setUpdatedAt(timestamp);
        return employee;
    }

    private Project project(Long id, String name, LocalDateTime timestamp) {
        Project project = Project.builder().name(name).build();
        project.setId(id);
        project.setCreatedAt(timestamp.minusDays(1));
        project.setUpdatedAt(timestamp);
        return project;
    }

    private Task task(Long id, String title, TaskStatus status, LocalDateTime timestamp) {
        Task task = Task.builder().title(title).status(status).build();
        task.setId(id);
        task.setCreatedAt(timestamp.minusDays(1));
        task.setUpdatedAt(timestamp);
        return task;
    }
}
