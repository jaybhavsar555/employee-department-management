# Architecture Guide

## Layered Architecture

Controller -> Service -> Repository -> PostgreSQL

## Why each layer exists

- **Controller**: HTTP only, thin REST layer
- **DTO**: API contract separate from entities
- **Service**: Business rules and transactions
- **Repository**: Data access (Repository Pattern)
- **Entity**: JPA ORM mapping
- **Mapper**: Entity/DTO conversion
- **Exception**: Centralized error handling
- **Security**: JWT authentication filter

## Entity Relationships

- User N:1 Role
- Department 1:N Employee

See schema.sql for tables.