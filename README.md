# DartAPI CLI

DartAPI is a CLI tool for scaffolding and running typed REST APIs in Dart. It generates a full project structure with routing, JWT authentication, request validation, database integration, and OpenAPI documentation — ready to extend.

Part of the [DartAPI](https://pub.dev/packages/dartapi) ecosystem.

---

## Installation

```bash
dart pub global activate dartapi
```

---

## Commands

### `dartapi create <project_name>`

Scaffolds a new project with:

- `bin/main.dart` — server entry point
- `AuthController`, `UserController`, `ProductController` — example controllers
- JWT setup via `dartapi_auth`
- Database connection via `dartapi_db`
- DTOs with validation
- OpenAPI documentation at `/docs`

```bash
dartapi create my_app
cd my_app
dart pub get
dartapi run --port=8080
```

### `dartapi generate controller <Name>`

Adds a typed controller to an existing project:

```bash
dartapi generate controller Order
```

Generates `lib/src/controllers/order_controller.dart` with GET and POST stubs.

### `dartapi run --port <port>`

Starts the server and watches for input:

- `r` — reload
- `:q` — quit

```bash
dartapi run --port=8080
```

### `dartapi docs [--port=<port>] [--out=<file>]`

Exports the OpenAPI spec from a running server:

```bash
dartapi docs --out openapi.json
```

### `dartapi generate migration <name>`

Creates a numbered SQL migration file in `migrations/`:

```bash
dartapi generate migration create_orders_table
# → migrations/0001_create_orders_table.sql
```

### `dartapi db migrate`

Runs all pending migrations against the configured database.

---

## Generated Project Structure

```
my_app/
├── bin/
│   └── main.dart
├── lib/
│   └── src/
│       ├── core/           # Server and router setup
│       ├── controllers/    # AuthController, UserController, ProductController
│       ├── dto/            # Typed request DTOs
│       ├── db/             # Database connection
│       ├── middleware/     # Auth and logging middleware
│       └── utils/          # Validation helpers
├── pubspec.yaml
└── analysis_options.yaml
```

---

## Database Setup (optional)

The generated `ProductController` requires a PostgreSQL database. If you don't need it, remove `ProductController` from `main.dart`.

To use it, update the `DbConfig` in `bin/main.dart`:

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

Then create the `products` table:

```sql
CREATE TABLE products (
  id       SERIAL PRIMARY KEY,
  name     TEXT NOT NULL,
  price    NUMERIC(10, 2) NOT NULL,
  quantity INTEGER NOT NULL
);
```

---

## API Reference (generated project)

### `POST /auth/login`

```json
{ "username": "admin@mail.com", "password": "1234" }
```

Response:

```json
{ "accessToken": "<jwt>", "refreshToken": "<jwt>" }
```

### `POST /auth/refresh`

Body (form-encoded): `refresh_token=<token>`

Response:

```json
{ "access_token": "<new_jwt>" }
```

### `GET /users`

Requires `Authorization: Bearer <access_token>`.

### `POST /users`

```json
{ "name": "Jane", "age": 28, "email": "jane@example.com" }
```

### `GET /products` / `POST /products`

Requires `Authorization: Bearer <access_token>` and a running PostgreSQL database.

`POST /products` body:

```json
{ "name": "Keyboard", "price": 29.99, "quantity": 15 }
```

---

## Links

- [dartapi_core](https://pub.dev/packages/dartapi_core) — routing, validation, middleware
- [dartapi_auth](https://pub.dev/packages/dartapi_auth) — JWT auth, API key middleware
- [dartapi_db](https://pub.dev/packages/dartapi_db) — PostgreSQL, MySQL, SQLite
- [GitHub](https://github.com/akashgk/dartapi)
- [pub.dev](https://pub.dev/packages/dartapi)

---

## License

BSD 3-Clause License © 2025 Akash G Krishnan
