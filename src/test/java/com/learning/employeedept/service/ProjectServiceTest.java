package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.ProjectRequest;
import com.learning.employeedept.dto.response.ProjectResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.ProjectStatus;
import com.learning.employeedept.exception.BadRequestException;
import com.learning.employeedept.exception.DuplicateResourceException;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.ProjectMapper;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.repository.ProjectRepository;
import com.learning.employeedept.service.impl.ProjectServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.time.LocalDate;
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
class ProjectServiceTest {

    @Mock
    private ProjectRepository projectRepository;

    @Mock
    private DepartmentRepository departmentRepository;

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private ProjectMapper projectMapper;

    @InjectMocks
    private ProjectServiceImpl projectService;

    @Test
    void create_shouldReturnProjectResponse() {
        ProjectRequest request = buildRequest();
        Department department = department(1L);
        Project entity = Project.builder().name("Portal").build();
        Project saved = Project.builder().name("Portal").build();
        saved.setId(5L);
        ProjectResponse response = ProjectResponse.builder().id(5L).name("Portal").build();

        when(projectRepository.existsByNameIgnoreCaseAndDepartmentId("Portal", 1L)).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(projectMapper.toEntity(request, department, null)).thenReturn(entity);
        when(projectRepository.save(entity)).thenReturn(saved);
        when(projectMapper.toResponse(saved)).thenReturn(response);

        ProjectResponse result = projectService.create(request);

        assertThat(result.getName()).isEqualTo("Portal");
        verify(projectRepository).save(entity);
    }

    @Test
    void create_shouldThrowWhenNameExistsInDepartment() {
        ProjectRequest request = buildRequest();
        when(projectRepository.existsByNameIgnoreCaseAndDepartmentId("Portal", 1L)).thenReturn(true);

        assertThatThrownBy(() -> projectService.create(request))
                .isInstanceOf(DuplicateResourceException.class);
        verify(projectRepository, never()).save(any());
    }

    @Test
    void create_shouldThrowWhenStartDateAfterEndDate() {
        ProjectRequest request = buildRequest();
        request.setStartDate(LocalDate.of(2025, 6, 1));
        request.setEndDate(LocalDate.of(2025, 1, 1));

        assertThatThrownBy(() -> projectService.create(request))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void create_shouldThrowWhenLeadNotInDepartment() {
        ProjectRequest request = buildRequest();
        request.setLeadEmployeeId(10L);
        Department department = department(1L);
        Department otherDepartment = department(2L);
        Employee lead = Employee.builder().department(otherDepartment).build();
        lead.setId(10L);

        when(projectRepository.existsByNameIgnoreCaseAndDepartmentId("Portal", 1L)).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(employeeRepository.findById(10L)).thenReturn(Optional.of(lead));

        assertThatThrownBy(() -> projectService.create(request))
                .isInstanceOf(BadRequestException.class);
    }

    @Test
    void getById_shouldThrowWhenNotFound() {
        when(projectRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> projectService.getById(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void getAll_shouldReturnPaginatedResults() {
        Project project = Project.builder().name("Portal").build();
        project.setId(1L);
        ProjectResponse response = ProjectResponse.builder().id(1L).name("Portal").build();
        Page<Project> page = new PageImpl<>(List.of(project));

        when(projectRepository.findWithFilters(eq(1L), eq(ProjectStatus.ACTIVE), isNull(), eq(PageRequest.of(0, 10))))
                .thenReturn(page);
        when(projectMapper.toResponse(project)).thenReturn(response);

        Page<ProjectResponse> result = projectService.getAll(
                1L, ProjectStatus.ACTIVE, null, PageRequest.of(0, 10));

        assertThat(result.getContent()).hasSize(1);
    }

    @Test
    void update_shouldReturnUpdatedProject() {
        ProjectRequest request = buildRequest();
        request.setName("Portal v2");
        Department department = department(1L);
        Project existing = Project.builder().name("Portal").build();
        existing.setId(5L);
        ProjectResponse response = ProjectResponse.builder().id(5L).name("Portal v2").build();

        when(projectRepository.findById(5L)).thenReturn(Optional.of(existing));
        when(projectRepository.existsByNameIgnoreCaseAndDepartmentIdAndIdNot("Portal v2", 1L, 5L))
                .thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(projectMapper.toResponse(existing)).thenReturn(response);

        ProjectResponse result = projectService.update(5L, request);

        assertThat(result.getName()).isEqualTo("Portal v2");
        verify(projectMapper).updateEntity(existing, request, department, null);
    }

    @Test
    void delete_shouldRemoveProject() {
        Project project = Project.builder().name("Portal").build();
        project.setId(5L);
        when(projectRepository.findById(5L)).thenReturn(Optional.of(project));

        projectService.delete(5L);

        verify(projectRepository).delete(project);
    }

    private ProjectRequest buildRequest() {
        ProjectRequest request = new ProjectRequest();
        request.setName("Portal");
        request.setDepartmentId(1L);
        request.setStatus(ProjectStatus.ACTIVE);
        return request;
    }

    private Department department(Long id) {
        Department department = Department.builder().name("Engineering").build();
        department.setId(id);
        return department;
    }
}
