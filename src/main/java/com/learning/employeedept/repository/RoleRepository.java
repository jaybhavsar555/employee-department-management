package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Role;
import com.learning.employeedept.entity.RoleName;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * Spring Data JPA repository for {@link Role}.
 * Small lookup table — mostly used at registration and seed-data startup.
 */
public interface RoleRepository extends JpaRepository<Role, Long> {

    /**
     * Derived query: find role by enum name ({@code ROLE_ADMIN}, {@code ROLE_USER}).
     * Used in {@code DataInitializer} and registration to assign default role.
     */
    Optional<Role> findByName(RoleName name);

    /**
     * Derived query: quick check if role exists before insert (seed data idempotency).
     */
    boolean existsByName(RoleName name);
}
