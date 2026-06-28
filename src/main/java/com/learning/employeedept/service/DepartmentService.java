package com.learning.employeedept.service;

import com.learning.employeedept.dto.request.DepartmentRequest;
import com.learning.employeedept.dto.response.DepartmentResponse;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

/**
 * Department business operations.
 * <p>
 * SOLID — <b>Interface Segregation</b>: callers depend only on department operations,
 * not employee or auth methods. <b>Dependency Inversion</b>: controllers depend on
 * this interface, not {@code DepartmentServiceImpl}.
 */
public interface DepartmentService {

    DepartmentResponse create(DepartmentRequest request);

    DepartmentResponse getById(Long id);

    Page<DepartmentResponse> getAll(String search, Pageable pageable);

    DepartmentResponse update(Long id, DepartmentRequest request);

    void delete(Long id);
}
