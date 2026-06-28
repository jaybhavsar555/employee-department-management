package com.learning.employeedept.controller;

import com.learning.employeedept.dto.request.LoginRequest;
import com.learning.employeedept.dto.request.RefreshTokenRequest;
import com.learning.employeedept.dto.request.RegisterRequest;
import com.learning.employeedept.dto.response.AuthResponse;
import com.learning.employeedept.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController // Returns JSON (not HTML views)
@RequestMapping("/api/v1/auth") // Base path for all auth endpoints
@RequiredArgsConstructor // Constructor injection for AuthService
@Tag(name = "Authentication") // Groups endpoints in Swagger UI
public class AuthController {

    private final AuthService authService; // Business logic layer — controller stays thin

    @PostMapping("/register") // POST /api/v1/auth/register
    @Operation(summary = "Register a new user")
    public ResponseEntity<AuthResponse> register(@Valid @RequestBody RegisterRequest request) {
        // @Valid runs validation (email format, required fields, etc.)
        // 201 CREATED because a new user resource was created
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login") // POST /api/v1/auth/login
    @Operation(summary = "Login and receive JWT token")
    public ResponseEntity<AuthResponse> login(@Valid @RequestBody LoginRequest request) {
        // Returns access token + refresh token + username + role
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh") // POST /api/v1/auth/refresh
    @Operation(summary = "Refresh access token using a refresh token")
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        // Client sends refresh token when access token expires — gets a new pair
        return ResponseEntity.ok(authService.refresh(request));
    }
}
