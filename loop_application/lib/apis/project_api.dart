import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loop_application/configs/server.config.dart' as server_config;
import 'package:loop_application/controllers/user_controller.dart';

class ProjectApi {
  //* Get all projects of a team
  static Future<List<dynamic>> getProjectsOfTeam(String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Fetching projects for team ID: $teamId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/project/team'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teamId': teamId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error response: ${response.body}');
        throw Exception('Failed to fetch projects: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error fetching projects: $e');
    }
  }

  //* Create a new project
  static Future<void> createProject(String teamId, String projectName) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Creating project: $projectName for team: $teamId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/project/create'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teamId': teamId,
          'projectName': projectName,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create project: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error creating project: $e');
    }
  }

  //* Update project name
  static Future<void> updateProject(String projectId, String newName, String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Updating project: $projectId with new name: $newName');
      
      final response = await http.put(
        Uri.parse('${server_config.testURL}/project/update'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'newName': newName,
          'teamId': teamId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      if (response.statusCode != 200) {
        throw Exception('Failed to update project: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error updating project: $e');
    }
  }

  //* Delete a project
  static Future<void> deleteProject(String projectId, String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();

      final token = await userController.getToken();

      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }

      print('Deleting project: $projectId');
      final response = await http.delete(
        Uri.parse('${server_config.testURL}/project/delete'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'teamId': teamId, // Thêm dòng này
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode != 200) {
        throw Exception('Failed to delete project: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e');
      throw Exception('Error deleting project: $e');
    }
  }

  //* Assign members to project
  static Future<void> assignMembersToProject(String projectId, List<String> memberIds, String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Assigning members to project ID: $projectId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/project/assign-members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'memberIds': memberIds,
          'teamId': teamId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to assign members to project');
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error assigning members to project: $e');
    }
  }

  //* Remove members from project
  static Future<void> removeMembersFromProject(String projectId, List<String> memberIds, String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Removing members from project ID: $projectId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/project/remove-members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'memberIds': memberIds,
          'teamId': teamId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode != 200) {
        print('Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to remove members from project');
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error removing members from project: $e');
    }
  }

  //* Get project with assigned members
  static Future<Map<String, dynamic>> getProjectWithMembers(String projectId, String teamId) async {
    try {
      final userController = UserController();
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Fetching project with members for project ID: $projectId');
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/project/with-members'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'projectId': projectId,
          'teamId': teamId,
        }),
      );
      
      print('Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error response: ${response.body}');
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch project with members');
      }
    } catch (e) {
      print('Exception occurred: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Error fetching project with members: $e');
    }
  }
}
