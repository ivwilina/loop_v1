import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loop_application/models/user.dart';

class UserController extends ChangeNotifier {
  static late Isar isar;

  static Future<void> initialize(Isar isarGlobal) async {
    isar = isarGlobal;
  }

  final List<User> users = [];

  //* Add a user
  Future<void> addUser(
    String username,
    String displayName,
    String email,
    String token,
    String userIdServer,
  ) async {
    final user =
        User()
          ..username = username
          ..displayName = displayName
          ..email = email
          ..token = token
          ..userIdServer = userIdServer;
    await isar.writeTxn(() => isar.users.put(user));
    getUser();
  }

  //* Get user information
  Future<void> getUser() async {
    final userList = await isar.users.where().findAll();
    if (userList.isNotEmpty) {
      users.clear();
      users.addAll(userList);
    }
    notifyListeners();
  }

  //* Get token of the first user
  //* If no user is found, return an empty string
  Future<String> getToken() async {
    final userList = await isar.users.where().findAll();
    if (userList.isNotEmpty) {
      return userList.first.token;
    }
    return '';
  }

  //* Get userIdServer of the first user
  //* If no user is found, return an empty string
  Future<String> getUserIdServer() async {
    final userList = await isar.users.where().findAll();
    if (userList.isNotEmpty) {
      return userList.first.userIdServer;
    }
    return '';
  }

  //* Delete all user
  Future<void> deleteAllUsers() async {
    await isar.writeTxn(() => isar.users.clear());
    users.clear();
    notifyListeners();
  }

}
