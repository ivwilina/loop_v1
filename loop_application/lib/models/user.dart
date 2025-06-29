import 'package:isar/isar.dart';

part 'user.g.dart';
//! Note: dart run build_runner build <run this cmd after init model> 

@Collection()
class User {
  Id id = Isar.autoIncrement;
  late String username;
  late String displayName;
  late String email;
  late String token;
  // late String avatarPath;
  late String userIdServer;
}