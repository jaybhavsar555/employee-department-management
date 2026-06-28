package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Department;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/**
 * Spring Data JPA repository for {@link Department}.
 * <p>
 * Inherited from {@link JpaRepository} (no code needed):
 * <ul>
 *   <li>{@code save(entity)} — insert or update</li>
 *   <li>{@code findById(id)} — find by primary key</li>
 *   <li>{@code findAll()} — list all rows</li>
 *   <li>{@code delete(entity)} / {@code deleteById(id)} — remove row</li>
 *   <li>{@code count()} — total row count</li>
 * </ul>
 */
public interface DepartmentRepository extends JpaRepository<Department, Long> {

    /**
     * Derived query: {@code SELECT * FROM departments WHERE LOWER(name) = LOWER(?)}.
     * Used on update to detect duplicate department names.
     */
    Optional<Department> findByNameIgnoreCase(String name);

    /**
     * Derived query: returns {@code true} if any department has this name (case-insensitive).
     * Used before create to prevent duplicates — throws 409 in service layer.
     */
    boolean existsByNameIgnoreCase(String name);

    /**
     * Derived query: same as {@link #existsByNameIgnoreCase} but excludes the current row.
     * Useful on update: "does another department already use this name?"
     */
    boolean existsByNameIgnoreCaseAndIdNot(String name, Long id);

    /**
     * Paginated list sorted by name (sort direction comes from {@link Pageable}).
     * Example: {@code PageRequest.of(0, 10, Sort.by("name"))}.
     * Returns {@link Page} with content + totalElements + totalPages for API responses.
     */
    Page<Department> findAllByOrderByNameAsc(Pageable pageable);

    /**
     * Optional text search on name/description with pagination.
     */
    @Query("""
            SELECT d FROM Department d
            WHERE (:search IS NULL OR :search = ''
                   OR LOWER(d.name) LIKE LOWER(CONCAT('%', :search, '%'))
                   OR LOWER(d.description) LIKE LOWER(CONCAT('%', :search, '%')))
            """)
    Page<Department> findWithFilters(@Param("search") String search, Pageable pageable);

    /**
     * Count departments that have at least one employee.
     * Derived from {@code employees} OneToMany collection on Department entity.
     */
    long countByEmployeesIsNotEmpty();
}
