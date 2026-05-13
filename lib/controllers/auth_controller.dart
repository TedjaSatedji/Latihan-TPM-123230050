import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database_helper.dart';
import '../main_page.dart';

class AuthController extends GetxController {
  final dbHelper = DatabaseHelper();
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
      final success = await dbHelper.loginUser(username, password);
      if (success) {
        await saveSessionAndNavigate(username);
      } else {
        Get.snackbar('Error', 'Invalid username or password');
      }
    } else {
      final success = await dbHelper.registerUser(username, password);
      if (success) {
        Get.snackbar('Success', 'Registration successful! You can now log in.');
        toggleMode();
      } else {
        Get.snackbar('Error', 'Username already exists. Try another.');
      }
    }
  }

  Future<void> saveSessionAndNavigate(String username) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('username', username);
    await prefs.setBool('isLoggedIn', true);

    Get.offAll(() => MainPage(username: username));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Get.offAllNamed('/');
  }
}
