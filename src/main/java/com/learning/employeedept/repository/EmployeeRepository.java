package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

/**
 * Spring Data JPA repository for {@link Employee}.
 * <p>
 * Demonstrates three query styles:
 * <ol>
 *   <li><b>Derived query methods</b> — Spring parses method name into SQL</li>
 *   <li><b>{@code @Query} JPQL</b> — custom logic with optional filters</li>
 *   <li><b>{@link Pageable}</b> — pagination + sorting for list endpoints</li>
 * </ol>
 */
public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    /**
     * Derived query: check email uniqueness on create (case-insensitive).
     * {@code WHERE LOWER(email) = LOWER(?)}.
     */
    boolean existsByEmailIgnoreCase(String email);

    /**
     * Derived query: check email uniqueness on update — ignores the employee being edited.
     * {@code WHERE LOWER(email) = LOWER(?) AND id <> ?}.
     */
    boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);

    /**
     * Derived query: all employees in one department (non-paginated).
     * Navigates relationship: {@code employee.department.id}.
     */
    List<Employee> findByDepartmentId(Long departmentId);

    /**
     * Derived query: paginated employees in one department, sorted via {@link Pageable}.
     * Example: {@code findByDepartmentId(1L, PageRequest.of(0, 10, Sort.by("lastName")))}.
     */
    Page<Employee> findByDepartmentId(Long departmentId, Pageable pageable);

    /**
     * Derived query: find by exact email (login/lookup scenarios).
     */
    Optional<Employee> findByEmailIgnoreCase(String email);

    /**
     * Custom JPQL with optional filters — powers {@code GET /employees?page&size&sort&departmentId&search}.
     * <ul>
     *   <li>{@code departmentId} null → no department filter</li>
     *   <li>{@code search} null/empty → no name/email filter</li>
     *   <li>{@code pageable} → LIMIT/OFFSET + ORDER BY from Spring Data</li>
     * </ul>
     */
    @Query("""
            SELECT e FROM Employee e
            WHERE (:departmentId IS NULL OR e.department.id = :departmentId)
              AND (:search IS NULL OR :search = ''
                   OR LOWER(e.firstName) LIKE LOWER(CONCAT('%', :search, '%'))
                   OR LOWER(e.lastName) LIKE LOWER(CONCAT('%', :search, '%'))
                   OR LOWER(e.email) LIKE LOWER(CONCAT('%', :search, '%')))
            """)
    Page<Employee> findWithFilters(@Param("departmentId") Long departmentId,
                                   @Param("search") String search,
                                   Pageable pageable);

    /**
     * Count employees assigned to a department — useful for dashboard stats.
     */
    long countByDepartmentId(Long departmentId);
}
