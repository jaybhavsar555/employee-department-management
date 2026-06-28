package com.learning.employeedept.service.impl;

import com.learning.employeedept.dto.request.LoginRequest;
import com.learning.employeedept.dto.request.RefreshTokenRequest;
import com.learning.employeedept.dto.request.RegisterRequest;
import com.learning.employeedept.dto.response.AuthResponse;
import com.learning.employeedept.entity.Role;
import com.learning.employeedept.entity.RoleName;
import com.learning.employeedept.entity.User;
import com.learning.employeedept.exception.DuplicateEmailException;
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

/**
 * Authentication business logic — register, login, token refresh.
 * <p>
 * SOLID — <b>Single Responsibility</b>: auth only. Does not manage employees/departments.
 * <b>Dependency Inversion</b>: implements {@link AuthService} interface.
 */
@Slf4j
@Service
@RequiredArgsConstructor
public class AuthServiceImpl implements AuthService {

    private final UserRepository userRepository;
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final AuthenticationManager authenticationManager;
    private final UserDetailsService userDetailsService;

    @Override
    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByUsername(request.getUsername())) {
            throw new DuplicateResourceException("Username already exists");
        }
        if (userRepository.existsByEmail(request.getEmail())) {
            throw new DuplicateEmailException("Email already exists: " + request.getEmail());
        }

        Role employeeRole = roleRepository.findByName(RoleName.ROLE_EMPLOYEE)
                .orElseThrow(() -> new IllegalStateException("Default role ROLE_EMPLOYEE not found"));

        User user = User.builder()
                .username(request.getUsername())
                .email(request.getEmail())
                .password(passwordEncoder.encode(request.getPassword()))
                .role(employeeRole)
                .build();

        userRepository.save(user);
        log.info("Registered new user: {} with role {}", user.getUsername(), RoleName.ROLE_EMPLOYEE);
        return buildAuthResponse(user.getUsername());
    }

    @Override
    public AuthResponse login(LoginRequest request) {
        try {
            authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(request.getUsername(), request.getPassword()));
        } catch (Exception ex) {
            log.warn("Login failed for username: {}", request.getUsername());
            throw new UnauthorizedException("Invalid username or password");
        }

        log.info("User logged in: {}", request.getUsername());
        return buildAuthResponse(request.getUsername());
    }

    @Override
    public AuthResponse refresh(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();

        if (!jwtService.isRefreshToken(refreshToken)) {
            throw new UnauthorizedException("Invalid refresh token");
        }

        String username = jwtService.extractUsername(refreshToken);
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);

        if (!jwtService.isRefreshTokenValid(refreshToken, userDetails)) {
            throw new UnauthorizedException("Refresh token expired or invalid");
        }

        log.info("Tokens refreshed for user: {}", username);
        return buildAuthResponse(username);
    }

    private AuthResponse buildAuthResponse(String username) {
        UserDetails userDetails = userDetailsService.loadUserByUsername(username);
        String token = jwtService.generateToken(userDetails);
        String refreshToken = jwtService.generateRefreshToken(userDetails);
        String role = userDetails.getAuthorities().iterator().next().getAuthority();

        return AuthResponse.builder()
                .token(token)
                .refreshToken(refreshToken)
                .tokenType("Bearer")
                .username(username)
                .role(role)
                .build();
    }
}
