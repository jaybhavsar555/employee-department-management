package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.exception.BadRequestException;
import com.learning.employeedept.exception.DuplicateResourceException;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.DepartmentMapper;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.service.impl.DepartmentServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;

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

/**
 * Unit tests for {@link DepartmentServiceImpl}.
 * <p>
 * <b>Mocking</b>: dependencies ({@link DepartmentRepository}, {@link DepartmentMapper}) are replaced
 * with Mockito mocks so we test business logic in isolation — no database required.
 * <p>
 * <b>Arrange–Act–Assert (AAA)</b>:
 * <ol>
 *   <li><b>Arrange</b> — set up mocks and input data</li>
 *   <li><b>Act</b> — call the method under test</li>
 *   <li><b>Assert</b> — verify outcome and mock interactions</li>
 * </ol>
 */
@ExtendWith(MockitoExtension.class)
class DepartmentServiceTest {

    @Mock
    private DepartmentRepository departmentRepository;

    @Mock
    private DepartmentMapper departmentMapper;

    @InjectMocks
    private DepartmentServiceImpl departmentService;

    @Test
    void create_shouldReturnDepartmentResponse() {
        // Arrange
        DepartmentRequest request = new DepartmentRequest();
        request.setName("Engineering");
        request.setDescription("Software team");

        Department entity = Department.builder().name("Engineering").description("Software team").build();
        Department saved = Department.builder().name("Engineering").description("Software team").build();
        saved.setId(1L);
        DepartmentResponse response = DepartmentResponse.builder()
                .id(1L)
                .name("Engineering")
                .description("Software team")
                .employeeCount(0)
                .build();

        when(departmentRepository.existsByNameIgnoreCase("Engineering")).thenReturn(false);
        when(departmentMapper.toEntity(request)).thenReturn(entity);
        when(departmentRepository.save(entity)).thenReturn(saved);
        when(departmentMapper.toResponse(saved)).thenReturn(response);

        // Act
        DepartmentResponse result = departmentService.create(request);

        // Assert
        assertThat(result.getName()).isEqualTo("Engineering");
        verify(departmentRepository).save(entity);
    }

    @Test
    void create_shouldThrowWhenDepartmentExists() {
        // Arrange
        DepartmentRequest request = new DepartmentRequest();
        request.setName("Engineering");
        when(departmentRepository.existsByNameIgnoreCase("Engineering")).thenReturn(true);

        // Act & Assert
        assertThatThrownBy(() -> departmentService.create(request))
                .isInstanceOf(DuplicateResourceException.class);
        verify(departmentRepository, never()).save(any());
    }

    @Test
    void getById_shouldThrowWhenNotFound() {
        when(departmentRepository.findById(99L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> departmentService.getById(99L))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void getAll_shouldReturnPaginatedResults() {
        // Arrange
        Pageable pageable = PageRequest.of(0, 10);
        Department dept = Department.builder().name("HR").build();
        dept.setId(1L);
        DepartmentResponse response = DepartmentResponse.builder().id(1L).name("HR").build();
        Page<Department> page = new PageImpl<>(List.of(dept));

        when(departmentRepository.findWithFilters(isNull(), eq(pageable))).thenReturn(page);
        when(departmentMapper.toResponse(dept)).thenReturn(response);

        // Act
        Page<DepartmentResponse> result = departmentService.getAll(null, pageable);

        // Assert
        assertThat(result.getContent()).hasSize(1);
        assertThat(result.getContent().get(0).getName()).isEqualTo("HR");
    }

    @Test
    void update_shouldReturnUpdatedDepartment() {
        DepartmentRequest request = new DepartmentRequest();
        request.setName("HR Updated");

        Department existing = Department.builder().name("HR").build();
        existing.setId(1L);
        DepartmentResponse response = DepartmentResponse.builder().id(1L).name("HR Updated").build();

        when(departmentRepository.findById(1L)).thenReturn(Optional.of(existing));
        when(departmentRepository.existsByNameIgnoreCaseAndIdNot("HR Updated", 1L)).thenReturn(false);
        when(departmentMapper.toResponse(existing)).thenReturn(response);

        DepartmentResponse result = departmentService.update(1L, request);

        assertThat(result.getName()).isEqualTo("HR Updated");
    }

    @Test
    void delete_shouldThrowWhenDepartmentHasEmployees() {
        Department dept = Department.builder().name("Engineering").build();
        dept.setId(1L);
        dept.getEmployees().add(new com.learning.employeedept.entity.Employee());

        when(departmentRepository.findById(1L)).thenReturn(Optional.of(dept));

        assertThatThrownBy(() -> departmentService.delete(1L))
                .isInstanceOf(BadRequestException.class);
        verify(departmentRepository, never()).delete(any());
    }
}
