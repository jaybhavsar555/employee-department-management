package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.exception.BadRequestException;
import com.learning.employeedept.exception.DuplicateResourceException;
import com.learning.employeedept.exception.ResourceNotFoundException;
import com.learning.employeedept.mapper.DepartmentMapper;
import com.learning.employeedept.repository.DepartmentRepository;
import com.learning.employeedept.service.DepartmentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Department business logic implementation.
 * <p>
 * SOLID — <b>Single Responsibility</b>: only department rules live here.
 * <b>Open/Closed</b>: extend via new service methods without changing controllers.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepository departmentRepository;
    private final DepartmentMapper departmentMapper;

    @Override
    @Transactional
    public DepartmentResponse create(DepartmentRequest request) {
        validateUniqueName(request.getName(), null);

        Department department = departmentMapper.toEntity(request);
        Department saved = departmentRepository.save(department);
        log.info("Created department id={} name={}", saved.getId(), saved.getName());
        return departmentMapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public DepartmentResponse getById(Long id) {
        Department department = findDepartment(id);
        return departmentMapper.toResponse(department);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<DepartmentResponse> getAll(String search, Pageable pageable) {
        log.debug("Fetching departments page={} size={} search={}",
                pageable.getPageNumber(), pageable.getPageSize(), search);
        return departmentRepository.findWithFilters(search, pageable)
                .map(departmentMapper::toResponse);
    }

    @Override
    @Transactional
    public DepartmentResponse update(Long id, DepartmentRequest request) {
        Department department = findDepartment(id);
        validateUniqueName(request.getName(), id);

        departmentMapper.updateEntity(department, request);
        log.info("Updated department id={}", id);
        return departmentMapper.toResponse(department);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Department department = findDepartment(id);
        if (!department.getEmployees().isEmpty()) {
            throw new BadRequestException("Cannot delete department with assigned employees");
        }
        departmentRepository.delete(department);
        log.info("Deleted department id={}", id);
    }

    private Department findDepartment(Long id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with id: " + id));
    }

    private void validateUniqueName(String name, Long currentId) {
        boolean exists = currentId == null
                ? departmentRepository.existsByNameIgnoreCase(name)
                : departmentRepository.existsByNameIgnoreCaseAndIdNot(name, currentId);

        if (exists) {
            throw new DuplicateResourceException("Department already exists: " + name);
        }
    }
}
