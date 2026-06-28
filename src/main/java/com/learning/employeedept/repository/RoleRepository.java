package com.learning.employeedept.repository;

import com.learning.employeedept.entity.Role;
import com.learning.employeedept.entity.RoleName;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface RoleRepository extends JpaRepository<Role, Long> {

    Optional<Role> findByName(RoleName name);
}
