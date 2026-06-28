package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import com.learning.employeedept.entity.Department;
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

import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

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

        DepartmentResponse result = departmentService.create(request);

        assertThat(result.getName()).isEqualTo("Engineering");
        verify(departmentRepository).save(entity);
    }

    @Test
    void create_shouldThrowWhenDepartmentExists() {
        DepartmentRequest request = new DepartmentRequest();
        request.setName("Engineering");

        when(departmentRepository.existsByNameIgnoreCase("Engineering")).thenReturn(true);

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
}