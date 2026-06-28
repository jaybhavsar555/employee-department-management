package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;

import java.util.List;

public interface DepartmentService {

    DepartmentResponse create(DepartmentRequest request);

    DepartmentResponse getById(Long id);

    List<DepartmentResponse> getAll();

    DepartmentResponse update(Long id, DepartmentRequest request);

    void delete(Long id);
}
