package com.learning.employeedept.entity;

import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.EnumType;
import jakarta.persistence.Enumerated;
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
 * Authorization role (e.g. ROLE_ADMIN).
 * Relationship: Role 1 ──→ N User
 */
@Entity // JPA entity — maps to a database table
@Table(name = "roles") // Explicit table name (matches schema.sql)
@Getter // Lombok: generates getters
@Setter // Lombok: generates setters
@NoArgsConstructor // JPA requires a no-arg constructor
@AllArgsConstructor // Lombok: constructor with all fields
@Builder // Lombok: fluent object builder (used in seed data)
public class Role extends BaseEntity {

    @Enumerated(EnumType.STRING) // Store enum as "ROLE_ADMIN", not as number 0/1
    @Column(nullable = false, unique = true, length = 20) // NOT NULL + UNIQUE constraint
    private RoleName name;

    @OneToMany(mappedBy = "role") // Inverse side: User owns the FK (role_id)
    @Builder.Default
    private List<User> users = new ArrayList<>();
}
