package com.learning.employeedept.controller;

import com.learning.employeedept.config.OpenApiExamples;
import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import com.learning.employeedept.service.DepartmentService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.web.PageableDefault;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * Department REST API — thin controller, business rules in {@link DepartmentService}.
 * <p>
 * REST best practices demonstrated:
 * <ul>
 *   <li>Resource-oriented URLs ({@code /departments/{id}})</li>
 *   <li>Correct HTTP verbs (GET read, POST create, PUT update, DELETE remove)</li>
 *   <li>{@link ResponseEntity} for explicit status codes</li>
 *   <li>Pagination via {@code page}, {@code size}, {@code sort} query params</li>
 *   <li>Role-based authorization — DELETE requires ADMIN</li>
 * </ul>
 */
@RestController
@RequestMapping("/api/v1/departments")
@RequiredArgsConstructor
@Tag(name = "Departments", description = "Manage organizational departments")
@SecurityRequirement(name = "Bearer Authentication")
public class DepartmentController {

    private final DepartmentService departmentService;

    @PostMapping
    @Operation(summary = "Create a department")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "Department created",
                    content = @Content(schema = @Schema(implementation = DepartmentResponse.class),
                            examples = @ExampleObject(value = OpenApiExamples.DEPARTMENT_RESPONSE))),
            @ApiResponse(responseCode = "409", description = "Duplicate department name",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE)))
    })
    public ResponseEntity<DepartmentResponse> create(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.DEPARTMENT_REQUEST)))
            @Valid @RequestBody DepartmentRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(departmentService.create(request));
    }

    @GetMapping("/{id}")
    @Operation(summary = "Get department by ID")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Department found",
                    content = @Content(schema = @Schema(implementation = DepartmentResponse.class),
                            examples = @ExampleObject(value = OpenApiExamples.DEPARTMENT_RESPONSE))),
            @ApiResponse(responseCode = "404", description = "Department not found",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE)))
    })
    public ResponseEntity<DepartmentResponse> getById(@PathVariable Long id) {
        return ResponseEntity.ok(departmentService.getById(id));
    }

    @GetMapping
    @Operation(summary = "List departments with pagination and sorting")
    @ApiResponse(responseCode = "200", description = "Paginated department list",
            content = @Content(examples = @ExampleObject(value = OpenApiExamples.PAGE_RESPONSE)))
    public ResponseEntity<Page<DepartmentResponse>> getAll(
            @RequestParam(required = false) String search,
            @PageableDefault(size = 10, sort = "name", direction = Sort.Direction.ASC) Pageable pageable) {
        return ResponseEntity.ok(departmentService.getAll(search, pageable));
    }

    @PutMapping("/{id}")
    @Operation(summary = "Update a department")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Department updated",
                    content = @Content(schema = @Schema(implementation = DepartmentResponse.class))),
            @ApiResponse(responseCode = "404", description = "Department not found"),
            @ApiResponse(responseCode = "409", description = "Duplicate name")
    })
    public ResponseEntity<DepartmentResponse> update(@PathVariable Long id,
                                                     @Valid @RequestBody DepartmentRequest request) {
        return ResponseEntity.ok(departmentService.update(id, request));
    }

    @DeleteMapping("/{id}")
    @PreAuthorize("hasRole('ADMIN')")
    @Operation(summary = "Delete a department", description = "Requires ROLE_ADMIN. Fails if employees are assigned.")
    @ApiResponses({
            @ApiResponse(responseCode = "204", description = "Department deleted"),
            @ApiResponse(responseCode = "403", description = "Insufficient role"),
            @ApiResponse(responseCode = "400", description = "Department has employees")
    })
    public ResponseEntity<Void> delete(@PathVariable Long id) {
        departmentService.delete(id);
        return ResponseEntity.noContent().build();
    }
}
