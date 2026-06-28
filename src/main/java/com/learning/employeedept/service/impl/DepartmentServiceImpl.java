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
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

@Slf4j
@Service
@RequiredArgsConstructor
public class DepartmentServiceImpl implements DepartmentService {

    private final DepartmentRepository departmentRepository;
    private final DepartmentMapper departmentMapper;

    @Override
    @Transactional
    public DepartmentResponse create(DepartmentRequest request) {
        if (departmentRepository.existsByNameIgnoreCase(request.getName())) {
            throw new DuplicateResourceException("Department already exists: " + request.getName());
        }

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
    public List<DepartmentResponse> getAll() {
        return departmentRepository.findAll().stream()
                .map(departmentMapper::toResponse)
                .toList();
    }

    @Override
    @Transactional
    public DepartmentResponse update(Long id, DepartmentRequest request) {
        Department department = findDepartment(id);

        departmentRepository.findByNameIgnoreCase(request.getName())
                .filter(existing -> !existing.getId().equals(id))
                .ifPresent(existing -> {
                    throw new DuplicateResourceException("Department already exists: " + request.getName());
                });

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
}
