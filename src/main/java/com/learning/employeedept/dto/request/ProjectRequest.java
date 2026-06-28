package com.learning.employeedept.dto.request;

import com.learning.employeedept.entity.ProjectStatus;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.time.LocalDate;

@Getter
@Setter
public class ProjectRequest {

    @NotBlank
    @Size(max = 150)
    private String name;

    @Size(max = 2000)
    private String description;

    private ProjectStatus status;

    private LocalDate startDate;

    private LocalDate endDate;

    @NotNull
    private Long departmentId;

    private Long leadEmployeeId;
}
