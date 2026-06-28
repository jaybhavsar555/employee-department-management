package com.learning.employeedept.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * HR record for staff. Belongs to exactly one department.
 * Can optionally lead projects and be assigned tasks.
 * Relationship: Department 1 ──→ N Employee, Employee 1 ──→ N Project (as lead), Employee 1 ──→ N Task (as assignee)
 */
@Entity
@Table(name = "employees")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Employee extends BaseEntity {

    @Column(nullable = false, length = 50)
    private String firstName;

    @Column(nullable = false, length = 50)
    private String lastName;

    @Column(nullable = false, unique = true, length = 100) // Business email — unique across company
    private String email;

    @Column(nullable = false, precision = 10, scale = 2) // NUMERIC(10,2) — money type, not float
    private BigDecimal salary;

    @Column(nullable = false) // DATE column — no time component
    private LocalDate hireDate;

    @ManyToOne(fetch = FetchType.LAZY, optional = false) // LAZY: load department only when accessed (performance)
    @JoinColumn(name = "department_id", nullable = false) // FK → departments.id
    private Department department;

    @OneToMany(mappedBy = "lead") // Projects where this employee is project manager (optional role)
    @Builder.Default
    private List<Project> leadProjects = new ArrayList<>();

    @OneToMany(mappedBy = "assignee") // Tasks assigned to this employee
    @Builder.Default
    private List<Task> assignedTasks = new ArrayList<>();
}
