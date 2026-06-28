package com.learning.employeedept.entity;

/**
 * Fixed role values stored as strings in the database.
 * Using an enum prevents typos like "ADMIN" vs "ROLE_ADMIN".
 */
public enum RoleName {
    ROLE_ADMIN,
    ROLE_EMPLOYEE
}
