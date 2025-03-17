# 🚀 DartAPI - A Lightweight FastAPI-like Framework for Dart

DartAPI is a **lightweight** and **developer-friendly** framework for building fast, modern, and scalable APIs using Dart.

## 📌 Features
✅ **Fast and lightweight** - Minimal dependencies, optimized for speed.  
✅ **Easy to use** - Simple setup and minimal boilerplate.  
✅ **Configurable port** - Start the server with a custom port (`--port=<number>`).  
✅ **Dynamic routing** - Automatically registers controllers and their routes.  
✅ **Middleware support** - Includes logging and future authentication middleware.  
✅ **CLI Tool** - Generate projects, controllers, and models using the `dartapi` CLI.  

---

## 🔧 **Installation**
To use DartAPI globally, install it via Dart's package manager:

```sh
dart pub global activate dartapi
```

After activation, you can use the dartapi CLI to create projects and manage your API.

---

**📦 Creating a New API Project**

```sh
dartapi create my_project
cd my_project
dart pub get
```

---
**🚀 Running the Server**

You can start the API server using:


**1️⃣ Default Port (8080)**
```sh
dartapi run
```

**1️⃣ Custom Port (8080)**
```sh
dartapi run --port=3000
```

Alternatively, run it directly via Dart:
```sh
dart run bin/main.dart --port=3000
```

**✅ Expected Output:**

🚀 Server running on http://localhost:3000

---
**🔥 API Routes**

The boilerplate comes with the following methods

| Method | Route   | Description         |
|--------|--------|----------------------|
| GET    | /users | Fetch list of users  |
| POST   | /users | Create a new user    |


#### Example Request (Using cURL)

```sh
curl -X GET http://localhost:8080/users
```

✅ Response:

```sh
{"users": ["Christy", "Akash"]}
```

---

**🛠 Generating a Controller**

```sh
dartapi generate controller Product
```

✅ Creates:
```sh
lib/src/controllers/product_controller.dart
```
The generated controller includes:

```

import 'package:shelf/shelf.dart';
import 'base_controller.dart';

class ProductController extends BaseController {
  @override
  List<RouteDefinition> get routes => [
        RouteDefinition('GET', '/products', getAllProducts),
        RouteDefinition('POST', '/products', createProduct),
      ];

  Response getAllProducts(Request request) {
    return Response.ok('{"products": ["Laptop", "Phone"]}', headers: {'Content-Type': 'application/json'});
  }

  Response createProduct(Request request) {
    return Response.ok('{"message": "Product created"}', headers: {'Content-Type': 'application/json'});
  }
}
```


✅ Now accessible at:

	•	GET /products
	•	POST /products


---

**🛠 Middleware**

DartAPI includes middleware support. The default logging middleware logs all requests:

Example Middleware (lib/src/middleware/logging.dart)

```

import 'package:shelf/shelf.dart';

Middleware loggingMiddleware() {
  return (Handler innerHandler) {
    return (Request request) async {
      print("📌 Request: \${request.method} \${request.requestedUri}");
      final response = await innerHandler(request);
      return response;
    };
  };
}
```
✅ Adding Middleware in server.dart:

```

final handler = Pipeline()
    .addMiddleware(loggingMiddleware()) 
    .addHandler(_router.handler.call);

```
---
🗄 Database Setup (Planned Feature)

Currently, DartAPI provides a placeholder for database connections:
```

class Database {
  static void connect() {
    print('🔗 Connecting to database...');
  }
}

In future versions, we will support:
- ✅ PostgreSQL, SQLite, MongoDB
- ✅ Database models with dartapi generate model User
- ✅ Migrations (dartapi migrate db)
```

---
**🎯 Planned Features**


- 📌 Swagger UI (/docs route for API documentation)
- 📌 Authentication System (JWT Middleware)
- 📌 WebSocket Support (/ws for real-time communication)
- 📌 Database ORM Integration (PostgreSQL, SQLite, MongoDB)
- 📌 Task Scheduling (Cron Jobs, Background Tasks)
- 📌 Deployment Support (docker and dartapi deploy)


---

**📝 License**

This project is open-source under the MIT License.

---


**🚀 Get Started Now!**

```
dartapi create my_project
cd my_project
dart pub get
dartapi run --port=8080
```


**✅ Start building APIs with Dart! 🚀🚀🚀**


---
**✅ Adding Auth! 🚀🚀🚀**

Add the dartapi_auth package.
```sh
dart pub add dartapi_auth
```

Currently there is support for JWT using Auth Middleware.

```
   final jwtService = JwtService(
    accessTokenSecret: 'super-secret-key',
    refreshTokenSecret: 'super-refresh-secret',
    issuer: 'dartapi',
    audience: 'dartapi-users',
  );
  ```


  Add the `authMiddleware` Middle ware to the route definition.

  ```
RouteDefinition('GET', '/users', getAllUsers, middlewares: [authMiddleware(jwtService)]),
```
