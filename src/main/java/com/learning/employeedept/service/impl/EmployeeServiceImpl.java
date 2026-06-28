package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.request.EmployeeRequest;
import com.learning.employeedept.dto.response.EmployeeResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.exception.DuplicateResourceException;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.EmployeeMapper;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.repository.EmployeeRepository;
import com.learning.employeedept.service.EmployeeService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class EmployeeServiceImpl implements EmployeeService {

    private final EmployeeRepository employeeRepository;
    private final DepartmentRepository departmentRepository;
    private final EmployeeMapper employeeMapper;

    @Override
    @Transactional
    public EmployeeResponse create(EmployeeRequest request) {
        validateUniqueEmail(request.getEmail(), null);
        Department department = findDepartment(request.getDepartmentId());

        Employee employee = employeeMapper.toEntity(request, department);
        Employee saved = employeeRepository.save(employee);
        log.info("Created employee id={} email={}", saved.getId(), saved.getEmail());
        return employeeMapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public EmployeeResponse getById(Long id) {
        Employee employee = findEmployee(id);
        return employeeMapper.toResponse(employee);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<EmployeeResponse> getAll(Long departmentId, String search, Pageable pageable) {
        return employeeRepository.findWithFilters(departmentId, search, pageable)
                .map(employeeMapper::toResponse);
    }

    @Override
    @Transactional
    public EmployeeResponse update(Long id, EmployeeRequest request) {
        Employee employee = findEmployee(id);
        validateUniqueEmail(request.getEmail(), id);
        Department department = findDepartment(request.getDepartmentId());

        employeeMapper.updateEntity(employee, request, department);
        log.info("Updated employee id={}", id);
        return employeeMapper.toResponse(employee);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Employee employee = findEmployee(id);
        employeeRepository.delete(employee);
        log.info("Deleted employee id={}", id);
    }

    private Employee findEmployee(Long id) {
        return employeeRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + id));
    }

    private Department findDepartment(Long id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with id: " + id));
    }

    private void validateUniqueEmail(String email, Long currentEmployeeId) {
        boolean exists = currentEmployeeId == null
                ? employeeRepository.existsByEmailIgnoreCase(email)
                : employeeRepository.existsByEmailIgnoreCaseAndIdNot(email, currentEmployeeId);

        if (exists) {
            throw new DuplicateResourceException("Employee email already exists: " + email);
        }
    }
}
