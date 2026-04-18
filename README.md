# DartAPI CLI

**DartAPI** is a modular and developer-friendly CLI tool for building robust, typed REST APIs using the Dart language.  
Rather than acting as a heavy, opinionated framework, DartAPI provides powerful code generation tools that let you build scalable backend applications with clean architecture, JWT authentication, request validation, and PostgreSQL/MySQL support.

---

## 📦 What It Does

- ✅ Project scaffolding (`dartapi create`)
- ✅ Controller generation (`dartapi generate controller`)
- ✅ Hot-reload style dev server with keyboard controls (`dartapi run`)
- ✅ Integrated with:
  - [dartapi_core](https://pub.dev/packages/dartapi_core)
  - [dartapi_auth](https://pub.dev/packages/dartapi_auth)
  - [dartapi_db](https://pub.dev/packages/dartapi_db)

---

## 🚀 Installation

Activate globally:

```bash
dart pub global activate dartapi
```

---

## 📁 CLI Commands

### `dartapi create <project_name>`

Creates a full DartAPI project with:
- `bin/main.dart`
- Controllers (`UserController`, `AuthController`, `ProductController`)
- Middleware (`logging`, `auth`)
- JWT setup with `dartapi_auth`
- DB support with `dartapi_db`
- DTOs and validation helpers
- Auto schema definitions for future Swagger support


---
There are no additional items we need to required to run the generated project.

`Note`: that this is not mandatory. You can remove the product controller and DB related code from 
the main.dart file if you don't need it.

But if you want to use the product controller, you need to install the `postgres` DB.


🔧 Step 1: Install PostgreSQL

✅ On macOS (using Homebrew):

```bash
brew install postgresql@14
brew services start postgresql@14
```

✅ On Ubuntu / Debian:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl enable postgresql
sudo systemctl start postgresql
```


✅ On Windows:


	•	Download the PostgreSQL installer from: https://www.postgresql.org/download/windows/
	•	Use the graphical installer to complete the setup.


  📦 Step 2: Create a Database

  Run the following commands in your terminal or psql:

```sql
psql postgres
```
Then in the psql prompt:
```sql
CREATE DATABASE dartapi_test;
CREATE USER dartuser WITH ENCRYPTED PASSWORD 'postgres';
GRANT ALL PRIVILEGES ON DATABASE dartapi_test TO dartuser;
```

Update your DbConfig in main.dart as per your configuration:


---


### `dartapi generate controller <Name>`

Adds a controller to an existing DartAPI project:

```bash
dartapi generate controller Product
```

Generates `lib/src/controllers/product_controller.dart` with GET and POST methods and proper typing.

---

### `dartapi run --port <port>`

Runs your DartAPI server using `bin/main.dart`.  
You can control it interactively:

- Type `:q` to quit
- Type `r` to reload

```bash
dartapi run --port=8080
```

---

## ▶️ Running a Generated Project

After scaffolding, follow these steps to get the server running:

**1. Create and enter your project**
```bash
dartapi create my_app
cd my_app
```

**2. Install dependencies**
```bash
dart pub get
```

**3. (Optional) Set up the database**

If you want to use `ProductController`, make sure PostgreSQL is running and update the `DbConfig` in `bin/main.dart` with your credentials:

```dart
final config = const DbConfig(
  type: DbType.postgres,
  host: 'localhost',
  port: 5432,
  database: 'dartapi_test',
  username: 'postgres',
  password: 'yourpassword',          // ← change this
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

If you don't need DB support, remove `ProductController` from `main.dart` and delete `product_controller.dart`.

**4. Start the server**
```bash
dartapi run --port=8080
```

You should see:
```
🚀 Server running on http://localhost:8080
```

---

## 🧪 Testing with Postman

The generated project includes three controllers with the following endpoints. Import the requests below into Postman to test them.

### Auth endpoints

#### `POST /auth/login`

Returns a JWT access token and refresh token.

- **URL**: `http://localhost:8080/auth/login`
- **Method**: POST
- **Body** (raw JSON):
```json
{
  "username": "admin@mail.com",
  "password": "1234"
}
```
- **Response**:
```json
{
  "accessToken": "<jwt_access_token>",
  "refreshToken": "<jwt_refresh_token>"
}
```

Copy the `accessToken` value — you'll need it as a Bearer token for protected routes.

---

#### `POST /auth/refresh`

Exchanges a valid refresh token for a new access token.

- **URL**: `http://localhost:8080/auth/refresh`
- **Method**: POST
- **Body** (x-www-form-urlencoded):

| Key | Value |
|-----|-------|
| `refresh_token` | `<your_refresh_token>` |

- **Response**:
```json
{
  "access_token": "<new_jwt_access_token>"
}
```

---

### User endpoints

#### `GET /users`

Returns a list of users. Requires authentication.

- **URL**: `http://localhost:8080/users`
- **Method**: GET
- **Headers**:

| Key | Value |
|-----|-------|
| `Authorization` | `Bearer <access_token>` |

- **Response**:
```json
["Christy", "Akash"]
```

---

#### `POST /users`

Creates a new user.

- **URL**: `http://localhost:8080/users`
- **Method**: POST
- **Body** (raw JSON):
```json
{
  "name": "Jane",
  "age": 28,
  "email": "jane@example.com"
}
```
- **Response**:
```
User Jane created
```

---

### Product endpoints

> **Requires a running PostgreSQL database** with the `products` table created (see setup above).

All product endpoints require an `Authorization: Bearer <access_token>` header.

#### `GET /products`

Returns all products from the database.

- **URL**: `http://localhost:8080/products`
- **Method**: GET
- **Headers**:

| Key | Value |
|-----|-------|
| `Authorization` | `Bearer <access_token>` |

- **Response**:
```json
[
  { "id": 1, "name": "Keyboard", "price": 29.99, "quantity": 15 }
]
```

---

#### `POST /products`

Inserts a new product into the database.

- **URL**: `http://localhost:8080/products`
- **Method**: POST
- **Headers**:

| Key | Value |
|-----|-------|
| `Authorization` | `Bearer <access_token>` |

- **Body** (raw JSON):
```json
{
  "name": "Keyboard",
  "price": 29.99,
  "quantity": 15
}
```
- **Response**:
```json
{ "id": 1, "name": "Keyboard", "price": 29.99, "quantity": 15 }
```

---

### Suggested Postman flow

1. Call `POST /auth/login` → copy `accessToken`
2. Set a Postman environment variable `token` = `<accessToken>`
3. Use `Authorization: Bearer {{token}}` in all protected requests
4. Call `POST /products` to insert a product, then `GET /products` to verify

---

## 🧱 Generated Project Structure

```
my_app/
├── bin/
│   └── main.dart
├── lib/
│   └── src/
│       ├── core/           # Server/router setup
│       ├── controllers/    # UserController, AuthController, etc.
│       ├── dto/            # DTOs with schema
│       ├── db/             # DB connection logic
│       ├── middleware/     # Auth/logging middleware
│       └── utils/          # Validation, helpers
├── pubspec.yaml
└── analysis_options.yaml
```

---

## ✅ Why Use DartAPI?

- Minimal but powerful
- Follows clean architecture principles
- Type-safe routing using `ApiRoute<ApiInput, ApiOutput>`
- Built-in JWT auth and DB integration
- Ready to extend with OpenAPI/Swagger

---

Checkout the [Medium article](https://medium.com/@krishnanag1996/dartapi-build-scalable-backends-in-dart-with-a-modular-api-toolkit-6b12f97cb94a) for more details.

---

## 📄 License

BSD 3-Clause License © 2025 Akash G Krishnan  
[LICENSE](./LICENSE)

---

## 🌐 Links

- 📦 Pub.dev: [dartapi](https://pub.dev/packages/dartapi)
- 🛠️ GitHub: [github.com/akashgk/dartapi](https://github.com/akashgk/dartapi)
