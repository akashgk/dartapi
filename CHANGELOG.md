## 0.1.39
- Generated project no longer crashes on `dartapi run` when no database is configured
- Add `DB_ENABLED` env var (default `false` in dev, `true` in staging/production); when false the app starts with in-memory repositories — no PostgreSQL needed
- Generated `main.dart` conditionally creates DB connection and runs migrations only when `DB_ENABLED=true`; falls back to `InMemoryUserRepository` / `InMemoryProductRepository` otherwise
- `app.onShutdown` uses `db?.close()` (db is now nullable)
- `AppConfig.dbEnabled` getter reads `DB_ENABLED`

## 0.1.38
- Fix generated `bin/main.dart`: `MigrationRunner(db).run()` → `.migrate()` (correct method name)
- Fix generated `bin/main.dart`: add `// ignore: avoid_print` on all startup debug `print` calls
- Fix generated `lib/src/dto/user_dto.dart`: `validateAll` now uses the correct `Map<String, void Function()>` signature; `EmailValidator` now receives its required message argument
- Fix generated `test/services/user_service_test.dart`: `UserDTO(...)` constructors are now `const`
- Fix generated `lib/src/config/app_config.dart`: wrap `.env.<APP_ENV>` in backticks in doc comment to suppress HTML angle-bracket warning

## 0.1.37
- Generated project upgraded to production-grade scaffold:
  - Full CRUD for Users and Products (GET list, GET by id, POST, PUT, DELETE) with 404 guards
  - Controller → Service → Repository enterprise architecture; `InMemoryXxxRepository` for dev/tests, `DbXxxRepository` for production
  - Multi-field validation in `UserDTO.fromJson` via `validateAll` (collects all errors before throwing 422)
  - Per-route 5-minute cache on `GET /products` with `X-Cache: HIT/MISS` header
  - Background task demo on `POST /products` (fires after 201 response is delivered)
  - `POST /auth/logout` endpoint that revokes the access token via `InMemoryTokenStore`
  - SQL migration files `0001_create_users_table.sql` and `0002_create_products_table.sql` generated in `migrations/`
  - Comprehensive `README.md` covering all features, full project structure, all running modes, complete API reference with request/response examples, middleware pipeline diagram, Prometheus metrics, production checklist, and extending guide
  - Full `UserService` test suite — `getUsers` (pagination, empty page), `getUser` (404), `createUser`, `updateUser` (success + reflect + 404), `deleteUser` (success + list + 404)
  - Auth test suite updated with `logout` group — verifies revoked token fails verification and logout completes without throw

## 0.1.36
- Add `dartapi build [--output=<name>] [--docker]` — AOT-compiles the project to a self-contained native binary via `dart compile exe`; `--docker` writes a multi-stage `Dockerfile` that produces a minimal `debian:bookworm-slim` runtime image
- Add `dartapi run --isolates=N` — spawns N Dart isolates all bound to the same port (`HttpServer.bind shared: true`), using every CPU core
- Generated `DartAPI.start()` gains a `shared: bool` parameter for multi-isolate mode
- Generated `DartAPI.enableMetrics()` — registers `GET /metrics` (Prometheus text format) and adds `metricsMiddleware` to the pipeline
- Generated `main.dart` reads `ISOLATES` env var, spawns N−1 extra isolates, and passes `shared: true` to `app.start()`
- Bump generated `dartapi_core` dep to `^0.0.24`

## 0.1.35
- Bump generated `dartapi_core` dep to `^0.0.22` (multi-field validation)
- Bump generated `dartapi_auth` dep to `^0.0.9` (refresh token rotation)

## 0.1.34
- Add `dartapi generate resource <Name>` — scaffolds a full CRUD resource: controller (GET list, GET by id, POST, PUT, DELETE), DTO with `fromJson`/`toMap`, and model with `Serializable`
- Generated controller uses `pathParam<int>`, `queryParam<int>`, `PaginatedResponse`, and returns `null` on DELETE for automatic 204 response
- Prints wiring instructions and next steps after generation

## 0.1.33
- Add `dartapi run --env=<environment>` — injects `APP_ENV` into the server process (`dartapi run --env=staging`)
- Combine with `--watch`: `dartapi run --env=dev --watch`
- Bump generated `dartapi_core` dep to `^0.0.21`

## 0.1.32
- Move generated env files from project root into `env/` subdirectory — `env/.env.dev`, `env/.env.staging`, `env/.env.uat`, `env/.env.production`, `env/.env.example`
- Update generated `main.dart` to load from `env/.env` and `env/.env.<APP_ENV>`
- Update generated `.gitignore` to exclude `env/.env*` (keeps `env/.env.example` committed)
- Add `dartapi run --watch` — watches `lib/` and `bin/` for `.dart` file changes and auto-restarts the server (500 ms debounce)

## 0.1.31
- `dartapi generate controller` now prints wiring instructions — shows the import and `app.addControllers([...])` call to add to `bin/main.dart`
- Bump generated `dartapi_core` dep to `^0.0.20` (fixes bool/num response serialization)

## 0.1.30
- Add generated `README.md` to scaffolded projects — covers project structure, per-environment run commands, environment variable reference, API endpoint table, migration and test commands
- Fix CORS: generated `DartAPI` class now accepts `corsOrigin` and uses `config.corsOrigin` instead of hardcoded `'*'`
- Add `AppConfig.validateForProduction()` — warns at startup when production runs with development JWT secrets

## 0.1.29
- Fix: replace `dotenv` external dependency with a built-in `env_loader.dart` (no version-resolution issues, zero extra deps)
- Generated `lib/src/config/env_loader.dart` provides `loadEnvFile(path)` and `mergeEnv(sources)` — handles comments, inline comments, and quoted values

## 0.1.28
- Fix: `dartapi create` now runs `dart pub get` automatically after scaffolding — packages are resolved immediately and IDEs show no missing-import errors

## 0.1.27
- Fix: generated `AuthController` test used `username: 'admin'` but controller checks `admin@mail.com` — corrected to match
- Add multi-environment support to generated projects: `.env.dev`, `.env.staging`, `.env.uat`, `.env.production` each scaffolded with appropriate defaults
- Add `.env.example` (committed) documenting all available environment variables
- Add `dotenv: ^4.2.1` to generated `pubspec.yaml` — `.env` and `.env.<APP_ENV>` are loaded at startup
- Generated `main.dart` now loads `DotEnv` before `AppConfig`, prints startup info in debug mode, and supports `--port=N` alongside `--port N`
- Generated `AppConfig` now has `AppEnvironment` enum, `isDev`/`isStaging`/`isUat`/`isProduction` helpers, per-env smart defaults for `debug`, `logLevel`, `jwtAccessExpiry`, `dbPoolSize`, and `corsOrigin`
- Add `.gitignore` to generated projects (excludes `.env.*` files, keeps `.env.example`)

## 0.1.26
- Bump generated `dartapi_core` dep to `^0.0.19`, `dartapi_auth` to `^0.0.8`, `dartapi_db` to `^0.0.10`

## 0.1.25
- Add `test/` suite: `utils_test.dart`, `create_command_constants_test.dart`, `generate_controller_test.dart`, `generate_migration_test.dart`
- Add `dart_test.yaml` with `concurrency: 1` to prevent CWD conflicts across test files
- Tests cover: `StringCasingExtension`, template placeholder substitution, scaffolded file tree, controller generation, and migration numbering

## 0.1.24
- Add `AppConfig` (`lib/src/config/app_config.dart`) to generated projects — typed env var config via `EnvConfig`
- Generated `main.dart` reads DB and JWT credentials from `AppConfig` instead of hardcoded strings
- Generated `DartAPI` class now exposes `enableHealthCheck()` which registers `GET /health`
- Bump generated `dartapi_core` dep to `^0.0.18`

## 0.1.23
- Fix: generated `AuthController.refreshToken` now parses request body as JSON instead of URL-encoded form data

## 0.1.22
- Fix: remove stale `bin/<name>.dart` and `lib/<name>.dart` generated by `dart create` (caused `avoid_print` warning)
- Fix: `page` and `limit` in generated `UserController.getAllUsers` are now commented out to avoid `unused_local_variable` warning
- Fix: add `const` to `ApiException` throws in generated `AuthController` and `ProductController` (`prefer_const_constructors`)

## 0.1.21
- Add `onStartup`/`onShutdown` lifecycle hooks to generated `DartAPI` class
- Shutdown hooks run on SIGINT and SIGTERM (SIGTERM skipped on Windows)
- Bump generated `dartapi_core` dep to `^0.0.16`

## 0.1.20
- Extract all scaffolded file contents into `.tmpl` files under `lib/templates/`
- Add `TemplateEngine` for `Isolate.resolvePackageUri`-based template loading and `{{placeholder}}` substitution
- `CreateCommandConstants.files()` is now async; `createProject` and `generateController` are now async
- `dartapi generate controller` uses `controller.dart.tmpl` instead of an inline string

## 0.1.19
- Bump generated `dartapi_core` dep to `^0.0.14`
- Generated `RouterManager` now registers `controller.webSocketRoutes` via `shelf_router`

## 0.1.18
- Bump generated `dartapi_core` dep to `^0.0.13`

## 0.1.17
- Improve README: remove emojis, fix broken content, add MySQL example

## 0.1.16
- Fix generated `AuthController`: invalid credentials now returns 401 (was 500); missing/invalid refresh token now returns 400/401
- Bump generated `dartapi_core` dep to `^0.0.11`

## 0.1.15
- Bump generated `dartapi_core` dep to `^0.0.10`

## 0.1.14
- Bump generated `dartapi_auth` dep to `^0.0.6`
- Bump generated `dartapi_db` dep to `^0.0.8`
- Generated `AuthController.refreshToken` now correctly `await`s `jwtService.verifyRefreshToken()`

## 0.1.13
- Add `dartapi generate migration <name>` — creates a numbered `.sql` file in `migrations/`
- Add `dartapi db migrate [--dry-run]` — runs `bin/migrate.dart` inside the project to apply pending migrations

## 0.1.12
- Bump generated `dartapi_core` dep to `^0.0.9`
- Generated `RouterManager` now tracks all collected routes via `collectedRoutes`
- Generated `DartAPI` class now has `enableDocs({title, version})` — call after `addControllers()` to serve `/docs`, `/redoc`, `/openapi.json`
- Generated `main.dart` now calls `app.enableDocs(title: projectName, version: '1.0.0')`
- Add `dartapi docs [--port=<port>] [--out=<file>]` CLI command to export OpenAPI spec from a running server

## 0.1.11
- Bump generated `dartapi_core` dep to `^0.0.7`
- Generated `UserController` now demonstrates query params (`page`, `limit`) and `statusCode: 201` on POST
- Generated `ProductController` now demonstrates path params (`GET /products/<id>`) and `statusCode: 201` on POST

## 0.1.10
- Add step-by-step running instructions to README
- Add Postman testing guide for all generated endpoints (auth, users, products)

## 0.1.9
- Update generated project templates to use latest package versions (`dartapi_db: ^0.0.7`, `dartapi_core: ^0.0.6`, `dartapi_auth: ^0.0.5`)
- Generated `main.dart` now includes `PoolConfig` in `DbConfig` to enable connection pooling by default

## 0.1.8
- Fix `dartapi run --port 8080` (space-separated) now works alongside `--port=8080`

## 0.1.7
- Add Documentation for Postgress for Generated Project
- Fixed issues related to Postgres parsing.

## 0.1.6
- upgrade Dartapi core

## 0.1.4
- Update Readme
- Fix Controller Generator

## 0.1.3
- Repo License Changes
- Fix Code Issues
- Add DartApi Core, Dartpi Db
- Improve Project scaffolding and structure.

## 0.1.1
- Add Stop and Reload Server Support.
- Add Demo test for controllers.


## 0.0.9
- Separate CORE logic to separeate DartApi_core package
- Add some linting rules

## 0.0.8
- Improve type safety for Api Request Response
- Implemented Common Serailization Validation
- Changed HTTP Methods.
- Add Meta Data for OpenAPi Implementation
- Add More logs

## 0.0.7
- CORS support

## 0.0.6
- dart format

## 0.0.5
✅ **Auth Middleware Support** - Add Auth Middleware support for each route.
✅ **Auth Middleware Template** - Add Auth Middleware template.
✅ **Fix Middleware loggin** - Fix a Middle ware logging issue which prevented logs on dartapi run
✅ **Add Default to CLI**


## 0.0.4
✅ **Custom Middleware Support** - Add Custom Middleware support for each route.


## 0.0.3
✅ **Request Validation Middleware** - Request Validation using MiddleWare support Added and template generated


## 0.0.2
✅ **CLI Tool** - Generate projects, controllers, and models using the `dartapi` CLI.


## 0.0.1
✅ **Fast and lightweight** - Minimal dependencies, optimized for speed.  
✅ **Easy to use** - Simple setup and minimal boilerplate.  
✅ **Configurable port** - Start the server with a custom port (`--port=<number>`).  
✅ **Dynamic routing** - Automatically registers controllers and their routes.  
✅ **Middleware support** - Includes logging and future authentication middleware.  
✅ **CLI Tool** - Generate projects, controllers, and models using the `dartapi` CLI.  










