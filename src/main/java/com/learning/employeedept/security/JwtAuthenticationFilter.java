package com.learning.employeedept.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.lang.NonNull;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;

@Component // Registered automatically as a Spring bean
@RequiredArgsConstructor
public class JwtAuthenticationFilter extends OncePerRequestFilter {

    private final JwtService jwtService; // Parse and validate JWT
    private final CustomUserDetailsService userDetailsService; // Load user from DB

    /**
     * Runs once per HTTP request BEFORE the request reaches the controller.
     * If a valid JWT is present, we tell Spring Security who the user is.
     */
    @Override
    protected void doFilterInternal(@NonNull HttpServletRequest request,
                                    @NonNull HttpServletResponse response,
                                    @NonNull FilterChain filterChain) throws ServletException, IOException {
        // Read "Authorization: Bearer eyJhbG..." header
        String authHeader = request.getHeader("Authorization");

        // No token — skip JWT logic, continue to next filter (may still be blocked by SecurityConfig)
        if (authHeader == null || !authHeader.startsWith("Bearer ")) {
            filterChain.doFilter(request, response);
            return;
        }

        // Remove "Bearer " prefix — left with raw JWT string
        String jwt = authHeader.substring(7);
        String username = jwtService.extractUsername(jwt);

        // Only authenticate if we have a username AND nobody is logged in yet for this request
        if (username != null && SecurityContextHolder.getContext().getAuthentication() == null) {
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);

            // Must be access token (not refresh) and must be valid + not expired
            if (jwtService.isAccessToken(jwt) && jwtService.isTokenValid(jwt, userDetails)) {
                // Create Spring Security authentication object with user's roles
                UsernamePasswordAuthenticationToken authentication =
                        new UsernamePasswordAuthenticationToken(
                                userDetails, null, userDetails.getAuthorities());
                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(request));

                // Store user in thread-local context — controllers can use @AuthenticationPrincipal
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        }

        // Pass request to the next filter / controller
        filterChain.doFilter(request, response);
    }
}
