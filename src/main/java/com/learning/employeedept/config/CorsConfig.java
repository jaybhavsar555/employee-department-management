package com.learning.employeedept.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration // Spring config class — creates beans at startup
public class CorsConfig {

    @Bean // This bean is injected into SecurityConfig
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration configuration = new CorsConfiguration();

        // Allow requests from any origin (fine for dev; restrict in production)
        configuration.setAllowedOriginPatterns(List.of("*"));
        // HTTP methods the browser is allowed to use
        configuration.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS", "PATCH"));
        // Allow all request headers (e.g. Authorization, Content-Type)
        configuration.setAllowedHeaders(List.of("*"));
        // Browser may read Authorization header from the response
        configuration.setExposedHeaders(List.of("Authorization"));
        // Required when frontend sends cookies or auth headers cross-origin
        configuration.setAllowCredentials(true);

        // Apply the above rules to every URL path in the app
        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", configuration);
        return source;
    }
}
