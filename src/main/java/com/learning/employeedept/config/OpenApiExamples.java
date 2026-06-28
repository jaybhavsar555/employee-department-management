package com.learning.employeedept.config;

/**
 * Shared OpenAPI example payloads — keeps controller annotations readable.
 */
public final class OpenApiExamples {

    private OpenApiExamples() {
    }

    public static final String LOGIN_REQUEST = """
            {
              "username": "admin",
              "password": "admin123"
            }
            """;

    public static final String REGISTER_REQUEST = """
            {
              "username": "johndoe",
              "email": "john@example.com",
              "password": "securePass123"
            }
            """;

    public static final String AUTH_RESPONSE = """
            {
              "token": "eyJhbGciOiJIUzI1NiJ9...",
              "refreshToken": "eyJhbGciOiJIUzI1NiJ9...",
              "tokenType": "Bearer",
              "username": "admin",
              "role": "ROLE_ADMIN"
            }
            """;

    public static final String DEPARTMENT_REQUEST = """
            {
              "name": "Engineering",
              "description": "Software development team"
            }
            """;

    public static final String DEPARTMENT_RESPONSE = """
            {
              "id": 1,
              "name": "Engineering",
              "description": "Software development team",
              "employeeCount": 5,
              "createdAt": "2026-01-15T10:00:00",
              "updatedAt": "2026-01-15T10:00:00"
            }
            """;

    public static final String EMPLOYEE_REQUEST = """
            {
              "firstName": "Jane",
              "lastName": "Smith",
              "email": "jane.smith@company.com",
              "salary": 75000.00,
              "hireDate": "2024-03-15",
              "departmentId": 1
            }
            """;

    public static final String EMPLOYEE_RESPONSE = """
            {
              "id": 1,
              "firstName": "Jane",
              "lastName": "Smith",
              "email": "jane.smith@company.com",
              "salary": 75000.00,
              "hireDate": "2024-03-15",
              "departmentId": 1,
              "departmentName": "Engineering",
              "createdAt": "2026-01-15T10:00:00",
              "updatedAt": "2026-01-15T10:00:00"
            }
            """;

    public static final String PAGE_RESPONSE = """
            {
              "content": [],
              "totalElements": 0,
              "totalPages": 0,
              "size": 10,
              "number": 0,
              "first": true,
              "last": true
            }
            """;

    public static final String ERROR_RESPONSE = """
            {
              "timestamp": "2026-06-28T10:30:00",
              "status": 404,
              "error": "Not Found",
              "message": "Resource not found",
              "path": "/api/v1/departments/99"
            }
            """;
}
