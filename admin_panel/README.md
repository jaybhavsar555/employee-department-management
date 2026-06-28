# EMS Admin Panel (Flutter Web)

Flutter web admin dashboard for the [Employee & Department Management API](../README.md).

## Features

- JWT login (default admin: `admin` / `admin123`)
- Dashboard with department and employee stats
- Department CRUD (delete requires `ROLE_ADMIN`)
- Employee list with pagination, search, and department filter
- Employee CRUD (delete requires `ROLE_ADMIN`)
- Responsive layout (navigation rail on desktop, drawer + bottom nav on mobile)

## Prerequisites

- [FVM](https://fvm.app/) (recommended — see `.fvmrc`)
- Spring Boot API running at `http://localhost:8080`

## Run locally

```bash
# From repo root — start PostgreSQL and the API first
docker compose up -d
./mvnw spring-boot:run   # or mvnw.cmd on Windows

# Start the admin panel
cd admin_panel
fvm flutter pub get
fvm flutter run -d chrome
```

## Build for production

```bash
cd admin_panel
fvm flutter build web --release
```

Output is in `admin_panel/build/web/`.

## Configuration

Set a custom API URL at build or run time:

```bash
fvm flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8080/api/v1
```

## Project structure

```
lib/
├── core/           # API client, constants, exceptions
├── models/         # DTOs matching the REST API
├── services/       # HTTP service layer
├── providers/      # Riverpod state
├── router/         # go_router navigation + auth guard
├── theme/          # Material 3 theme
├── shared/         # Reusable widgets (shell, loading, dialogs)
└── features/       # Login, dashboard, departments, employees
```
