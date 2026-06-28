package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Task;
import com.learning.employeedept.entity.TaskPriority;
import com.learning.employeedept.entity.TaskStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDate;
import java.util.List;

/**
 * Spring Data JPA repository for {@link Task}.
 * Tasks belong to a project; optionally assigned to an employee and linked to creating user.
 */
public interface TaskRepository extends JpaRepository<Task, Long> {

    /**
     * Derived query: paginated tasks for a project (sprint board / project detail page).
     */
    Page<Task> findByProjectId(Long projectId, Pageable pageable);

    /**
     * Derived query: all tasks assigned to one employee (paginated "my tasks" view).
     */
    Page<Task> findByAssigneeId(Long assigneeId, Pageable pageable);

    /**
     * Derived query: filter tasks by workflow status with pagination.
     */
    Page<Task> findByStatus(TaskStatus status, Pageable pageable);

    /**
     * Derived query: filter by priority — e.g. all CRITICAL tasks.
     */
    Page<Task> findByPriority(TaskPriority priority, Pageable pageable);

    /**
     * Derived query: tasks in a project with a specific status (Kanban column).
     */
    Page<Task> findByProjectIdAndStatus(Long projectId, TaskStatus status, Pageable pageable);

    /**
     * Derived query: overdue tasks for one assignee (due date before today, not DONE).
     * Spring parses {@code LessThan} as {@code <} in SQL.
     */
    List<Task> findByAssigneeIdAndDueDateLessThanAndStatusNot(
            Long assigneeId, LocalDate today, TaskStatus excludedStatus);

    /**
     * Derived query: count open tasks in a project (exclude DONE/CANCELLED).
     */
    long countByProjectIdAndStatusNotIn(Long projectId, List<TaskStatus> excludedStatuses);

    /**
     * Custom JPQL: flexible task search with optional project, assignee, status, priority filters.
     * Used for admin filters: "show HIGH priority IN_PROGRESS tasks in project 5".
     */
    @Query("""
            SELECT t FROM Task t
            WHERE (:projectId IS NULL OR t.project.id = :projectId)
              AND (:assigneeId IS NULL OR t.assignee.id = :assigneeId)
              AND (:status IS NULL OR t.status = :status)
              AND (:priority IS NULL OR t.priority = :priority)
              AND (:search IS NULL OR :search = ''
                   OR LOWER(t.title) LIKE LOWER(CONCAT('%', :search, '%'))
                   OR LOWER(t.description) LIKE LOWER(CONCAT('%', :search, '%')))
            """)
    Page<Task> findWithFilters(@Param("projectId") Long projectId,
                               @Param("assigneeId") Long assigneeId,
                               @Param("status") TaskStatus status,
                               @Param("priority") TaskPriority priority,
                               @Param("search") String search,
                               Pageable pageable);

    /**
     * Count tasks by workflow status — dashboard completed task metric.
     */
    long countByStatus(TaskStatus status);

    /**
     * Count tasks excluding given statuses — dashboard pending task metric.
     */
    long countByStatusNotIn(List<TaskStatus> excludedStatuses);
}
