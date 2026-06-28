package com.learning.employeedept.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Getter
@Builder
@AllArgsConstructor
public class EmployeeResponse {

    private final Long id;
    private final String firstName;
    private final String lastName;
    private final String email;
    private final BigDecimal salary;
    private final LocalDate hireDate;
    private final Long departmentId;
    private final String departmentName;
    private final LocalDateTime createdAt;
    private final LocalDateTime updatedAt;
}
