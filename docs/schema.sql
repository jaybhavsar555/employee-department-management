-- =============================================================================
-- Employee & Department Management System — PostgreSQL Schema
-- =============================================================================
-- Purpose : Reference DDL for interviews and production planning.
-- Note    : In dev, JPA `ddl-auto=update` auto-creates/updates tables.
--           Use Flyway/Liquibase in production instead of ddl-auto.
-- =============================================================================

-- ---------------------------------------------------------------------------
-- EXTENSIONS (optional — useful for UUID PKs or full-text search later)
-- ---------------------------------------------------------------------------
-- CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ---------------------------------------------------------------------------
-- ENUM TYPES — store fixed domain values at the database level
-- Why not VARCHAR? CHECK constraints work, but ENUM prevents invalid inserts
-- and documents allowed values in the schema itself.
-- ---------------------------------------------------------------------------
CREATE TYPE project_status AS ENUM ('PLANNED', 'ACTIVE', 'ON_HOLD', 'COMPLETED', 'CANCELLED');
CREATE TYPE task_status    AS ENUM ('TODO', 'IN_PROGRESS', 'IN_REVIEW', 'DONE', 'CANCELLED');
CREATE TYPE task_priority  AS ENUM ('LOW', 'MEDIUM', 'HIGH', 'CRITICAL');

-- ---------------------------------------------------------------------------
-- TABLE: roles
-- Normalization: Role names live in their own table (3NF) instead of being
-- duplicated as a string on every user row.
-- ---------------------------------------------------------------------------
CREATE TABLE roles (
    id          BIGSERIAL       PRIMARY KEY,                    -- PK: surrogate key (auto-increment)
    name        VARCHAR(20)     NOT NULL UNIQUE,                -- UK: ROLE_ADMIN, ROLE_USER
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT chk_roles_name CHECK (name IN ('ROLE_ADMIN', 'ROLE_USER'))
);

-- ---------------------------------------------------------------------------
-- TABLE: users  (Authentication & authorization — NOT the same as employees)
-- A User logs into the API. An Employee is HR data. They may link later via
-- employee.user_id, but we keep them separate (Single Responsibility).
-- ---------------------------------------------------------------------------
CREATE TABLE users (
    id          BIGSERIAL       PRIMARY KEY,
    username    VARCHAR(50)     NOT NULL UNIQUE,                -- UK + index for login lookup
    email       VARCHAR(100)    NOT NULL UNIQUE,                -- UK + index for uniqueness checks
    password    VARCHAR(255)    NOT NULL,                       -- BCrypt hash — never plain text
    role_id     BIGINT          NOT NULL,                       -- FK → roles
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_users_role
        FOREIGN KEY (role_id) REFERENCES roles(id)
        ON DELETE RESTRICT                                      -- Cannot delete role if users exist
        ON UPDATE CASCADE,

    CONSTRAINT chk_users_username_length CHECK (char_length(username) >= 3),
    CONSTRAINT chk_users_email_format    CHECK (email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

CREATE INDEX idx_users_role_id ON users(role_id);

-- ---------------------------------------------------------------------------
-- TABLE: departments
-- Top-level organizational unit. One department has many employees & projects.
-- ---------------------------------------------------------------------------
CREATE TABLE departments (
    id          BIGSERIAL       PRIMARY KEY,
    name        VARCHAR(100)    NOT NULL UNIQUE,                -- UK: no duplicate dept names
    description VARCHAR(500),
    created_at  TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMP       NOT NULL DEFAULT NOW()
);

-- ---------------------------------------------------------------------------
-- TABLE: employees
-- HR records. Every employee belongs to exactly ONE department (2NF/3NF).
-- ---------------------------------------------------------------------------
CREATE TABLE employees (
    id              BIGSERIAL       PRIMARY KEY,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    email           VARCHAR(100)    NOT NULL UNIQUE,
    salary          NUMERIC(10, 2)  NOT NULL,
    hire_date       DATE            NOT NULL,
    department_id   BIGINT          NOT NULL,                   -- FK → departments
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_employees_department
        FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE RESTRICT                                      -- Block delete if employees exist
        ON UPDATE CASCADE,

    CONSTRAINT chk_employees_salary_positive CHECK (salary > 0),
    CONSTRAINT chk_employees_hire_date       CHECK (hire_date <= CURRENT_DATE)
);

CREATE INDEX idx_employees_department_id ON employees(department_id);
CREATE INDEX idx_employees_last_name     ON employees(last_name);
CREATE INDEX idx_employees_email         ON employees(email);

-- ---------------------------------------------------------------------------
-- TABLE: projects
-- A project is owned by one department. Optional lead employee (project manager).
-- Relationship: Department 1 ──→ N Projects
--               Employee  1 ──→ N Projects (as lead, optional)
-- ---------------------------------------------------------------------------
CREATE TABLE projects (
    id                  BIGSERIAL       PRIMARY KEY,
    name                VARCHAR(150)    NOT NULL,
    description         TEXT,
    status              project_status  NOT NULL DEFAULT 'PLANNED',
    start_date          DATE,
    end_date            DATE,
    department_id       BIGINT          NOT NULL,               -- FK → departments
    lead_employee_id    BIGINT,                                   -- FK → employees (nullable)
    created_at          TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at          TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_projects_department
        FOREIGN KEY (department_id) REFERENCES departments(id)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_projects_lead_employee
        FOREIGN KEY (lead_employee_id) REFERENCES employees(id)
        ON DELETE SET NULL                                          -- Lead leaves → project survives
        ON UPDATE CASCADE,

    CONSTRAINT uq_projects_name_per_department
        UNIQUE (department_id, name),                             -- Same name OK in different depts

    CONSTRAINT chk_projects_dates
        CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

CREATE INDEX idx_projects_department_id    ON projects(department_id);
CREATE INDEX idx_projects_lead_employee_id ON projects(lead_employee_id);
CREATE INDEX idx_projects_status           ON projects(status);

-- ---------------------------------------------------------------------------
-- TABLE: tasks
-- Smallest unit of work. Belongs to one project; optionally assigned to one employee.
-- Relationship: Project 1 ──→ N Tasks
--               Employee 1 ──→ N Tasks (as assignee)
-- ---------------------------------------------------------------------------
CREATE TABLE tasks (
    id              BIGSERIAL       PRIMARY KEY,
    title           VARCHAR(200)    NOT NULL,
    description     TEXT,
    status          task_status     NOT NULL DEFAULT 'TODO',
    priority        task_priority   NOT NULL DEFAULT 'MEDIUM',
    due_date        DATE,
    project_id      BIGINT          NOT NULL,                   -- FK → projects
    assignee_id     BIGINT,                                       -- FK → employees (nullable)
    created_by_id   BIGINT,                                       -- FK → users (audit trail)
    created_at      TIMESTAMP       NOT NULL DEFAULT NOW(),
    updated_at      TIMESTAMP       NOT NULL DEFAULT NOW(),

    CONSTRAINT fk_tasks_project
        FOREIGN KEY (project_id) REFERENCES projects(id)
        ON DELETE CASCADE                                         -- Delete project → delete its tasks
        ON UPDATE CASCADE,

    CONSTRAINT fk_tasks_assignee
        FOREIGN KEY (assignee_id) REFERENCES employees(id)
        ON DELETE SET NULL                                        -- Employee removed → task unassigned
        ON UPDATE CASCADE,

    CONSTRAINT fk_tasks_created_by
        FOREIGN KEY (created_by_id) REFERENCES users(id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
);

CREATE INDEX idx_tasks_project_id   ON tasks(project_id);
CREATE INDEX idx_tasks_assignee_id  ON tasks(assignee_id);
CREATE INDEX idx_tasks_status       ON tasks(status);
CREATE INDEX idx_tasks_due_date     ON tasks(due_date);
CREATE INDEX idx_tasks_priority     ON tasks(priority);

-- Composite index: common query "open tasks for a project sorted by due date"
CREATE INDEX idx_tasks_project_status_due ON tasks(project_id, status, due_date);

-- ---------------------------------------------------------------------------
-- OPTIONAL: project_members (Many-to-Many — Employee ↔ Project)
-- Use when multiple employees work on one project beyond the single "lead".
-- Uncomment if you implement team membership.
-- ---------------------------------------------------------------------------
-- CREATE TABLE project_members (
--     project_id   BIGINT NOT NULL REFERENCES projects(id) ON DELETE CASCADE,
--     employee_id  BIGINT NOT NULL REFERENCES employees(id) ON DELETE CASCADE,
--     joined_at    TIMESTAMP NOT NULL DEFAULT NOW(),
--     PRIMARY KEY (project_id, employee_id)                   -- Composite PK prevents duplicates
-- );
-- CREATE INDEX idx_project_members_employee_id ON project_members(employee_id);

-- ---------------------------------------------------------------------------
-- RELATIONSHIP SUMMARY
-- ---------------------------------------------------------------------------
-- roles        1 ──→ N  users
-- departments  1 ──→ N  employees
-- departments  1 ──→ N  projects
-- employees    1 ──→ N  projects   (as lead_employee_id, optional)
-- projects     1 ──→ N  tasks
-- employees    1 ──→ N  tasks      (as assignee_id, optional)
-- users        1 ──→ N  tasks      (as created_by_id, optional)

-- ---------------------------------------------------------------------------
-- SEED DATA (reference — app DataInitializer handles roles/admin in Java)
-- ---------------------------------------------------------------------------
-- INSERT INTO roles (name, created_at, updated_at) VALUES
--     ('ROLE_ADMIN', NOW(), NOW()),
--     ('ROLE_USER',  NOW(), NOW());
