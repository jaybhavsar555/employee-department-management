package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.EmployeeRequest;
import com.learning.employeedept.dto.response.EmployeeResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

public interface EmployeeService {

    EmployeeResponse create(EmployeeRequest request);

    EmployeeResponse getById(Long id);

    Page<EmployeeResponse> getAll(Long departmentId, String search, Pageable pageable);

    EmployeeResponse update(Long id, EmployeeRequest request);

    void delete(Long id);
}
