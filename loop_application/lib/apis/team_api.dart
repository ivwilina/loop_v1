import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:loop_application/configs/server.config.dart' as server_config;
import 'package:loop_application/controllers/user_controller.dart';

class TeamApi {
  //* Fetch all teams that the user has participated in
  static Future<List<dynamic>> getAllTeamsUserParticipatedIn() async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      final userIdServer = await userController.getUserIdServer();
      
      if (token.isEmpty || userIdServer.isEmpty) {
        print('Token or userIdServer is empty');
        return [];
      }
      
      print('Fetching teams for user ID: $userIdServer'); // Debug log
      
      final response = await http.get(
        Uri.parse('${server_config.testURL}/team/get/$userIdServer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error response: ${response.body}'); // Debug log
        return [];
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      return [];
    }
  }
  //* Fetch teams that the user is owner of
  static Future<List<dynamic>> getTeamsOwnedByUser() async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      final userIdServer = await userController.getUserIdServer();
      
      if (token.isEmpty || userIdServer.isEmpty) {
        print('Token or userIdServer is empty');
        return [];
      }
      
      print('Fetching owned teams for user ID: $userIdServer'); // Debug log
      
      final response = await http.get(
        Uri.parse('${server_config.testURL}/team/get/owned/$userIdServer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error response: ${response.body}'); // Debug log
        return [];
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      return [];
    }
  }
  //* Fetch teams that the user has joined
  static Future<List<dynamic>> getTeamsUserJoined() async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      final userIdServer = await userController.getUserIdServer();
      
      if (token.isEmpty || userIdServer.isEmpty) {
        print('Token or userIdServer is empty');
        return [];
      }
      
      print('Fetching joined teams for user ID: $userIdServer'); // Debug log
      
      final response = await http.get(
        Uri.parse('${server_config.testURL}/team/get/joined/$userIdServer'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body) as List<dynamic>;
      } else {
        print('Error response: ${response.body}'); // Debug log
        return [];
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      return [];
    }
  }//* Create a new team
  static Future<void> createTeam(String teamName) async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      // Check if we have users after refresh
      final users = userController.users;
      print('Users found directly in database: ${users.length}'); // Debug log
      
      if (users.isEmpty) {
        throw Exception('Error creating team: User not logged in');
      }
      
      // Get the token directly to ensure it's the latest
      final token = await userController.getToken();
      if (token.isEmpty) {
        throw Exception('Error creating team: Invalid token');
      }
      
      final username = users[0].username;
      print('Creating team with username: $username and token: ${token.substring(0, min(10, token.length))}...'); // Debug log
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/team/new'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'name': teamName,
          'username': username,
        }),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode != 201) {
        throw Exception('Failed to create team: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      throw Exception('Error creating team: $e');
    }
  }
  //* Get team information by ID
  static Future<Map<String, dynamic>> getTeamById(String teamId) async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Fetching team info for team ID: $teamId'); // Debug log
      
      final response = await http.get(
        Uri.parse('${server_config.testURL}/team/info/$teamId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      
      if (response.statusCode == 200) {
        // Parse the JSON response
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        print('Error response: ${response.body}'); // Debug log
        throw Exception('Failed to fetch team: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      throw Exception('Error fetching team by ID: $e');
    }
  }
  //* Add a user to a team
  static Future<void> addUserToTeam(String teamId, String username) async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Adding user $username to team $teamId'); // Debug log
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/team/update/add'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teamId': teamId,
          'username': username,
        }),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode != 200) {
        throw Exception('Failed to add user to team: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      throw Exception('Error adding user to team: $e');
    }
  }
  //* Remove a user from a team
  static Future<void> removeUserFromTeam(String teamId, String userId) async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Removing user $userId from team $teamId'); // Debug log
      
      final response = await http.post(
        Uri.parse('${server_config.testURL}/team/update/remove'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teamId': teamId,
          'userId': userId,
        }),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode != 200) {
        throw Exception('Failed to remove user from team: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      throw Exception('Error removing user from team: $e');
    }
  }
  //* Change member role in team
  static Future<void> changeMemberRole(String teamId, String userId, String newRole) async {
    try {
      // Creating a shared instance of UserController
      final userController = UserController();
      // Get all users - force a refresh from Isar
      await userController.getUser();
      
      final token = await userController.getToken();
      
      if (token.isEmpty) {
        print('Token is empty');
        throw Exception('User not logged in');
      }
      
      print('Changing role of user $userId in team $teamId to $newRole'); // Debug log
      
      final response = await http.put(
        Uri.parse('${server_config.testURL}/team/update/role'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'teamId': teamId,
          'userId': userId,
          'newRole': newRole,
        }),
      );
      
      print('Response status: ${response.statusCode}'); // Debug log
      print('Response body: ${response.body}'); // Debug log
      
      if (response.statusCode != 200) {
        throw Exception('Failed to change member role: ${response.body}');
      }
    } catch (e) {
      print('Exception occurred: $e'); // Debug log
      throw Exception('Error changing member role: $e');
    }
  }
}
