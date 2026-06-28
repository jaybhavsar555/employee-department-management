package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.EmployeeRequest;
import com.learning.employeedept.dto.response.EmployeeResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.exception.DuplicateEmailException;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.EmployeeMapper;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.service.impl.EmployeeServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.PageRequest;

import java.math.BigDecimal;
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
class EmployeeServiceTest {

    @Mock
    private EmployeeRepository employeeRepository;

    @Mock
    private DepartmentRepository departmentRepository;

    @Mock
    private EmployeeMapper employeeMapper;

    @InjectMocks
    private EmployeeServiceImpl employeeService;

    @Test
    void create_shouldReturnEmployeeResponse() {
        // Arrange
        EmployeeRequest request = buildRequest();
        Department department = Department.builder().name("Engineering").build();
        department.setId(1L);
        Employee entity = Employee.builder().firstName("Jane").lastName("Doe").build();
        Employee saved = Employee.builder().firstName("Jane").lastName("Doe").build();
        saved.setId(10L);
        EmployeeResponse response = EmployeeResponse.builder().id(10L).firstName("Jane").build();

        when(employeeRepository.existsByEmailIgnoreCase("jane@company.com")).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(employeeMapper.toEntity(request, department)).thenReturn(entity);
        when(employeeRepository.save(entity)).thenReturn(saved);
        when(employeeMapper.toResponse(saved)).thenReturn(response);

        // Act
        EmployeeResponse result = employeeService.create(request);

        // Assert
        assertThat(result.getId()).isEqualTo(10L);
        verify(employeeRepository).save(entity);
    }

    @Test
    void create_shouldThrowDuplicateEmailException() {
        EmployeeRequest request = buildRequest();
        when(employeeRepository.existsByEmailIgnoreCase("jane@company.com")).thenReturn(true);

        assertThatThrownBy(() -> employeeService.create(request))
                .isInstanceOf(DuplicateEmailException.class);
        verify(employeeRepository, never()).save(any());
    }

    @Test
    void create_shouldThrowWhenDepartmentNotFound() {
        EmployeeRequest request = buildRequest();
        when(employeeRepository.existsByEmailIgnoreCase("jane@company.com")).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.empty());

        assertThatThrownBy(() -> employeeService.create(request))
                .isInstanceOf(ResourceNotFoundException.class);
    }

    @Test
    void getAll_shouldReturnPaginatedEmployees() {
        Page<Employee> page = new PageImpl<>(List.of(new Employee()));
        EmployeeResponse response = EmployeeResponse.builder().id(1L).build();

        when(employeeRepository.findWithFilters(isNull(), isNull(), eq(PageRequest.of(0, 10))))
                .thenReturn(page);
        when(employeeMapper.toResponse(any(Employee.class))).thenReturn(response);

        Page<EmployeeResponse> result = employeeService.getAll(null, null, PageRequest.of(0, 10));

        assertThat(result.getContent()).hasSize(1);
    }

    @Test
    void update_shouldUpdateEmployee() {
        EmployeeRequest request = buildRequest();
        Department department = Department.builder().name("Engineering").build();
        department.setId(1L);
        Employee employee = Employee.builder().email("old@company.com").build();
        employee.setId(10L);
        EmployeeResponse response = EmployeeResponse.builder().id(10L).firstName("Jane").build();

        when(employeeRepository.findById(10L)).thenReturn(Optional.of(employee));
        when(employeeRepository.existsByEmailIgnoreCaseAndIdNot("jane@company.com", 10L)).thenReturn(false);
        when(departmentRepository.findById(1L)).thenReturn(Optional.of(department));
        when(employeeMapper.toResponse(employee)).thenReturn(response);

        EmployeeResponse result = employeeService.update(10L, request);

        assertThat(result.getId()).isEqualTo(10L);
        verify(employeeMapper).updateEntity(employee, request, department);
    }

    @Test
    void delete_shouldRemoveEmployee() {
        Employee employee = Employee.builder().email("jane@company.com").build();
        employee.setId(5L);
        when(employeeRepository.findById(5L)).thenReturn(Optional.of(employee));

        employeeService.delete(5L);

        verify(employeeRepository).delete(employee);
    }

    private EmployeeRequest buildRequest() {
        EmployeeRequest request = new EmployeeRequest();
        request.setFirstName("Jane");
        request.setLastName("Doe");
        request.setEmail("jane@company.com");
        request.setSalary(new BigDecimal("75000"));
        request.setHireDate(LocalDate.of(2024, 1, 15));
        request.setDepartmentId(1L);
        return request;
    }
}
