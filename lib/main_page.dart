import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';
import 'list_page.dart';
import 'login_page.dart';

class MainPage extends StatelessWidget {
  final String username;

  const MainPage({super.key, required this.username});

  @override
  Widget build(BuildContext context) {
    final authController = Get.put(AuthController());

    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome, $username'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.logout();
              Get.offAll(() => const LoginPage());
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildMenuButton('News', 'articles'),
            const SizedBox(height: 16),
            _buildMenuButton('Blogs', 'blogs'),
            const SizedBox(height: 16),
            _buildMenuButton('Reports', 'reports'),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(String title, String type) {
    return SizedBox(
      width: 200,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(16),
        ),
        onPressed: () {
          Get.to(() => ListPage(title: title, type: type));
        },
        child: Text(title, style: const TextStyle(fontSize: 18)),
      ),
    );
  }
}
