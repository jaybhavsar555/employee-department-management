package com.learning.employeedept.mapper;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import com.learning.employeedept.entity.Department;
import org.springframework.stereotype.Component;

@Component
public class DepartmentMapper {

    public Department toEntity(DepartmentRequest request) {
        return Department.builder()
                .name(request.getName().trim())
                .description(request.getDescription())
                .build();
    }

    public void updateEntity(Department department, DepartmentRequest request) {
        department.setName(request.getName().trim());
        department.setDescription(request.getDescription());
    }

    public DepartmentResponse toResponse(Department department) {
        return DepartmentResponse.builder()
                .id(department.getId())
                .name(department.getName())
                .description(department.getDescription())
                .employeeCount(department.getEmployees() != null ? department.getEmployees().size() : 0)
                .createdAt(department.getCreatedAt())
                .updatedAt(department.getUpdatedAt())
                .build();
    }
}
