package com.learning.employeedept.mapper;

import com.learning.employeedept.dto.request.ProjectRequest;
import com.learning.employeedept.dto.response.ProjectResponse;
import com.learning.employeedept.entity.Department;
import com.learning.employeedept.entity.Employee;
import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.ProjectStatus;
import org.springframework.stereotype.Component;

@Component
public class ProjectMapper {

    public Project toEntity(ProjectRequest request, Department department, Employee lead) {
        return Project.builder()
                .name(request.getName().trim())
                .description(request.getDescription())
                .status(request.getStatus() != null ? request.getStatus() : ProjectStatus.PLANNED)
                .startDate(request.getStartDate())
                .endDate(request.getEndDate())
                .department(department)
                .lead(lead)
                .build();
    }

    public void updateEntity(Project project, ProjectRequest request, Department department, Employee lead) {
        project.setName(request.getName().trim());
        project.setDescription(request.getDescription());
        project.setStatus(request.getStatus() != null ? request.getStatus() : project.getStatus());
        project.setStartDate(request.getStartDate());
        project.setEndDate(request.getEndDate());
        project.setDepartment(department);
        project.setLead(lead);
    }

    public ProjectResponse toResponse(Project project) {
        Employee lead = project.getLead();
        return ProjectResponse.builder()
                .id(project.getId())
                .name(project.getName())
                .description(project.getDescription())
                .status(project.getStatus())
                .startDate(project.getStartDate())
                .endDate(project.getEndDate())
                .departmentId(project.getDepartment().getId())
                .departmentName(project.getDepartment().getName())
                .leadEmployeeId(lead != null ? lead.getId() : null)
                .leadEmployeeName(lead != null ? lead.getFirstName() + " " + lead.getLastName() : null)
                .taskCount(project.getTasks() != null ? project.getTasks().size() : 0)
                .createdAt(project.getCreatedAt())
                .updatedAt(project.getUpdatedAt())
                .build();
    }
}
