package com.learning.employeedept.service.impl;

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
import com.learning.employeedept.service.ProjectService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j
@Service
@RequiredArgsConstructor
public class ProjectServiceImpl implements ProjectService {

    private final ProjectRepository projectRepository;
    private final DepartmentRepository departmentRepository;
    private final EmployeeRepository employeeRepository;
    private final ProjectMapper projectMapper;

    @Override
    @Transactional
    public ProjectResponse create(ProjectRequest request) {
        validateUniqueName(request.getName(), request.getDepartmentId(), null);
        validateDateRange(request);
        Department department = findDepartment(request.getDepartmentId());
        Employee lead = findLead(request.getLeadEmployeeId(), department);

        Project project = projectMapper.toEntity(request, department, lead);
        Project saved = projectRepository.save(project);
        log.info("Created project id={} name={}", saved.getId(), saved.getName());
        return projectMapper.toResponse(saved);
    }

    @Override
    @Transactional(readOnly = true)
    public ProjectResponse getById(Long id) {
        Project project = findProject(id);
        return projectMapper.toResponse(project);
    }

    @Override
    @Transactional(readOnly = true)
    public Page<ProjectResponse> getAll(Long departmentId, ProjectStatus status, String search, Pageable pageable) {
        log.debug("Fetching projects page={} departmentId={} status={} search={}",
                pageable.getPageNumber(), departmentId, status, search);
        return projectRepository.findWithFilters(departmentId, status, search, pageable)
                .map(projectMapper::toResponse);
    }

    @Override
    @Transactional
    public ProjectResponse update(Long id, ProjectRequest request) {
        Project project = findProject(id);
        validateUniqueName(request.getName(), request.getDepartmentId(), id);
        validateDateRange(request);
        Department department = findDepartment(request.getDepartmentId());
        Employee lead = findLead(request.getLeadEmployeeId(), department);

        projectMapper.updateEntity(project, request, department, lead);
        log.info("Updated project id={}", id);
        return projectMapper.toResponse(project);
    }

    @Override
    @Transactional
    public void delete(Long id) {
        Project project = findProject(id);
        projectRepository.delete(project);
        log.info("Deleted project id={}", id);
    }

    private Project findProject(Long id) {
        return projectRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Project not found with id: " + id));
    }

    private Department findDepartment(Long id) {
        return departmentRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Department not found with id: " + id));
    }

    private Employee findLead(Long leadEmployeeId, Department department) {
        if (leadEmployeeId == null) {
            return null;
        }
        Employee lead = employeeRepository.findById(leadEmployeeId)
                .orElseThrow(() -> new ResourceNotFoundException("Employee not found with id: " + leadEmployeeId));
        if (!lead.getDepartment().getId().equals(department.getId())) {
            throw new BadRequestException("Project lead must belong to the project's department");
        }
        return lead;
    }

    private void validateUniqueName(String name, Long departmentId, Long currentProjectId) {
        boolean exists = currentProjectId == null
                ? projectRepository.existsByNameIgnoreCaseAndDepartmentId(name, departmentId)
                : projectRepository.existsByNameIgnoreCaseAndDepartmentIdAndIdNot(name, departmentId, currentProjectId);

        if (exists) {
            throw new DuplicateResourceException("Project already exists in this department: " + name);
        }
    }

    private void validateDateRange(ProjectRequest request) {
        if (request.getStartDate() != null && request.getEndDate() != null
                && request.getStartDate().isAfter(request.getEndDate())) {
            throw new BadRequestException("Project start date must be on or before end date");
        }
    }
}
