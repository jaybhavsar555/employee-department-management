package com.learning.employeedept.config;

import io.swagger.v3.oas.models.Components;
import io.swagger.v3.oas.models.OpenAPI;
import io.swagger.v3.oas.models.info.Contact;
import io.swagger.v3.oas.models.info.Info;
import io.swagger.v3.oas.models.security.SecurityRequirement;
import io.swagger.v3.oas.models.security.SecurityScheme;
import io.swagger.v3.oas.models.tags.Tag;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

import java.util.List;

@Configuration
public class OpenApiConfig {

    private static final String SECURITY_SCHEME_NAME = "Bearer Authentication";

    @Bean
    public OpenAPI openAPI() {
        return new OpenAPI()
                .info(new Info()
                        .title("Employee & Department Management API")
                        .description("""
                                Production-style Spring Boot REST API with JWT security, pagination, \
                                and role-based authorization (ROLE_ADMIN, ROLE_EMPLOYEE).
                                """)
                        .version("1.0.0")
                        .contact(new Contact()
                                .name("Jay Bhavsar")
                                .url("https://github.com/jaybhavsar555/employee-department-management")))
                .tags(List.of(
                        new Tag().name("Authentication").description("Public auth endpoints"),
                        new Tag().name("Departments").description("Department CRUD — JWT required"),
                        new Tag().name("Employees").description("Employee CRUD with pagination — JWT required"),
                        new Tag().name("Health").description("Application health check")
                ))
                .addSecurityItem(new SecurityRequirement().addList(SECURITY_SCHEME_NAME))
                .components(new Components()
                        .addSecuritySchemes(SECURITY_SCHEME_NAME, new SecurityScheme()
                                .name(SECURITY_SCHEME_NAME)
                                .type(SecurityScheme.Type.HTTP)
                                .scheme("bearer")
                                .bearerFormat("JWT")
                                .description("Paste JWT from /auth/login (without 'Bearer ' prefix)")));
    }
}
