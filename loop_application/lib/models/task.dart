import 'package:isar/isar.dart';
import 'package:loop_application/models/subtask.dart';

//! Note: dart run build_runner build <run this cmd after init model> 

part 'task.g.dart';

@Collection()
class Task {
  Id id = Isar.autoIncrement;
  late int category;
  late String title;
  late bool isTeamTask;
  String? teamTaskId;
  late DateTime deadline;
  late int status; //* 1: pending  2:completed  3:review
  int? flag; //* 0: none  1:low  2:normal  3:high  4:urgent
  String? description;
  String? note;
  List<String>? attachment;
  @Backlink(to: 'task')
  final subtasks = IsarLinks<Subtask>();
}
