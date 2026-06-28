package com.learning.employeedept.config;

// --- Imports: Spring Security + our JWT filter + CORS support ---
import com.learning.employeedept.security.JwtAuthenticationFilter;
import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.jpa.repository.config.EnableJpaAuditing;
import org.springframework.http.HttpMethod;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.AuthenticationProvider;
import org.springframework.security.authentication.dao.DaoAuthenticationProvider;
import org.springframework.security.config.annotation.authentication.configuration.AuthenticationConfiguration;
import org.springframework.security.config.annotation.method.configuration.EnableMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configurers.AbstractHttpConfigurer;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfigurationSource;

@Configuration // Tells Spring: this class contains bean definitions
@EnableWebSecurity // Turns on Spring Security for the whole app
@EnableMethodSecurity // Allows @PreAuthorize style checks on methods (if we use them)
@EnableJpaAuditing // Auto-fills createdAt / updatedAt on database entities
@RequiredArgsConstructor // Lombok creates a constructor for all final fields (dependency injection)
public class SecurityConfig {

    // Custom filter that reads JWT from Authorization header
    private final JwtAuthenticationFilter jwtAuthenticationFilter;
    // Loads user details (username, password hash, roles) from database
    private final UserDetailsService userDetailsService;
    // CORS rules so Flutter web app can call this API from the browser
    private final CorsConfigurationSource corsConfigurationSource;

    @Bean // Exposes this method's return value as a Spring bean
    public SecurityFilterChain securityFilterChain(HttpSecurity http) throws Exception {
        http
                // Allow cross-origin requests (needed for Flutter web on a different port)
                .cors(cors -> cors.configurationSource(corsConfigurationSource))
                // Disable CSRF because we use stateless JWT, not browser cookies
                .csrf(AbstractHttpConfigurer::disable)
                // No HTTP session stored on server — every request must send JWT
                .sessionManagement(session -> session.sessionCreationPolicy(SessionCreationPolicy.STATELESS))
                // Define which URLs need login and which roles are required
                .authorizeHttpRequests(auth -> auth
                        // Login, register, refresh — anyone can call these
                        .requestMatchers("/api/v1/auth/**").permitAll()
                        // Swagger docs — public for development
                        .requestMatchers("/swagger-ui/**", "/swagger-ui.html", "/api-docs/**", "/v3/api-docs/**")
                        .permitAll()
                        // Health check — public so Docker/monitoring can ping it
                        .requestMatchers(HttpMethod.GET, "/api/v1/health").permitAll()
                        // Only ADMIN role can DELETE resources
                        .requestMatchers(HttpMethod.DELETE, "/api/v1/**").hasRole("ADMIN")
                        // All other API calls need a valid JWT
                        .anyRequest().authenticated()
                )
                // Tells Spring how to verify username + password at login time
                .authenticationProvider(authenticationProvider())
                // Run our JWT filter before Spring's default username/password filter
                .addFilterBefore(jwtAuthenticationFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build(); // Build and return the final security filter chain
    }

    @Bean
    public AuthenticationProvider authenticationProvider() {
        // Standard Spring provider: loads user from DB and checks BCrypt password
        DaoAuthenticationProvider provider = new DaoAuthenticationProvider();
        provider.setUserDetailsService(userDetailsService); // Where to load users from
        provider.setPasswordEncoder(passwordEncoder()); // How to compare passwords
        return provider;
    }

    @Bean
    public AuthenticationManager authenticationManager(AuthenticationConfiguration config) throws Exception {
        // Used internally when login() calls authenticationManager.authenticate(...)
        return config.getAuthenticationManager();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        // BCrypt hashes passwords — we never store plain text passwords
        return new BCryptPasswordEncoder();
    }
}
