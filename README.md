# DartAPI CLI

A CLI tool for scaffolding typed REST APIs in Dart, powered by [`dartapi_core`](https://pub.dev/packages/dartapi_core). Generate a minimal server, a full-featured app, or anything in between — then extend it with your own code.

Part of the [DartAPI](https://pub.dev/packages/dartapi) ecosystem.

---

## Installation

```bash
dart pub global activate dartapi
```

---

## Commands

### `dartapi create <project_name>`

Scaffolds a new project. Three modes are available:

#### Minimal (default)

A bare server with a single `GET /hello` endpoint. No auth, no database — start from a clean slate.

```bash
dartapi create my_app
```

Generated structure:

```
my_app/
├── bin/main.dart
├── lib/src/controllers/hello_controller.dart
├── env/.env
├── pubspec.yaml
└── analysis_options.yaml
```

#### With specific features (`--with`)

Add exactly the features you need. Combine multiple features with commas.

```bash
dartapi create my_app --with=auth
dartapi create my_app --with=db
dartapi create my_app --with=auth,db
dartapi create my_app --with=auth,db,files,ws
```

| Feature | What gets generated |
|---------|---------------------|
| `auth` | `AuthController`, `AuthService`, `LoginDTO`, `TokenResponse`, `User` model, `JwtService` wiring |
| `db` | `dartapi_db` dependency, `UserRepository`/`ProductRepository`, `MigrationRunner` wiring |
| `files` | `FilesController` with multipart upload support |
| `ws` | `WsController` with WebSocket echo handler |

Features compose cleanly — `--with=auth,db` generates a full auth flow backed by a real database.

#### Full scaffold (`--full`)

A kitchen-sink project with all features, a bootstrap architecture, and a `ServiceRegistry`-based DI setup.

```bash
dartapi create my_app --full
```

Generated structure:

```
my_app/
├── bin/main.dart
├── lib/src/
│   ├── controllers/    # AuthController, UserController, ProductController, FilesController, WsController
│   ├── dto/            # LoginDTO, UserDTO, ProductDTO, ResourceDTO
│   ├── models/         # User model
│   ├── repositories/   # UserRepository (in-memory + db variants), ProductRepository
│   ├── services/       # AuthService, UserService, ProductService
│   └── bootstrap.dart  # DI wiring via ServiceRegistry
├── migrations/
├── env/.env
├── pubspec.yaml
└── analysis_options.yaml
```

After scaffolding any mode:

```bash
cd my_app
dart pub get
dart run bin/main.dart
```

---

### `dartapi generate controller <Name>`

Adds a typed controller to an existing project:

```bash
dartapi generate controller Order
```

Generates `lib/src/controllers/order_controller.dart` with GET and POST stubs.

---

### `dartapi generate migration <name>`

Creates a numbered SQL migration file in `migrations/`:

```bash
dartapi generate migration create_orders_table
# → migrations/0001_create_orders_table.sql
```

---

### `dartapi db migrate`

Runs all pending migrations against the configured database.

---

### `dartapi run --port <port>`

Starts the server and watches for input:

- `r` — reload
- `:q` — quit

```bash
dartapi run --port=8080
```

### `dartapi run --isolates=N`

Spawns N Dart isolates all bound to the same port. The OS load-balances incoming connections across all isolates, utilising every CPU core.

```bash
dartapi run --isolates=4         # 4 isolates, one per core
```

---

### `dartapi build`

AOT-compiles the project to a self-contained native binary via `dart compile exe`. No VM startup cost; single binary deployment.

```bash
dartapi build                    # produces ./server
dartapi build --output=myapp     # custom binary name
dartapi build --docker           # also writes a Dockerfile
```

The `--docker` flag writes a two-stage `Dockerfile`: compiles in a `dart:stable` builder image, copies only the binary into a minimal `debian:bookworm-slim` runtime image.

```bash
dartapi build --docker
docker build -t my-app .
docker run -p 8080:8080 my-app
```

---

### `dartapi docs [--port=<port>] [--out=<file>]`

Exports the OpenAPI spec from a running server:

```bash
dartapi docs --out openapi.json
```

---

## The framework: `dartapi_core`

The CLI scaffolds projects that use `dartapi_core`. You can also use `dartapi_core` directly without the CLI — it's a standalone framework. See its [README](https://pub.dev/packages/dartapi_core) for documentation covering routing, validation, DI, JWT auth, middleware, OpenAPI, pagination, SSE, WebSockets, and more.

---

## Database Setup

When using `--with=db` or `--full`, update the `DbConfig` in `bin/main.dart` to point at your database:

```dart
final config = const DbConfig(
  type: DbType.postgres,
  host: 'localhost',
  port: 5432,
  database: 'dartapi_test',
  username: 'postgres',
  password: 'yourpassword',
  poolConfig: PoolConfig(maxConnections: 10),
);
```

Create the tables for the generated controllers:

```sql
CREATE TABLE users (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  email    TEXT NOT NULL UNIQUE
);

CREATE TABLE products (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10, 2) NOT NULL,
  quantity INTEGER NOT NULL
);
```

---

## Links

- [dartapi_core](https://pub.dev/packages/dartapi_core) — routing, validation, DI, auth, middleware
- [dartapi_db](https://pub.dev/packages/dartapi_db) — PostgreSQL, MySQL, SQLite
- [GitHub](https://github.com/akashgk/dartapi)
- [pub.dev](https://pub.dev/packages/dartapi)

---

## License

BSD 3-Clause License © 2025 Akash G Krishnan
