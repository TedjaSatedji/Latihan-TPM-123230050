# Flutter Quiz Study Guide

This guide is based on this repo's structure. The goal is not to memorize every line, but to remember the patterns so you can rebuild a similar app during a quiz.

## App Overview

This project is a Flutter app that has:

- Login and register
- Local SQLite database for users
- Saved login session with SharedPreferences
- API fetching with HTTP
- List page
- Detail page
- Navigation with GetX
- Reactive loading, error, and data states

The main flow is:

```text
main.dart
  SplashScreen checks saved login session
  -> LoginPage or MainPage

LoginPage
  -> AuthController
  -> DatabaseHelper
  -> SharedPreferences

MainPage
  -> category buttons

ListPage
  -> DataController.fetchList()
  -> ListView.builder

DetailPage
  -> DataController.fetchDetail()
  -> detail UI
```

## Important Packages

In `pubspec.yaml`, the important packages are:

```yaml
dependencies:
  get: ^4.7.3
  http: ^1.6.0
  path: ^1.9.1
  shared_preferences: ^2.5.5
  sqflite: ^2.4.2+1
  url_launcher: ^6.3.2
```

What they do:

- `get`: state management, navigation, snackbar
- `http`: fetch data from API
- `path`: join database path safely
- `shared_preferences`: save small local values like login status
- `sqflite`: local SQLite database
- `url_launcher`: open external URLs

## Basic Flutter Page Pattern

Memorize this structure:

```dart
import 'package:flutter/material.dart';

class MyPage extends StatelessWidget {
  const MyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title'),
      ),
      body: const Center(
        child: Text('Hello'),
      ),
    );
  }
}
```

Common widgets to remember:

- `Scaffold`
- `AppBar`
- `Center`
- `Column`
- `Row`
- `Padding`
- `SizedBox`
- `Text`
- `TextField`
- `ElevatedButton`
- `TextButton`
- `IconButton`
- `ListView.builder`
- `ListTile`
- `Card`
- `Image.network`
- `CircularProgressIndicator`
- `SingleChildScrollView`
- `FloatingActionButton`

## GetX Basics

GetX is used for:

- State management
- Navigation
- Snackbars
- Dependency/controller access

Use `GetMaterialApp` instead of `MaterialApp`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'My App',
      home: const HomePage(),
    );
  }
}
```

## GetX Controller Example

A controller stores logic and state:

```dart
import 'package:get/get.dart';

class CounterController extends GetxController {
  var count = 0.obs;

  void increment() {
    count.value++;
  }

  void reset() {
    count.value = 0;
  }
}
```

Important GetX state rules:

```dart
var count = 0.obs;
```

This makes `count` reactive.

```dart
count.value
```

Use `.value` to read or change reactive values.

```dart
Obx(() {
  return Text('${controller.count.value}');
});
```

`Obx` automatically rebuilds when reactive values change.

## GetX Page Example

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'counter_controller.dart';

class CounterPage extends StatelessWidget {
  const CounterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(CounterController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('GetX Example'),
      ),
      body: Center(
        child: Obx(() {
          return Text(
            'Count: ${controller.count.value}',
            style: const TextStyle(fontSize: 24),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.increment,
        child: const Icon(Icons.add),
      ),
    );
  }
}
```

Important lines:

```dart
final controller = Get.put(CounterController());
```

Creates and registers a controller.

```dart
final controller = Get.find<CounterController>();
```

Gets an already registered controller.

## GetX Navigation

Go to another page:

```dart
Get.to(() => const NextPage());
```

Go back:

```dart
Get.back();
```

Clear all previous pages and go to a new page:

```dart
Get.offAll(() => const LoginPage());
```

Show a snackbar:

```dart
Get.snackbar('Error', 'Something went wrong');
```

## GetX Mental Model

```text
Controller stores data and functions
.obs makes data reactive
Obx watches reactive data
Get.put creates/registers controller
Get.find gets an existing controller
Get.to navigates to a page
Get.offAll clears navigation history
Get.snackbar shows messages
```

## Login/Register Pattern

The login page usually has:

- Username `TextField`
- Password `TextField`
- Login/Register button
- Toggle button to switch mode

Example controller logic:

```dart
class AuthController extends GetxController {
  var isLoginMode = true.obs;

  void toggleMode() {
    isLoginMode.value = !isLoginMode.value;
  }

  Future<void> submit(String username, String password) async {
    if (username.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Please enter username and password');
      return;
    }

    if (isLoginMode.value) {
      // login logic
    } else {
      // register logic
    }
  }
}
```

Example UI usage:

```dart
Obx(() {
  return ElevatedButton(
    onPressed: () {
      authController.submit(
        usernameController.text.trim(),
        passwordController.text.trim(),
      );
    },
    child: Text(
      authController.isLoginMode.value ? 'Login' : 'Register',
    ),
  );
});
```

## SQLite Database Pattern

Use SQLite when you need structured local data.

Database helper structure:

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;

  static Database? _database;

  DatabaseHelper._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'users.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT
          )
        ''');
      },
    );
  }
}
```

Insert data:

```dart
Future<bool> registerUser(String username, String password) async {
  final db = await database;

  try {
    await db.insert('users', {
      'username': username,
      'password': password,
    });
    return true;
  } catch (e) {
    return false;
  }
}
```

Query data:

```dart
Future<bool> loginUser(String username, String password) async {
  final db = await database;

  final result = await db.query(
    'users',
    where: 'username = ? AND password = ?',
    whereArgs: [username, password],
  );

  return result.isNotEmpty;
}
```

Remember:

- `insert` adds data
- `query` reads data
- `where` prevents manually building SQL strings
- `whereArgs` safely fills the `?` values
- `result.isNotEmpty` means matching data exists

## SharedPreferences Pattern

Use SharedPreferences for small saved values, like login status.

Save session:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setString('username', username);
await prefs.setBool('isLoggedIn', true);
```

Read session:

```dart
final prefs = await SharedPreferences.getInstance();
final username = prefs.getString('username');
final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
```

Clear session:

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.clear();
```

## Splash Screen Login Check

A splash screen can decide whether to show login or main page:

```dart
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final username = prefs.getString('username');
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn && username != null) {
      Get.offAll(() => MainPage(username: username));
    } else {
      Get.offAll(() => const LoginPage());
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
```

Important idea:

```dart
initState()
```

runs once when the screen starts.

## HTTP API Fetch Pattern

Basic API controller:

```dart
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DataController extends GetxController {
  var dataList = [].obs;
  var detailData = {}.obs;
  var isLoading = true.obs;
  var errorMessage = ''.obs;

  Future<void> fetchList(String type) async {
    isLoading.value = true;
    errorMessage.value = '';
    dataList.clear();

    try {
      final response = await http.get(
        Uri.parse('https://api.spaceflightnewsapi.net/v4/$type/'),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        dataList.value = decoded['results'];
      } else {
        errorMessage.value = 'Failed to load data';
      }
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
```

Important API pattern:

```dart
final response = await http.get(Uri.parse(url));

if (response.statusCode == 200) {
  final decoded = json.decode(response.body);
} else {
  errorMessage.value = 'Failed to load data';
}
```

Use `try/catch/finally`:

- `try`: run risky code
- `catch`: handle errors
- `finally`: always run, usually to stop loading

## Loading/Error/Data UI Pattern

This pattern appears often:

```dart
Obx(() {
  if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  if (controller.errorMessage.value.isNotEmpty) {
    return Center(child: Text(controller.errorMessage.value));
  }

  return ListView.builder(
    itemCount: controller.dataList.length,
    itemBuilder: (context, index) {
      final item = controller.dataList[index];
      return ListTile(
        title: Text(item['title'] ?? 'No Title'),
      );
    },
  );
});
```

Remember the order:

```text
Loading?
Error?
Show data
```

## List Page Pattern

A list page receives a title and type:

```dart
class ListPage extends StatelessWidget {
  final String title;
  final String type;

  const ListPage({
    super.key,
    required this.title,
    required this.type,
  });
}
```

Fetch data after the page is built:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  dataController.fetchList(type);
});
```

Build a list:

```dart
ListView.builder(
  itemCount: data.length,
  itemBuilder: (context, index) {
    final item = data[index];

    return Card(
      child: ListTile(
        leading: item['image_url'] != null
            ? Image.network(
                item['image_url'],
                width: 80,
                fit: BoxFit.cover,
              )
            : const Icon(Icons.image),
        title: Text(item['title'] ?? 'No Title'),
        subtitle: Text(item['news_site'] ?? item['summary'] ?? ''),
        onTap: () {
          Get.to(() => DetailPage(
                id: item['id'].toString(),
                type: type,
                title: title,
              ));
        },
      ),
    );
  },
);
```

## Detail Page Pattern

A detail page receives an ID and fetches one item:

```dart
class DetailPage extends StatelessWidget {
  final String id;
  final String type;
  final String title;

  const DetailPage({
    super.key,
    required this.id,
    required this.type,
    required this.title,
  });
}
```

Fetch detail:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  dataController.fetchDetail(type, id);
});
```

Display detail:

```dart
SingleChildScrollView(
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      if (data['image_url'] != null)
        Image.network(
          data['image_url'],
          width: double.infinity,
          height: 250,
          fit: BoxFit.cover,
        ),
      Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              data['title'] ?? 'No Title',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(data['news_site'] ?? 'Unknown Site'),
            const SizedBox(height: 16),
            Text(data['summary'] ?? 'No Description'),
          ],
        ),
      ),
    ],
  ),
);
```

## Open External URL

Use `url_launcher`:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> launchArticleUrl(String urlString) async {
  final url = Uri.parse(urlString);

  if (!await launchUrl(url)) {
    Get.snackbar('Error', 'Could not launch URL');
  }
}
```

Example button:

```dart
FloatingActionButton(
  onPressed: () => launchArticleUrl(data['url']),
  child: const Icon(Icons.open_in_browser),
);
```

## Quiz Practice Tasks

Practice building these without looking first:

1. A basic Flutter page with `Scaffold`, `AppBar`, and `body`.
2. A login/register page with two `TextField`s.
3. A GetX controller with `.obs` variables.
4. An `Obx` widget that updates the UI.
5. Navigation using `Get.to` and `Get.offAll`.
6. A SQLite helper with `openDatabase`.
7. A register function using `db.insert`.
8. A login function using `db.query`.
9. Save and read login state with SharedPreferences.
10. Fetch API data using `http.get`.
11. Decode JSON using `json.decode`.
12. Show loading, error, then data.
13. Build a list with `ListView.builder`.
14. Navigate from a list item to a detail page.
15. Open a URL using `url_launcher`.

## Most Likely Quiz Requirements

If asked to make a similar app, expect requirements like:

- Create login and register
- Store users locally
- Save login session
- Show a main menu
- Fetch data from an API
- Show API data in a list
- Show selected item detail
- Add logout
- Use GetX for state and navigation

## What To Memorize Hard

These are the highest-value snippets:

```dart
var isLoading = true.obs;
var errorMessage = ''.obs;
var dataList = [].obs;
```

```dart
Obx(() {
  if (controller.isLoading.value) {
    return const Center(child: CircularProgressIndicator());
  }

  if (controller.errorMessage.value.isNotEmpty) {
    return Center(child: Text(controller.errorMessage.value));
  }

  return YourMainWidget();
});
```

```dart
final response = await http.get(Uri.parse(url));
final decoded = json.decode(response.body);
```

```dart
Get.to(() => NextPage());
Get.offAll(() => LoginPage());
Get.snackbar('Error', 'Message');
```

```dart
final prefs = await SharedPreferences.getInstance();
await prefs.setBool('isLoggedIn', true);
final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
```

```dart
final result = await db.query(
  'users',
  where: 'username = ? AND password = ?',
  whereArgs: [username, password],
);
```

## Simple Exam Strategy

Start with this order:

1. Create pages first.
2. Add navigation.
3. Add controllers.
4. Add login/register logic.
5. Add saved session.
6. Add API fetching.
7. Add list UI.
8. Add detail UI.
9. Add loading and error states.
10. Add logout.

If you get stuck, make the UI first, then connect the logic one part at a time.
