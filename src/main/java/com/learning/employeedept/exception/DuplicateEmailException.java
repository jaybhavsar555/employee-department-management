package com.learning.employeedept.exception;

/**
 * Thrown when an email address is already registered (user or employee).
 * Mapped to HTTP 409 Conflict by {@link GlobalExceptionHandler}.
 */
public class DuplicateEmailException extends RuntimeException {

    public DuplicateEmailException(String message) {
        super(message);
    }
}
