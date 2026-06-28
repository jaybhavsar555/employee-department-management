package com.learning.employeedept.service;

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
import com.learning.employeedept.service.impl.AuthServiceImpl;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.InjectMocks;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.util.List;
import java.util.Optional;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@ExtendWith(MockitoExtension.class)
class AuthServiceTest {

    @Mock
    private UserRepository userRepository;

    @Mock
    private RoleRepository roleRepository;

    @Mock
    private PasswordEncoder passwordEncoder;

    @Mock
    private JwtService jwtService;

    @Mock
    private AuthenticationManager authenticationManager;

    @Mock
    private UserDetailsService userDetailsService;

    @InjectMocks
    private AuthServiceImpl authService;

    @Test
    void register_shouldCreateUserAndReturnTokens() {
        // Arrange
        RegisterRequest request = new RegisterRequest();
        request.setUsername("john");
        request.setEmail("john@example.com");
        request.setPassword("pass12345");

        Role employeeRole = Role.builder().name(RoleName.ROLE_EMPLOYEE).build();
        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                "john", "hash", List.of(new SimpleGrantedAuthority("ROLE_EMPLOYEE")));

        when(userRepository.existsByUsername("john")).thenReturn(false);
        when(userRepository.existsByEmail("john@example.com")).thenReturn(false);
        when(roleRepository.findByName(RoleName.ROLE_EMPLOYEE)).thenReturn(Optional.of(employeeRole));
        when(passwordEncoder.encode("pass12345")).thenReturn("hashed");
        when(userRepository.save(any(User.class))).thenAnswer(inv -> inv.getArgument(0));
        when(userDetailsService.loadUserByUsername("john")).thenReturn(userDetails);
        when(jwtService.generateToken(userDetails)).thenReturn("access-token");
        when(jwtService.generateRefreshToken(userDetails)).thenReturn("refresh-token");

        // Act
        AuthResponse response = authService.register(request);

        // Assert
        assertThat(response.getToken()).isEqualTo("access-token");
        assertThat(response.getRole()).isEqualTo("ROLE_EMPLOYEE");
        verify(userRepository).save(any(User.class));
    }

    @Test
    void register_shouldThrowDuplicateEmailException() {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("john");
        request.setEmail("john@example.com");
        request.setPassword("pass12345");

        when(userRepository.existsByUsername("john")).thenReturn(false);
        when(userRepository.existsByEmail("john@example.com")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(DuplicateEmailException.class);
        verify(userRepository, never()).save(any());
    }

    @Test
    void register_shouldThrowDuplicateResourceExceptionForUsername() {
        RegisterRequest request = new RegisterRequest();
        request.setUsername("john");
        request.setEmail("john@example.com");
        request.setPassword("pass12345");

        when(userRepository.existsByUsername("john")).thenReturn(true);

        assertThatThrownBy(() -> authService.register(request))
                .isInstanceOf(DuplicateResourceException.class);
    }

    @Test
    void login_shouldReturnTokensOnSuccess() {
        LoginRequest request = new LoginRequest();
        request.setUsername("admin");
        request.setPassword("admin123");

        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                "admin", "hash", List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));

        when(userDetailsService.loadUserByUsername("admin")).thenReturn(userDetails);
        when(jwtService.generateToken(userDetails)).thenReturn("access");
        when(jwtService.generateRefreshToken(userDetails)).thenReturn("refresh");

        AuthResponse response = authService.login(request);

        assertThat(response.getUsername()).isEqualTo("admin");
        verify(authenticationManager).authenticate(any(UsernamePasswordAuthenticationToken.class));
    }

    @Test
    void refresh_shouldReturnNewTokens() {
        RefreshTokenRequest request = new RefreshTokenRequest();
        request.setRefreshToken("refresh-token");

        UserDetails userDetails = new org.springframework.security.core.userdetails.User(
                "admin", "hash", List.of(new SimpleGrantedAuthority("ROLE_ADMIN")));

        when(jwtService.isRefreshToken("refresh-token")).thenReturn(true);
        when(jwtService.extractUsername("refresh-token")).thenReturn("admin");
        when(userDetailsService.loadUserByUsername("admin")).thenReturn(userDetails);
        when(jwtService.isRefreshTokenValid("refresh-token", userDetails)).thenReturn(true);
        when(jwtService.generateToken(userDetails)).thenReturn("new-access");
        when(jwtService.generateRefreshToken(userDetails)).thenReturn("new-refresh");

        AuthResponse response = authService.refresh(request);

        assertThat(response.getToken()).isEqualTo("new-access");
    }

    @Test
    void login_shouldThrowUnauthorizedOnBadCredentials() {
        LoginRequest request = new LoginRequest();
        request.setUsername("admin");
        request.setPassword("wrong");

        when(authenticationManager.authenticate(any()))
                .thenThrow(new BadCredentialsException("Bad credentials"));

        assertThatThrownBy(() -> authService.login(request))
                .isInstanceOf(UnauthorizedException.class);
    }
}
