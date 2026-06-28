package com.learning.employeedept.dto.response;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Getter;

@Getter
@Builder
@AllArgsConstructor
public class DashboardStatsResponse {

    private final long departments;
    private final long employees;
    private final long projects;
    private final long tasks;
    private final long pendingTasks;
    private final long completedTasks;
}
