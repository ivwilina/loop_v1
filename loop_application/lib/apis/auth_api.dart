import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loop_application/configs/server.config.dart' as server_config;
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/views/home_tab.dart';
import 'package:provider/provider.dart';

class AuthApi {
  // This class is currently empty, but it can be used to define methods
  // for authentication-related API calls in the future.

  // Example method for user login
  static Future<void> login(
    String username,
    String password,
    BuildContext context,
  ) async {
    Timer? timeoutTimer;
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.primary,
              title: Text('Không phản hồi'),
              content: Text(
                'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
              ),
              actions: [
                TextButton(
                  style: TextButton.styleFrom(
                    foregroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => HomeTab()),
                      (route) => false,
                    );
                  },
                  child: Text('OK'),
                ),
              ],
            ),
      );
    });

    try {
      final response = await http.post(
        Uri.parse('${server_config.testURL}/user/login'),
        headers: {'Content-Type': 'application/json'},
        body: '{"username": "$username", "password": "$password"}',
      );

      // Cancel the timer if the response is received before 1 minute
      timeoutTimer.cancel();

      if (response.statusCode == 200) {
        // Handle successful login
        final result = jsonDecode(response.body);
        Provider.of<UserController>(context, listen: false).addUser(
          result['username'],
          result['displayName'],
          result['email'],
          result['token'],
          result['userId'],
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng nhập thành công!',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
        // Navigate to home or another screen
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeTab()),
          (route) => false,
        );
      } else {
        // Handle login failure
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              jsonDecode(response.body)['message'] ?? 'Đăng nhập thất bại',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      // Cancel the timer if an error occurs
      timeoutTimer.cancel();
      // Handle server not responding or connection error
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text('Không phản hồi'),
              content: Text(
                'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
                style: TextStyle(
                  fontSize: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('OK'),
                ),
              ],
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
      );
    }
  }
  // Method for user registration
  static Future<void> register(
    String username, 
    String password,
    String email,
    String displayName,
    BuildContext context
  ) async {
    Timer? timeoutTimer;
    timeoutTimer = Timer(const Duration(seconds: 10), () {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Không phản hồi'),
          content: Text(
            'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    });

    try {
      final response = await http.post(
        Uri.parse('${server_config.testURL}/user/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          'displayName': displayName,
        }),
      );

      // Cancel the timer if the response is received
      timeoutTimer.cancel();

      if (response.statusCode == 201) {
        // Handle successful registration
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Đăng ký thành công! Vui lòng đăng nhập.',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
        // Navigate back to login
        Navigator.pop(context);
      } else {
        // Handle registration failure
        final responseData = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseData['message'] ?? 'Đăng ký thất bại',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          ),
        );
      }
    } catch (e) {
      // Cancel the timer if an error occurs
      timeoutTimer.cancel();
      // Handle server not responding or connection error
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text('Lỗi kết nối'),
          content: Text(
            'Không thể kết nối đến máy chủ. Vui lòng thử lại sau.',
          ),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  // // Example method for user logout
  // Future<void> logout() async {
  //   // Implement logout logic here
  // }
}
