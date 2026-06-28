package com.learning.employeedept.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class DepartmentResponse {

    private final Long id;
    private final String name;
    private final String description;
    private final int employeeCount;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
}
