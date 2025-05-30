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

## 🧪 Example Usage

```bash
dartapi create my_app
cd my_app
dart pub get
dartapi run --port=8080
```

Now open Postman and test `/users` or `/auth/login`.

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