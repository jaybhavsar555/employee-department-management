# Employee & Department Management System

A beginner-to-intermediate **Spring Boot** learning project for backend interview preparation.

Manage departments and employees with JWT-secured REST APIs, validation, pagination, sorting, filtering, and clean layered architecture.

## Tech Stack

| Layer | Technology |
|-------|------------|
| Language | Java 17+ (Java 21 recommended) |
| Framework | Spring Boot 3.3 |
| Security | Spring Security + JWT |
| Persistence | Spring Data JPA + PostgreSQL |
| Build | Maven |
| Docs | Swagger (springdoc-openapi) |
| Testing | JUnit 5 + Mockito |
| DevOps | Docker + Docker Compose |

## Prerequisites

Install before running locally:

1. **JDK 17 or 21** — [Adoptium](https://adoptium.net/) or Oracle JDK  
   ```bash
   java -version
   ```

2. **Docker Desktop** (for PostgreSQL)  
   ```bash
   docker --version
   docker compose version
   ```

3. **Git** (to push to GitHub)  
   ```bash
   git --version
   ```

> Maven is **not required** — the project includes the Maven Wrapper (`mvnw` / `mvnw.cmd`).

## Project Structure

```
employee-department-management/
├── docs/
│   ├── ARCHITECTURE.md      # Layer design & rationale
│   └── schema.sql           # Reference DB schema
├── src/main/java/com/learning/employeedept/
│   ├── config/              # Security, Swagger, seed data
│   ├── controller/          # REST endpoints (thin layer)
│   ├── dto/                 # Request/response objects
│   ├── entity/              # JPA entities
│   ├── exception/           # Custom exceptions + global handler
│   ├── mapper/              # Entity ↔ DTO mapping
│   ├── repository/          # Spring Data JPA repositories
│   ├── security/            # JWT filter & user details
│   └── service/             # Business logic (interfaces + impl)
├── src/main/resources/
│   └── application.yml
├── docker-compose.yml
├── Dockerfile
└── pom.xml
```

## Quick Start

### 1. Start PostgreSQL

```bash
docker compose up -d
```

### 2. Run the application

**Windows:**
```bash
mvnw.cmd spring-boot:run
```

**Linux / macOS:**
```bash
./mvnw spring-boot:run
```

App runs at: `http://localhost:8080`

### 3. Open Swagger UI

`http://localhost:8080/swagger-ui.html`

### 4. Default admin user (seeded on startup)

| Field | Value |
|-------|-------|
| Username | `admin` |
| Password | `admin123` |
| Role | `ROLE_ADMIN` |

## API Overview

| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| GET | `/api/v1/health` | Public | Health check |
| POST | `/api/v1/auth/register` | Public | Register user |
| POST | `/api/v1/auth/login` | Public | Login → JWT |
| GET/POST/PUT | `/api/v1/departments/**` | JWT | Department CRUD |
| DELETE | `/api/v1/departments/{id}` | ADMIN | Delete department |
| GET/POST/PUT | `/api/v1/employees/**` | JWT | Employee CRUD + filters |
| DELETE | `/api/v1/employees/{id}` | ADMIN | Delete employee |

### Example: Login & create department

```bash
# Login
curl -X POST http://localhost:8080/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"admin\",\"password\":\"admin123\"}"

# Use token from response
curl -X POST http://localhost:8080/api/v1/departments \
  -H "Authorization: Bearer <TOKEN>" \
  -H "Content-Type: application/json" \
  -d "{\"name\":\"Engineering\",\"description\":\"Software team\"}"
```

### Employee list with pagination & filtering

```
GET /api/v1/employees?page=0&size=10&sort=lastName,asc&departmentId=1&search=john
```

## Run Tests

```bash
mvnw.cmd test
```

## Push to GitHub

```bash
git init
git add .
git commit -m "Initial commit: Spring Boot EMS scaffold with JWT, CRUD, and Docker"
git branch -M main
git remote add origin https://github.com/<your-username>/employee-department-management.git
git push -u origin main
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `JWT_SECRET` | (see application.yml) | Min 32 chars for production |
| `SPRING_DATASOURCE_URL` | localhost PostgreSQL | Override DB URL |

## What This Project Demonstrates

- **Layered architecture** — Controller → Service → Repository  
- **SOLID** — interfaces for services, single-responsibility classes  
- **Repository pattern** — Spring Data JPA  
- **DTOs** — decouple API from entities  
- **Validation** — `@Valid` + Bean Validation  
- **Exception handling** — `@RestControllerAdvice`  
- **Logging** — SLF4J via Lombok `@Slf4j`  
- **JWT authentication** — stateless security  
- **Pagination / sorting / filtering** — `Pageable` + custom queries  

## License

MIT — free to use for learning and portfolio.
