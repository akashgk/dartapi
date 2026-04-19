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










