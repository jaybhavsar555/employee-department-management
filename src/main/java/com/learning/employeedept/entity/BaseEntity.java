package com.learning.employeedept.entity;

import jakarta.persistence.Column;
import jakarta.persistence.EntityListeners;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.MappedSuperclass;
import lombok.Getter;
import lombok.Setter;
import org.springframework.data.annotation.CreatedDate;
import org.springframework.data.annotation.LastModifiedDate;
import org.springframework.data.jpa.domain.support.AuditingEntityListener;

import java.time.LocalDateTime;

/**
 * Parent class for all entities — holds shared primary key and audit columns.
 */
@Getter
@Setter
@MappedSuperclass // Not a table itself; fields are inherited by child @Entity classes
@EntityListeners(AuditingEntityListener.class) // Enables auto-fill of createdAt / updatedAt
public abstract class BaseEntity {

    @Id // Marks the primary key field
    @GeneratedValue(strategy = GenerationType.IDENTITY) // DB auto-increment (PostgreSQL BIGSERIAL)
    private Long id;

    @CreatedDate // Set once when row is first inserted (requires @EnableJpaAuditing)
    @Column(nullable = false, updatable = false) // Never changes after create
    private LocalDateTime createdAt;

    @LastModifiedDate // Updated automatically on every save
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
