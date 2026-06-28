package com.learning.employeedept.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
import jakarta.persistence.FetchType;
import jakarta.persistence.JoinColumn;
import jakarta.persistence.ManyToOne;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import jakarta.persistence.UniqueConstraint;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

/**
 * Department-scoped initiative. Optionally led by one employee.
 * Relationship: Department 1 ──→ N Project, Employee 1 ──→ N Project (as lead), Project 1 ──→ N Task
 */
@Entity
@Table(
        name = "projects",
        uniqueConstraints = @UniqueConstraint(
                name = "uq_projects_name_per_department",
                columnNames = {"department_id", "name"} // Same project name allowed in different departments
        )
)
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Project extends BaseEntity {

    @Column(nullable = false, length = 150)
    private String name;

    @Column(columnDefinition = "TEXT") // Large free-text field
    private String description;

    @Enumerated(EnumType.STRING) // Stored as "ACTIVE", "PLANNED", etc.
    @Column(nullable = false, length = 20)
    @Builder.Default
    private ProjectStatus status = ProjectStatus.PLANNED;

    @Column
    private LocalDate startDate;

    @Column
    private LocalDate endDate;

    @ManyToOne(fetch = FetchType.LAZY, optional = false) // Every project belongs to one department
    @JoinColumn(name = "department_id", nullable = false)
    private Department department;

    @ManyToOne(fetch = FetchType.LAZY) // Optional project lead — nullable FK
    @JoinColumn(name = "lead_employee_id") // ON DELETE SET NULL in DB when lead is removed
    private Employee lead;

    @OneToMany(mappedBy = "project") // Tasks inside this project — cascade delete handled at DB level
    @Builder.Default
    private List<Task> tasks = new ArrayList<>();
}
