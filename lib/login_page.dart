import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'controllers/auth_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final _usernameController = TextEditingController();
    final _passwordController = TextEditingController();
    final authController = Get.put(AuthController());

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(authController.isLoginMode.value ? 'Login' : 'Register'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    authController.submit(
                      _usernameController.text.trim(),
                      _passwordController.text.trim(),
                    );
                  },
                  child: Text(authController.isLoginMode.value ? 'Login' : 'Register'),
                ),
                TextButton(
                  onPressed: authController.toggleMode,
                  child: Text(authController.isLoginMode.value
                      ? 'Don\'t have an account? Register'
                      : 'Already have an account? Login'),
                ),
              ],
            ),
          ),
        ));
  }
}
