# DartAPI — FastAPI Parity Roadmap

This document tracks everything needed to make DartAPI a serious FastAPI equivalent for Dart backends.

**Current stack:**
- `dartapi` v0.1.10 — CLI (create, run, generate)
- `dartapi_core` v0.0.6 — typed routing, validation, middleware
- `dartapi_auth` v0.0.5 — JWT (HS256), auth middleware
- `dartapi_db` v0.0.7 — PostgreSQL + MySQL with connection pooling

---

## Phase 1 — Core Routing Improvements (`dartapi_core`)

FastAPI makes path params, query params, and response codes first-class citizens. Dartapi currently ignores them.

### 1.1 Path parameter extraction
Shelf's router already handles `:id` in paths — expose a utility so handlers can read them without casting `request.params`:

```dart
// goal
Future<User> getUser(Request request, void _) async {
  final id = request.pathParam<int>('id');
  ...
}
```

**Files:** `dartapi_core/lib/src/utils/extensions.dart`, `dartapi_core/lib/src/core/api_route.dart`

### 1.2 Query parameter utilities
Add typed query param extraction:

```dart
final page = request.queryParam<int>('page', defaultValue: 1);
final search = request.queryParam<String>('q');
```

**Files:** `dartapi_core/lib/src/utils/extensions.dart`

### 1.3 Custom response status codes
Handlers always return 200. Add a way to return 201 on create, 204 on delete, etc.:

```dart
ApiRoute(
  method: ApiMethod.post,
  path: '/users',
  statusCode: 201,       // new field
  typedHandler: createUser,
)
```

**Files:** `dartapi_core/lib/src/core/api_route.dart`

### 1.4 Global exception handler
Let the app register a custom catch-all handler for unhandled exceptions instead of always returning a generic 500:

```dart
app.onError((error, stackTrace) => ApiException(503, 'Service unavailable'));
```

**Files:** app-level setup in generated `dartapi.dart`

---

## Phase 2 — OpenAPI / Swagger Generation (`dartapi_core`)

The single biggest FastAPI differentiator. All the metadata is already on `ApiRoute` (`summary`, `description`, `requestSchema`, `responseSchema`, `method`, `path`) — it just needs to be collected and serialized.

### 2.1 OpenAPI 3.0 spec generator
Walk all registered routes and emit an OpenAPI 3.0 JSON document:

```json
{
  "openapi": "3.0.0",
  "info": { "title": "My App", "version": "1.0.0" },
  "paths": {
    "/users": {
      "get": {
        "summary": "Get all users",
        "responses": { "200": { "description": "Success" } }
      }
    }
  }
}
```

**New file:** `dartapi_core/lib/src/openapi/openapi_generator.dart`

### 2.2 Swagger UI endpoint
Serve Swagger UI at `/docs` using a CDN-hosted bundle (no extra deps needed — serve the HTML inline):

```dart
app.enableDocs(title: 'My App', version: '1.0.0');
// serves: GET /docs        → Swagger UI
//         GET /redoc       → ReDoc
//         GET /openapi.json → raw spec
```

**New file:** `dartapi_core/lib/src/openapi/swagger_handler.dart`

### 2.3 Security scheme support
Annotate routes with security requirements so Swagger UI shows the lock icon and lets users paste tokens:

```dart
ApiRoute(
  ...
  security: [SecurityScheme.bearer],
)
```

**New file:** `dartapi_core/lib/src/openapi/security_scheme.dart`

### 2.4 CLI: generate docs command
```bash
dartapi docs                    # prints openapi.json to stdout
dartapi docs --out openapi.json
```

**New file:** `dartapi/lib/cli/generate_docs.dart`

---

## Phase 3 — Database: Transactions & Migrations (`dartapi_db`)

### 3.1 Transaction support
Add `transaction()` to `DartApiDB`:

```dart
await db.transaction((tx) async {
  await tx.insert('orders', orderData);
  await tx.insert('order_items', itemData);
});
```

- PostgreSQL: uses `Pool.runTx()` (available in postgres package)
- MySQL: uses `MySQLConnectionPool.transactional()`

**Files:** `dartapi_db/lib/core/dartapi_db_core.dart`, both drivers

### 3.2 Schema migration system
A lightweight migration runner (Flyway-style, not a full ORM):

```
migrations/
├── 0001_create_users.sql
├── 0002_add_email_index.sql
└── 0003_create_products.sql
```

- `DartApiDB.migrate()` — runs pending migrations in order
- Tracks applied migrations in a `_dartapi_migrations` table
- `dartapi db migrate` — CLI command

**New file:** `dartapi_db/lib/migrations/migration_runner.dart`  
**New CLI file:** `dartapi/lib/cli/migrate.dart`

### 3.3 SQLite support
Add a `SqliteDatabase` driver using the `sqlite3` package for local/embedded use:

```dart
final config = DbConfig(type: DbType.sqlite, database: 'app.db');
```

**New file:** `dartapi_db/lib/drivers/sqlite/sqlite_database.dart`  
**Modified:** `dartapi_db/lib/types/db_type.dart`, `dartapi_db/lib/factory/database_factory.dart`

---

## Phase 4 — Auth Improvements (`dartapi_auth`)

### 4.1 RS256 / asymmetric key support
Allow RS256 (and ES256) for JWTs so public keys can be shared with other services:

```dart
final jwtService = JwtService.asymmetric(
  privateKey: '-----BEGIN RSA PRIVATE KEY-----...',
  publicKey: '-----BEGIN PUBLIC KEY-----...',
  algorithm: JWTAlgorithm.RS256,
);
```

**File:** `dartapi_auth/lib/src/jwt_service.dart`

### 4.2 Token revocation / blacklist
Add an injectable `TokenStore` interface. Default is in-memory; users can provide a Redis/DB-backed store:

```dart
final jwtService = JwtService(
  ...,
  tokenStore: InMemoryTokenStore(),  // or RedisTokenStore(client)
);

// In logout handler:
await jwtService.revokeToken(token);
```

**New file:** `dartapi_auth/lib/src/token_store.dart`  
**Modified:** `dartapi_auth/lib/src/jwt_service.dart`, `dartapi_auth/lib/src/auth_middleware.dart`

### 4.3 API key authentication
Add `apiKeyMiddleware()` alongside `authMiddleware()`:

```dart
ApiRoute(
  middlewares: [apiKeyMiddleware(validKeys: {'abc123', 'xyz789'})],
  ...
)
```

**New file:** `dartapi_auth/lib/src/api_key_middleware.dart`

---

## Phase 5 — Middleware (`dartapi_core`)

### 5.1 Rate limiting middleware
Token-bucket rate limiter, keyed by IP or user ID:

```dart
.addMiddleware(rateLimitMiddleware(
  maxRequests: 100,
  window: Duration(minutes: 1),
))
```

**New file:** `dartapi_core/lib/src/middleware/rate_limit_middleware.dart`

### 5.2 Request ID middleware
Attach a unique `X-Request-Id` header to every request/response for distributed tracing:

```dart
.addMiddleware(requestIdMiddleware())
```

**New file:** `dartapi_core/lib/src/middleware/request_id_middleware.dart`

### 5.3 Response compression
Gzip responses above a configurable size threshold:

```dart
.addMiddleware(compressionMiddleware())
```

**New file:** `dartapi_core/lib/src/middleware/compression_middleware.dart`

---

## Phase 6 — Advanced Features

### 6.1 File uploads (`dartapi_core`)
Parse `multipart/form-data` in handlers:

```dart
Future<String> uploadAvatar(Request request, void _) async {
  final file = await request.file('avatar');
  // file.bytes, file.filename, file.contentType
}
```

**New file:** `dartapi_core/lib/src/utils/multipart.dart`

### 6.2 Background tasks (`dartapi_core`)
Run work after the response is sent (like FastAPI's `BackgroundTasks`):

```dart
Future<String> sendWelcome(Request request, UserDTO? dto) async {
  request.backgroundTask(() => emailService.sendWelcome(dto!.email));
  return 'User created';
}
```

**New file:** `dartapi_core/lib/src/core/background_task.dart`

### 6.3 WebSocket support (`dartapi_core`)
Add a `WebSocketRoute` alongside `ApiRoute`:

```dart
WebSocketRoute(
  path: '/ws/chat',
  handler: (channel) async {
    await for (final message in channel.stream) { ... }
  },
)
```

**New file:** `dartapi_core/lib/src/core/websocket_route.dart`

---

## Phase 7 — CLI & DX Improvements (`dartapi`)

### 7.1 External template files
Replace the 694-line `create_command_constants.dart` hardcoded strings with `.tmpl` files loaded at runtime. Easier to maintain and diff.

**Refactor:** `dartapi/lib/constants/` → `dartapi/lib/templates/`

### 7.2 `dartapi generate migration <name>`
```bash
dartapi generate migration create_users_table
# creates: migrations/0001_create_users_table.sql
```

**New file:** `dartapi/lib/cli/generate_migration.dart`

### 7.3 `dartapi db migrate`
```bash
dartapi db migrate          # run pending migrations
dartapi db migrate --dry-run
```

**New file:** `dartapi/lib/cli/run_migrations.dart`

---

## Priority Order

| # | Feature | Package | Impact |
|---|---------|---------|--------|
| 1 | OpenAPI/Swagger generation | dartapi_core | ⭐⭐⭐⭐⭐ |
| 2 | Path & query param utilities | dartapi_core | ⭐⭐⭐⭐⭐ |
| 3 | Transaction support | dartapi_db | ⭐⭐⭐⭐ |
| 4 | Migration system | dartapi_db | ⭐⭐⭐⭐ |
| 5 | Custom response status codes | dartapi_core | ⭐⭐⭐⭐ |
| 6 | Rate limiting middleware | dartapi_core | ⭐⭐⭐ |
| 7 | RS256 support | dartapi_auth | ⭐⭐⭐ |
| 8 | Token revocation | dartapi_auth | ⭐⭐⭐ |
| 9 | SQLite support | dartapi_db | ⭐⭐⭐ |
| 10 | File uploads | dartapi_core | ⭐⭐⭐ |
| 11 | Background tasks | dartapi_core | ⭐⭐ |
| 12 | WebSocket support | dartapi_core | ⭐⭐ |
| 13 | API key auth | dartapi_auth | ⭐⭐ |
| 14 | Request ID middleware | dartapi_core | ⭐⭐ |
| 15 | Response compression | dartapi_core | ⭐⭐ |
| 16 | External CLI templates | dartapi | ⭐⭐ |
| 17 | `generate migration` CLI | dartapi | ⭐⭐ |
