package com.learning.employeedept.service;

import com.learning.employeedept.dto.response.ActivityItemResponse;
import com.learning.employeedept.dto.response.DashboardStatsResponse;

import java.util.List;

public interface DashboardService {

    DashboardStatsResponse getStats();

    List<ActivityItemResponse> getRecentActivity(int limit);
}
