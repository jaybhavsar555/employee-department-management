package com.learning.employeedept.config;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.event.EventListener;
import org.springframework.core.env.Environment;
import org.springframework.stereotype.Component;

/**
 * Logs key runtime information once the application is ready to accept traffic.
 * Uses INFO level — appropriate for lifecycle events (not DEBUG noise).
 */
@Slf4j
@Component
public class ApplicationStartupLogger {

    @EventListener(ApplicationReadyEvent.class)
    public void onApplicationReady(ApplicationReadyEvent event) {
        Environment env = event.getApplicationContext().getEnvironment();
        String port = env.getProperty("server.port", "8080");
        log.info("Application started successfully on port {}", port);
        log.info("Swagger UI: http://localhost:{}/swagger-ui.html", port);
        log.info("API base path: http://localhost:{}/api/v1", port);
    }
}
