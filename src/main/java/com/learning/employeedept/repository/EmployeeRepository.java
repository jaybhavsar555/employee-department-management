package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Employee;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

public interface EmployeeRepository extends JpaRepository<Employee, Long> {

    boolean existsByEmailIgnoreCase(String email);

    boolean existsByEmailIgnoreCaseAndIdNot(String email, Long id);

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
}
