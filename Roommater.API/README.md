# Roommater.API

ASP.NET Core 8 Web API backend for the Roommater Flutter app.

Base URL: `http://localhost:5073/api/`

## Tech Stack

- ASP.NET Core 8 Web API
- Entity Framework Core 8 (Code First)
- MySQL provider (Pomelo Entity Framework Core)
- JWT authentication
- AutoMapper
- Data Annotations validation
- Swagger/OpenAPI

## Project Structure

```text
Roommater.API/
├── Controllers/
├── Models/
├── DTOs/
├── Services/
├── Data/
│   ├── AppDbContext.cs
│   ├── DbSeeder.cs
│   └── Migrations/
├── Middleware/
├── Mappings/
├── Program.cs
├── appsettings.json
└── appsettings.Development.json
```

## Configuration

Set values in `appsettings.json`:

- `ConnectionStrings:DefaultConnection`
- `Jwt:Secret`
- `Jwt:Issuer`
- `Jwt:Audience`
- `Jwt:ExpiryDays`

> Important: replace the default `Jwt:Secret` before running in any shared or production environment. Prefer overriding it with environment variables or secret stores.

Example MySQL connection string (`ConnectionStrings:DefaultConnection`):

```text
Server=localhost;Port=3306;Database=RoommaterDb;User=roommater_dev;Password=<your-dev-password>;
```

Optional MySQL server version setting used by EF Core provider:

```text
MySql:ServerVersion=8.0.36-mysql
```

Use a local development user with limited permissions (not root), and override credentials via environment variables or user secrets outside source control.

## Run Locally

From repository root:

```bash
dotnet tool restore
dotnet restore Roommater.API/Roommater.API.csproj
dotnet build Roommater.API/Roommater.API.csproj
```

### Migrations

Create migration:

```bash
dotnet ef migrations add <MigrationName> --project Roommater.API/Roommater.API.csproj --output-dir Data/Migrations
```

Apply migration:

```bash
dotnet ef database update --project Roommater.API/Roommater.API.csproj
```

### Start API

```bash
dotnet run --project Roommater.API/Roommater.API.csproj
```

If you want to use different local database credentials without editing tracked files, override the connection string at runtime:

```bash
ConnectionStrings__DefaultConnection="Server=localhost;Port=3306;Database=RoommaterDb;User=roommater_dev;Password=<your-dev-password>;" \
dotnet run --project Roommater.API/Roommater.API.csproj
```

API runs on:

- `http://localhost:5073`
- Swagger: `http://localhost:5073/swagger`

## Authentication

Use JWT Bearer token in `Authorization` header:

```text
Authorization: Bearer <token>
```

Public endpoints:

- `POST /api/auth/signup`
- `POST /api/auth/signin`

All other endpoints require auth.

## Seed Data

On startup, migrations are applied and sample seed data is inserted once when the database is empty:

- Sample users
- One household
- Tasks
- Events
- Grocery items

## Error Response Format

Errors are returned as:

```json
{ "message": "Error description here" }
```

## Main Endpoint Groups

- `/api/auth`
- `/api/users`
- `/api/households`
- `/api/households/{householdId}/tasks`
- `/api/households/{householdId}/events`
- `/api/households/{householdId}/grocery`
- `/api/households/{householdId}/expenses`
- `/api/chats`
- `/api/listings`
- `/api/notifications`
