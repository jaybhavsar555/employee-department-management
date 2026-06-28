package com.learning.employeedept.exception;

/**
 * Thrown for business-rule validation failures in the service layer
 * (distinct from Jakarta Bean Validation on DTOs at the controller).
 * Mapped to HTTP 400 Bad Request by {@link GlobalExceptionHandler}.
 */
public class ValidationException extends RuntimeException {

    public ValidationException(String message) {
        super(message);
    }
}
