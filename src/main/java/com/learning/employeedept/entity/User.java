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

import java.util.ArrayList;
import java.util.List;

/**
 * API login account (authentication). Separate from {@link Employee} (HR data).
 * Relationship: Role 1 ──→ N User, User 1 ──→ N Task (as creator)
 */
@Entity
@Table(name = "users") // "users" is a reserved word in SQL — quoted by Hibernate if needed
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class User extends BaseEntity {

    @Column(nullable = false, unique = true, length = 50) // Login username — indexed for fast lookup
    private String username;

    @Column(nullable = false, unique = true, length = 100) // Unique email per user
    private String email;

    @Column(nullable = false) // BCrypt hash — never store plain text
    private String password;

    @ManyToOne(fetch = FetchType.EAGER, optional = false) // Every user must have a role; load role with user (for JWT)
    @JoinColumn(name = "role_id", nullable = false) // FK column in users table → roles.id
    private Role role;

    @OneToMany(mappedBy = "createdBy") // Tasks this user created (audit trail)
    @Builder.Default
    private List<Task> createdTasks = new ArrayList<>();
}
