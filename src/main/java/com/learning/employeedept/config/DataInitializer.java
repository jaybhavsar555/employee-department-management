package com.learning.employeedept.config;

import com.learning.employeedept.entity.Role;
import com.learning.employeedept.entity.RoleName;
import com.learning.employeedept.entity.User;
import com.learning.employeedept.repository.RoleRepository;
import com.learning.employeedept.repository.UserRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.CommandLineRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Slf4j
@Component
@RequiredArgsConstructor
public class DataInitializer implements CommandLineRunner {

    private final RoleRepository roleRepository;
    private final UserRepository userRepository;
    private final PasswordEncoder passwordEncoder;

    @Override
    public void run(String... args) {
        seedRole(RoleName.ROLE_ADMIN);
        seedRole(RoleName.ROLE_USER);
        seedAdminUser();
    }

    private void seedRole(RoleName roleName) {
        roleRepository.findByName(roleName).orElseGet(() -> {
            Role role = Role.builder().name(roleName).build();
            log.info("Seeding role: {}", roleName);
            return roleRepository.save(role);
        });
    }

    private void seedAdminUser() {
        if (userRepository.existsByUsername("admin")) {
            return;
        }

        Role adminRole = roleRepository.findByName(RoleName.ROLE_ADMIN)
                .orElseThrow(() -> new IllegalStateException("Admin role not found"));

        User admin = User.builder()
                .username("admin")
                .email("admin@ems.local")
                .password(passwordEncoder.encode("admin123"))
                .role(adminRole)
                .build();

        userRepository.save(admin);
        log.info("Seeded default admin user (username: admin, password: admin123)");
    }
}
