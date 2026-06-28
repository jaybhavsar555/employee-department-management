package com.learning.employeedept.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.OneToMany;
import jakarta.persistence.Table;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

import java.util.ArrayList;
import java.util.List;

/**
 * Organizational unit. One department has many employees and projects.
 * Relationship: Department 1 ──→ N Employee, Department 1 ──→ N Project
 */
@Entity
@Table(name = "departments")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Department extends BaseEntity {

    @Column(nullable = false, unique = true, length = 100) // Department names must be unique globally
    private String name;

    @Column(length = 500) // Optional description
    private String description;

    @OneToMany(mappedBy = "department") // Inverse side — Employee.department owns the FK
    @Builder.Default
    private List<Employee> employees = new ArrayList<>();

    @OneToMany(mappedBy = "department") // All projects belonging to this department
    @Builder.Default
    private List<Project> projects = new ArrayList<>();
}
