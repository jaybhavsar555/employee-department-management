package com.learning.employeedept.controller;

import com.learning.employeedept.dto.response.ActivityItemResponse;
import com.learning.employeedept.dto.response.DashboardStatsResponse;
import com.learning.employeedept.service.DashboardService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import io.swagger.v3.oas.annotations.tags.Tag;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping("/api/v1/dashboard")
@RequiredArgsConstructor
@Tag(name = "Dashboard", description = "Aggregate statistics and recent activity feed")
@SecurityRequirement(name = "Bearer Authentication")
public class DashboardController {

    private static final int DEFAULT_ACTIVITY_LIMIT = 15;

    private final DashboardService dashboardService;

    @GetMapping("/stats")
    @Operation(summary = "Get dashboard statistics",
            description = "Returns counts for departments, employees, projects, tasks, pending tasks, and completed tasks")
    @ApiResponse(responseCode = "200", description = "Dashboard statistics",
            content = @Content(schema = @Schema(implementation = DashboardStatsResponse.class)))
    public ResponseEntity<DashboardStatsResponse> getStats() {
        return ResponseEntity.ok(dashboardService.getStats());
    }

    @GetMapping("/activity")
    @Operation(summary = "Get recent activity feed",
            description = "Returns merged recent changes across departments, employees, projects, and tasks")
    @ApiResponse(responseCode = "200", description = "Recent activity items")
    public ResponseEntity<List<ActivityItemResponse>> getRecentActivity(
            @RequestParam(defaultValue = "15") int limit) {
        int safeLimit = limit > 0 ? limit : DEFAULT_ACTIVITY_LIMIT;
        return ResponseEntity.ok(dashboardService.getRecentActivity(safeLimit));
    }
}
