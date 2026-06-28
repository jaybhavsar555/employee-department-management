package com.learning.employeedept.controller;

import com.learning.employeedept.config.OpenApiExamples;
import com.learning.employeedept.dto.request.LoginRequest;
import com.learning.employeedept.dto.request.RefreshTokenRequest;
import com.learning.employeedept.dto.request.RegisterRequest;
import com.learning.employeedept.dto.response.AuthResponse;
import com.learning.employeedept.service.AuthService;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.media.Content;
import io.swagger.v3.oas.annotations.media.ExampleObject;
import io.swagger.v3.oas.annotations.media.Schema;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

/**
 * Thin REST controller for authentication — delegates all logic to {@link AuthService}.
 * <p>
 * REST best practice: use nouns ({@code /auth}), correct verbs via HTTP methods,
 * meaningful status codes (201 for register, 200 for login).
 */
@RestController
@RequestMapping("/api/v1/auth")
@RequiredArgsConstructor
@Tag(name = "Authentication", description = "Register, login, and refresh JWT tokens")
public class AuthController {

    private final AuthService authService;

    @PostMapping("/register")
    @Operation(summary = "Register a new user", description = "Creates account with ROLE_EMPLOYEE and returns JWT tokens")
    @ApiResponses({
            @ApiResponse(responseCode = "201", description = "User registered",
                    content = @Content(schema = @Schema(implementation = AuthResponse.class),
                            examples = @ExampleObject(value = OpenApiExamples.AUTH_RESPONSE))),
            @ApiResponse(responseCode = "409", description = "Username or email already exists",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE))),
            @ApiResponse(responseCode = "400", description = "Validation failed",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE)))
    })
    public ResponseEntity<AuthResponse> register(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.REGISTER_REQUEST)))
            @Valid @RequestBody RegisterRequest request) {
        return ResponseEntity.status(HttpStatus.CREATED).body(authService.register(request));
    }

    @PostMapping("/login")
    @Operation(summary = "Login", description = "Authenticate and receive access + refresh JWT tokens")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Login successful",
                    content = @Content(schema = @Schema(implementation = AuthResponse.class),
                            examples = @ExampleObject(value = OpenApiExamples.AUTH_RESPONSE))),
            @ApiResponse(responseCode = "401", description = "Invalid credentials",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE)))
    })
    public ResponseEntity<AuthResponse> login(
            @io.swagger.v3.oas.annotations.parameters.RequestBody(
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.LOGIN_REQUEST)))
            @Valid @RequestBody LoginRequest request) {
        return ResponseEntity.ok(authService.login(request));
    }

    @PostMapping("/refresh")
    @Operation(summary = "Refresh tokens", description = "Exchange a valid refresh token for a new token pair")
    @ApiResponses({
            @ApiResponse(responseCode = "200", description = "Tokens refreshed",
                    content = @Content(schema = @Schema(implementation = AuthResponse.class),
                            examples = @ExampleObject(value = OpenApiExamples.AUTH_RESPONSE))),
            @ApiResponse(responseCode = "401", description = "Invalid or expired refresh token",
                    content = @Content(examples = @ExampleObject(value = OpenApiExamples.ERROR_RESPONSE)))
    })
    public ResponseEntity<AuthResponse> refresh(@Valid @RequestBody RefreshTokenRequest request) {
        return ResponseEntity.ok(authService.refresh(request));
    }
}
