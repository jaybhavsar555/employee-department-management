package com.learning.employeedept.exception;

import com.learning.employeedept.dto.response.ApiErrorResponse;
import jakarta.servlet.http.HttpServletRequest;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class GlobalExceptionHandlerTest {

    @Mock
    private HttpServletRequest request;

    @InjectMocks
    private GlobalExceptionHandler handler;

    @Test
    void handleNotFound_shouldReturn404() {
        when(request.getRequestURI()).thenReturn("/api/v1/employees/99");

        ResponseEntity<ApiErrorResponse> response = handler.handleNotFound(
                new ResourceNotFoundException("Employee not found"), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getBody().getStatus()).isEqualTo(404);
        assertThat(response.getBody().getMessage()).contains("Employee not found");
    }

    @Test
    void handleDuplicateEmail_shouldReturn409() {
        when(request.getRequestURI()).thenReturn("/api/v1/auth/register");

        ResponseEntity<ApiErrorResponse> response = handler.handleDuplicateEmail(
                new DuplicateEmailException("Email already exists"), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CONFLICT);
    }

    @Test
    void handleValidationException_shouldReturn400() {
        when(request.getRequestURI()).thenReturn("/api/v1/departments");

        ResponseEntity<ApiErrorResponse> response = handler.handleValidationException(
                new ValidationException("Invalid data"), request);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.BAD_REQUEST);
    }
}
