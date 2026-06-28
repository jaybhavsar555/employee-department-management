package com.learning.employeedept.dto.response;

import com.learning.employeedept.entity.ProjectStatus;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class ProjectResponse {

    private final Long id;
    private final String name;
    private final String description;
    private final ProjectStatus status;
    private final LocalDate startDate;
    private final LocalDate endDate;
    private final Long departmentId;
    private final String departmentName;
    private final Long leadEmployeeId;
    private final String leadEmployeeName;
    private final int taskCount;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
}
