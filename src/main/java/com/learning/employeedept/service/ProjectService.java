package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.ProjectRequest;
import com.learning.employeedept.dto.response.ProjectResponse;
import com.learning.employeedept.entity.ProjectStatus;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface ProjectService {

    ProjectResponse create(ProjectRequest request);

    ProjectResponse getById(Long id);

    Page<ProjectResponse> getAll(Long departmentId, ProjectStatus status, String search, Pageable pageable);

    ProjectResponse update(Long id, ProjectRequest request);

    void delete(Long id);
}
