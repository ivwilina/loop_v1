import 'package:isar/isar.dart';
import 'package:loop_application/models/task.dart';

//! Note: dart run build_runner build <run this cmd after init model> 

part 'subtask.g.dart';

@Collection()
class Subtask {
  Id id = Isar.autoIncrement;
  late String title;
  late bool isCompleted;
  
  final task = IsarLink<Task>();
}