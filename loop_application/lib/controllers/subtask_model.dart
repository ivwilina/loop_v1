import 'package:isar/isar.dart';
import 'package:loop_application/models/subtask.dart';
import 'package:loop_application/models/task.dart';
// import 'package:path_provider/path_provider.dart';

//TODO: init provider

class SubtaskModel {
  static late Isar isar;

  //* Init - Database
  static Future<void> initialize(Isar isarGlobal) async {
    isar = isarGlobal;
  }

  //* List of subtasks
  final List<Subtask> currentSubtasks = [];

  // //* CREATE a subtask
  // Future<void> createSubtask(String subtaskTitle, Task momTask) async {
  //   final newSubtask = Subtask();
  //   newSubtask.isCompleted = false;
  //   newSubtask.title = subtaskTitle;
  //   newSubtask.task.value = momTask;
  //   isar.writeTxnSync(() => isar.subtasks.putSync(newSubtask));
  // }

  //* CREATE subtasks
  Future<void> createSubtasks(List<String> subtaskTitles, Task momTask) async {
    for (var i = 0; i < subtaskTitles.length; i++) {
      final newSubtask = Subtask();
      newSubtask.isCompleted = false;
      newSubtask.title = subtaskTitles[i];
      newSubtask.task.value = momTask;
      isar.writeTxnSync(() => isar.subtasks.putSync(newSubtask));
    }
  }

  //*READ subtasks from db (subtaks that inside a task)
  Future<void> fetchSubtasks(Task momTask) async {
    List<Subtask> fetchedSubtasks =
        await isar.subtasks.filter().task((q) {
          return q.idEqualTo(momTask.id);
        }).findAll();
    currentSubtasks.clear();
    currentSubtasks.addAll(fetchedSubtasks);
  }

  //* UPDATE a subtask
  Future<void> updateSubtask(int id, String newTitle, Task momTask) async {
    final existingSubtask = await isar.subtasks.get(id);
    if (existingSubtask != null) {
      existingSubtask.title = newTitle;
      await isar.writeTxn(() => isar.subtasks.put(existingSubtask));
      await fetchSubtasks(momTask);
    }
  }

  //* DELETE a subtask
  Future<void> deleteCategory(int id, Task momTask) async {
    await isar.writeTxn(() => isar.subtasks.delete(id));
    await fetchSubtasks(momTask);
  }
}
