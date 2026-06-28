package com.learning.employeedept.repository;

import com.learning.employeedept.entity.RoleName;
import com.learning.employeedept.entity.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

/**
 * Spring Data JPA repository for {@link User} (API authentication accounts).
 */
public interface UserRepository extends JpaRepository<User, Long> {

    /**
     * Derived query: load user for login ({@code AuthenticationManager} / JWT).
     * Matches username exactly — case-sensitive.
     */
    Optional<User> findByUsername(String username);

    /**
     * Derived query: find by email (password reset, duplicate check).
     */
    Optional<User> findByEmail(String email);

    /**
     * Derived query: prevent duplicate username on registration.
     */
    boolean existsByUsername(String username);

    /**
     * Derived query: prevent duplicate email on registration.
     */
    boolean existsByEmail(String email);

    /**
     * Derived query: same as {@link #existsByUsername} but excludes current user on profile update.
     */
    boolean existsByUsernameAndIdNot(String username, Long id);

    /**
     * Derived query: same as {@link #existsByEmail} but excludes current user on profile update.
     */
    boolean existsByEmailAndIdNot(String email, Long id);

    /**
     * Derived query: paginated users filtered by role.
     * Navigates {@code user.role.name} relationship path.
     * Example: list all admins — {@code findByRoleName(ROLE_ADMIN, pageable)}.
     */
    Page<User> findByRoleName(RoleName roleName, Pageable pageable);

    /**
     * Count users with a given role — useful for admin dashboard metrics.
     */
    long countByRoleName(RoleName roleName);
}
