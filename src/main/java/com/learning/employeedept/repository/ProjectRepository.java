package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Project;
import com.learning.employeedept.entity.ProjectStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.Optional;

/**
 * Spring Data JPA repository for {@link Project}.
 * Projects belong to a department and may have an optional lead employee.
 */
public interface ProjectRepository extends JpaRepository<Project, Long> {

    /**
     * Derived query: paginated projects for one department.
     * Supports {@code GET /departments/{id}/projects?page=0&size=10}.
     */
    Page<Project> findByDepartmentId(Long departmentId, Pageable pageable);

    /**
     * Derived query: filter projects by lifecycle status with pagination.
     * Example: all ACTIVE projects — {@code findByStatus(ACTIVE, pageable)}.
     */
    Page<Project> findByStatus(ProjectStatus status, Pageable pageable);

    /**
     * Derived query: combine department + status filter.
     * Example: active projects in Engineering department.
     */
    Page<Project> findByDepartmentIdAndStatus(Long departmentId, ProjectStatus status, Pageable pageable);

    /**
     * Derived query: projects where employee is the lead (project manager).
     */
    Page<Project> findByLeadId(Long leadEmployeeId, Pageable pageable);

    /**
     * Derived query: find project by name within a department (unique constraint per dept).
     */
    Optional<Project> findByNameIgnoreCaseAndDepartmentId(String name, Long departmentId);

    /**
     * Derived query: duplicate name check before create/update within same department.
     */
    boolean existsByNameIgnoreCaseAndDepartmentId(String name, Long departmentId);

    /**
     * Derived query: duplicate check on update — exclude current project id.
     */
    boolean existsByNameIgnoreCaseAndDepartmentIdAndIdNot(String name, Long departmentId, Long id);

    /**
     * Custom JPQL: optional search by project name/description + optional department/status filters.
     * {@link Pageable} adds pagination and sorting.
     */
    @Query("""
            SELECT p FROM Project p
            WHERE (:departmentId IS NULL OR p.department.id = :departmentId)
              AND (:status IS NULL OR p.status = :status)
              AND (:search IS NULL OR :search = ''
                   OR LOWER(p.name) LIKE LOWER(CONCAT('%', :search, '%'))
                   OR LOWER(p.description) LIKE LOWER(CONCAT('%', :search, '%')))
            """)
    Page<Project> findWithFilters(@Param("departmentId") Long departmentId,
                                  @Param("status") ProjectStatus status,
                                  @Param("search") String search,
                                  Pageable pageable);

    /**
     * Count projects in a department — dashboard / department detail stats.
     */
    long countByDepartmentId(Long departmentId);
}
