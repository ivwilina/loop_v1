import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loop_application/configs/server.config.dart' as server_config;
import 'package:loop_application/controllers/user_controller.dart';

class TaskApi {
  //* Get all tasks of a project
  static Future<List<dynamic>> getTasksOfProject(String projectId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Fetching tasks for project ID: $projectId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/project'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to fetch tasks: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error fetching tasks: $e');
    }
  }

  //* Tạo nhiệm vụ mới cho một dự án
  static Future<void> createTask({
    required String projectId,
    required String title,
    String? description,
    DateTime? deadline,
    String? assignee,
    String? flag, // Thêm tham số flag
    List<Map<String, dynamic>>? subtasks,
  }) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      final userId = await userController.getUserIdServer();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Creating task: $title for project: $projectId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/new'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'title': title,
          'description': description ?? '',
          'deadline': deadline?.toIso8601String(),
          'assignee': assignee,
          'flag': flag ?? 'none', // Mặc định là 'none'
          'subtasks': subtasks ?? [],
          'createdBy': userId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error creating task: $e');
    }
  }

  //* Cập nhật nhiệm vụ
  static Future<void> updateTask({
    required String taskId,
    String? title,
    String? description,
    DateTime? deadline,
    String? status,
    String? assignee,
    String? flag, // Thêm tham số flag
    List<Map<String, dynamic>>? subtasks,
  }) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      final userId = await userController.getUserIdServer();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Updating task: $taskId');
      
      final response = await http.put(
        Uri.parse('${server_config.testURL}/task/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'title': title,
          'description': description,
          'deadline': deadline?.toIso8601String(),
          'status': status,
          'assignee': assignee,
          'flag': flag, // Thêm flag vào body
          'subtasks': subtasks,
          'updatedBy': userId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error updating task: $e');
    }
  }

  //* Delete a task
  static Future<void> deleteTask(String taskId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Deleting task: $taskId');
      
      final response = await http.delete(
        Uri.parse('${server_config.testURL}/task/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to delete task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error deleting task: $e');
    }
  }

  //* Get task information by task ID
  static Future<Map<String, dynamic>> getTaskInfo(String taskId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Fetching task info for ID: $taskId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to fetch task info: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error fetching task info: $e');
    }
  }

  //* Assign task to a member
  static Future<void> assignTaskToMember(String taskId, String memberId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Assigning task $taskId to member $memberId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/assign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'memberId': memberId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception('Failed to assign task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error assigning task: $e');
    }
  }

  //* Unassign task from member
  static Future<void> unassignTask(String taskId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Unassigning task $taskId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/unassign'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        throw Exception('Failed to unassign task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error unassigning task: $e');
    }
  }

  //* Toggle task status between pending and completed
  static Future<Map<String, dynamic>> toggleTaskStatus(String taskId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      final userId = await userController.getUserIdServer();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Toggling status for task: $taskId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/toggle-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'userId': userId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to toggle task status: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error toggling task status: $e');
    }
  }

  //* Take task by member (for unassigned tasks)
  static Future<Map<String, dynamic>> takeTask({
    required String taskId,
    required String projectId,
  }) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Taking task: $taskId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/take'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'projectId': projectId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to take task: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error taking task: $e');
    }
  }

  //* Update task status with role-based permissions
  static Future<Map<String, dynamic>> updateTaskStatus({
    required String taskId,
    required String newStatus,
    required String projectId,
  }) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Updating task status: $taskId to $newStatus');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/update-status'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'newStatus': newStatus,
          'projectId': projectId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        throw Exception('Failed to update task status: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error updating task status: $e');
    }
  }

  //* Cập nhật cờ ưu tiên của nhiệm vụ
  static Future<Map<String, dynamic>> updateTaskFlag({
    required String taskId,
    required String flag,
  }) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Updating task flag for task: $taskId to: $flag');
      
      final response = await http.put(
        Uri.parse('${server_config.testURL}/task/update-flag'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
          'flag': flag,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to update task flag: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error updating task flag: $e');
    }
  }

  //* Get task statistics for a project
  static Future<Map<String, dynamic>> getTaskStatistics(String projectId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Getting task statistics for project: $projectId');
      
      final response = await http.get(
        Uri.parse('${server_config.testURL}/task/statistics/$projectId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get task statistics: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error getting task statistics: $e');
    }
  }

  //* Get detailed task information including logs
  static Future<Map<String, dynamic>> getTaskDetailsWithLogs(String taskId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Getting task details with logs for task: $taskId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/task/info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'taskId': taskId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get task details: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error getting task details: $e');
    }
  }
}