package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.request.LoginRequest;
import com.learning.employeedept.dto.request.RefreshTokenRequest;
import com.learning.employeedept.dto.request.RegisterRequest;
import com.learning.employeedept.dto.response.AuthResponse;
import com.learning.employeedept.entity.Role;
import com.learning.employeedept.entity.RoleName;
import com.learning.employeedept.entity.User;
import com.learning.employeedept.exception.DuplicateResourceException;
import com.learning.employeedept.exception.UnauthorizedException;
import com.learning.employeedept.repository.RoleRepository;
import com.learning.employeedept.repository.UserRepository;
import com.learning.employeedept.security.JwtService;
import com.learning.employeedept.service.AuthService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Slf4j // Adds a logger — log.info(...) for audit trail
@Service // Business logic layer bean
@RequiredArgsConstructor // Inject all dependencies via constructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder; // BCrypt — hashes passwords
    private final JwtService jwtService; // Creates and validates JWT tokens
    private final AuthenticationManager authenticationManager; // Checks username/password at login
    private final UserDetailsService userDetailsService; // Loads user + roles from DB

    @Override
    @Transactional // All DB steps succeed together or roll back
    public AuthResponse register(RegisterRequest request) {
        // Prevent duplicate username — return 409 Conflict
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new DuplicateResourceException("Username already exists");
        }
        // Prevent duplicate email
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateResourceException("Email already exists");
        }

        // New users get ROLE_USER by default (not admin)
        Role userRole = roleRepository.findByName(RoleName.ROLE_USER)
                .orElseThrow(() -> new IllegalStateException("Default role ROLE_USER not found"));

        // Build user entity — password is hashed before saving
        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(userRole)
                .build();

        userRepository.save(user); // Insert into users table
        log.info("Registered new user: {}", user.getUsername());

        // Immediately return tokens so user is logged in after register
        return buildAuthResponse(user.getUsername());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        try {
            // Spring Security checks username + password against database
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword()));
        } catch (Exception ex) {
            // Wrong password or unknown user — return 401
            throw new UnauthorizedException("Invalid username or password");
        }

        log.info("User logged in: {}", request.getUsername());
        // Password OK — generate and return JWT tokens
        return buildAuthResponse(request.getUsername());
    }

    @Override
    public AuthResponse refresh(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        // Make sure this token is a refresh token, not an access token
        if (!jwtService.isRefreshToken(refreshToken)) {
            throw new UnauthorizedException("Invalid refresh token");
        }

        // Read username from inside the JWT payload
        String username = jwtService.extractUsername(refreshToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);

        // Check token is not expired and belongs to this user
        if (!jwtService.isRefreshTokenValid(refreshToken, userDetails)) {
            throw new UnauthorizedException("Refresh token expired or invalid");
        }

        log.info("Tokens refreshed for user: {}", username);
        // Issue a brand-new access + refresh token pair
        return buildAuthResponse(username);
    }

    /** Shared helper — builds the JSON response sent to the client after login/register/refresh. */
    private AuthResponse buildAuthResponse(String username) {
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        String token = jwtService.generateToken(userDetails); // Short-lived access token
        String refreshToken = jwtService.generateRefreshToken(userDetails); // Long-lived refresh token
        String role = userDetails.getAuthorities().iterator().next().getAuthority(); // e.g. ROLE_ADMIN

        return AuthResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .tokenType("Bearer") // Client sends: Authorization: Bearer <token>
                .username(username)
                .role(role)
                .build();
    }
}
