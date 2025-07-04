import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loop_application/models/subtask.dart';
import 'package:loop_application/models/task.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loop_application/controllers/task_model.dart';

//TODO: init provider

class TaskModel extends ChangeNotifier {
  static late Isar isar;
  static late Isar isarForSubtask;

  //* Init - Database
  static Future<void> initialize(Isar isarGlobal) async {
    isar = isarGlobal;
  }

  //* List of tasks
  final List<Task> currentTask = [];
  final List<Task> currentTaskHaveDeadline = [];
  final List<Task> taskOnSpecificDay = [];

  final Task emptyTask =
      Task()
        ..title = ''
        ..category = 2
        ..isTeamTask = false
        ..deadline = DateTime.now()
        ..status = 1;

  //* CREATE a task without subtask
  Future<void> createLocalTask(
    String title,
    bool isTeamTask,
    DateTime deadline,
    DateTime checkDate,
  ) async {
    final newTask = Task();
    newTask.title = title;
    newTask.category = 2;
    newTask.isTeamTask = isTeamTask; //TODO: handle if task comes from a team
    newTask.deadline = deadline;
    newTask.status = 1;
    await isar.writeTxn(() => isar.tasks.put(newTask));
    findAll();
    findByDate(deadline);
  }

  //* CREATE a task with subtask(s)
  Future<void> createLocalTaskWithSubtasks(
    String title,
    bool isTeamTask,
    DateTime deadline,
    List<String> subtaskTitles,
    DateTime checkDate,
  ) async {
    //* Init task
    final newTask = Task();
    newTask.title = title;
    newTask.category = 2;
    newTask.isTeamTask = isTeamTask; //TODO: handle if task comes from a team
    newTask.deadline = deadline;
    newTask.status = 1;
    await isar.writeTxn(() => isar.tasks.put(newTask));

    // *Init subtask(s)
    for (var i = 0; i < subtaskTitles.length; i++) {
      final newSubtask = Subtask();
      newSubtask.isCompleted = false;
      newSubtask.title = subtaskTitles[i];
      newSubtask.task.value = newTask;
      isar.writeTxnSync(() => isar.subtasks.putSync(newSubtask));
    }
    findAll();
    findByDate(deadline);
  }

  //* CREATE subtask
  Future<void> createSubtask(String subtaskTitle, Task momTask) async {
    final newSubtask = Subtask();
    newSubtask.isCompleted = false;
    newSubtask.title = subtaskTitle;
    newSubtask.task.value = momTask;
    isar.writeTxnSync(() => isar.subtasks.putSync(newSubtask));
    findByDate(momTask.deadline);
    findByCategory(momTask.category);
    notifyListeners();
  }

  //*READ tasks from db
  Future<void> findAll() async {
    List<Task> fetchedTasks = await isar.tasks.where().findAll();
    currentTask.clear();
    currentTask.addAll(fetchedTasks);
    notifyListeners();
  }

  //* READ a single task by ID
  Task findById(int id) {
    final task = isar.tasks.getSync(id);
    if (task != null) {
      return task;
    } else {
      throw Exception('Task not found');
    }
  }

  //! DEVELOPER ONLY
  // //* READ a single task by ID
  // Future<void> fetchTaskById(int id) async {
  //   final task = await isar.tasks.get(id);
  //   if (task != null) {
  //     await task.subtasks.load();
  //     final List<Subtask> tempSubtaskList = task.subtasks.toList();
  //     for (var subtask in task.subtasks) {
  //   }
  //     emptyTask.id = task.id;
  //     emptyTask.title = task.title;
  //     emptyTask.category = task.category;
  //     emptyTask.isDeadline = task.isDeadline;
  //     emptyTask.isTeamTask = task.isTeamTask;
  //     emptyTask.teamTaskID = task.teamTaskID;
  //     emptyTask.remind = task.remind;
  //     emptyTask.deadline = task.deadline;
  //     emptyTask.isCompleted = task.isCompleted;
  //     emptyTask.flag = task.flag;
  //     emptyTask.note = task.note;
  //     emptyTask.subtasks.clear();
  //     for (var subtask in tempSubtaskList) {
  //       final newSubtask = Subtask()
  //         ..id = subtask.id
  //         ..title = subtask.title
  //         ..isCompleted = subtask.isCompleted
  //         ..task.value = emptyTask;
  //       emptyTask.subtasks.add(newSubtask);
  //     }
  //   } else {
  //     throw Exception('Task not found');
  //   }
  //   notifyListeners();
  // }

  //*READ tasks in Category
  Future<void> findByCategory(int categoryId, {bool notify = true}) async {
    List<Task> fetchedTasks =
        await isar.tasks.filter().categoryEqualTo(categoryId).findAll();
    currentTask.clear();
    currentTask.addAll(fetchedTasks);
    currentTask.sort((a, b) {
      return a.deadline.compareTo(b.deadline);
    });
    if (notify) notifyListeners();
  }

  //*READ tasks on specific day from db
  Future<void> findByDate(DateTime dayToSearch, {bool notify = true}) async {
    // Luôn fetch fresh data từ database
    List<Task> fetchedTasks = await isar.tasks.where().findAll();
    
    // Cập nhật currentTask để đảm bảo sync
    currentTask.clear();
    currentTask.addAll(fetchedTasks);
    
    // Filter tasks cho ngày cụ thể
    taskOnSpecificDay.clear();
    for (var n in fetchedTasks) {
      if (dayToSearch.year == n.deadline.year &&
          dayToSearch.month == n.deadline.month &&
          dayToSearch.day == n.deadline.day) {
        if (!taskOnSpecificDay.contains(n)) {
          taskOnSpecificDay.add(n);
        }
      }
    }
    // Sort sau khi hoàn thành vòng lặp
    taskOnSpecificDay.sort((a, b) {
      return a.deadline.compareTo(b.deadline);
    });
    if (notify) notifyListeners();
  }

  // //*READ tasks from db (specific date)
  // Future<void> fetchTaskByDate(DateTime searchDate) async {
  //   List<Task> fetchedTasks = await isar.tasks.where().findAll();
  //   currentTask.clear();
  //   currentTask.addAll(fetchedTasks);
  // }

  // //* READ only task with deadline
  // Future<void> fetchTaskWithDeadline() async {
  //   List<Task> fetchedTasks =
  //       await isar.tasks.filter().isDeadlineEqualTo(true).findAll();
  //   currentTaskHaveDeadline.clear();
  //   currentTaskHaveDeadline.addAll(fetchedTasks);
  //   currentTaskHaveDeadline.sort((a, b) {
  //     // Compare by isCompleted (false comes before true)
  //     if (a.isCompleted != b.isCompleted) {
  //       return a.isCompleted ? 1 : -1;
  //     }
  //     // If isCompleted is the same, compare by deadline
  //     if (a.deadline != null && b.deadline != null) {
  //       return a.deadline!.compareTo(b.deadline!);
  //     } else if (a.deadline != null) {
  //       return -1; // Tasks with a deadline come first
  //     } else if (b.deadline != null) {
  //       return 1; // Tasks without a deadline come last
  //     }
  //     return 0; // If both are null, keep the original order
  //   });
  //   notifyListeners();
  // }

  //* UPDATE task status local (from pending to completed and reverse)
  Future<void> changeStatusLocal(Task task) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      if (existingTask.status == 1) {
        existingTask.status = 2;
      } else if (existingTask.status == 2) {
        existingTask.status = 1;
      }
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
    bridgeFetch(task.deadline);
  }

  //* Check completed subtask by ID
  Future<void> checkCompletedSubtask(int subtaskId, Task momTask) async {
    final existingSubtask = await isar.subtasks.get(subtaskId);
    if (existingSubtask != null) {
      existingSubtask.isCompleted = !existingSubtask.isCompleted;
      await isar.writeTxn(() => isar.subtasks.put(existingSubtask));
    }
    notifyListeners();
  }

  //* Mark as favorite
  Future<void> markAsFavorite(Task task) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      (existingTask.category != 1)
          ? existingTask.category = 1
          : existingTask.category = 2;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
  }

  //* UPDATE task's title
  Future<void> updateTaskTitle(Task task, String newTitle) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      existingTask.title = newTitle;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
    findByDate(task.deadline);
    notifyListeners();
  }

  //* UPDATE task's note
  Future<void> updateTaskNote(Task task, String newNote) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      existingTask.note = newNote;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
    notifyListeners();
  }

  //* UPDATE task's category
  Future<void> updateTaskCategory(Task task, int newCategory) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      existingTask.category = newCategory;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
  }

  //* UPDATE task's deadline
  Future<void> updateTaskDeadline(Task task, DateTime newDeadline) async {
    final existingTask = await isar.tasks.get(task.id);
    if (existingTask != null) {
      existingTask.deadline = newDeadline;
      await isar.writeTxn(() => isar.tasks.put(existingTask));
    }
    await findAll(); // Cập nhật toàn bộ tasks
    findByDate(existingTask!.deadline);
    notifyListeners();
  }

  //* UPDATE subtask's title
  Future<void> updateSubtaskTitle(
    int subtaskId,
    String newTitle,
    Task momTask,
  ) async {
    final existingSubtask = await isar.subtasks.get(subtaskId);
    if (existingSubtask != null) {
      existingSubtask.title = newTitle;
      await isar.writeTxn(() => isar.subtasks.put(existingSubtask));
    }
    notifyListeners();
  }

  //* DELETE a task
  Future<void> deleteTask(Task task) async {
    DateTime taskDeadline = task.deadline;
    
    // Xóa task khỏi database
    await isar.writeTxn(() => isar.tasks.delete(task.id));
    
    // Chỉ refresh data cần thiết, không thay đổi currentTask filter
    await findAll(); // Cập nhật currentTask với tất cả tasks
    await findByDate(taskDeadline, notify: false); // Cập nhật taskOnSpecificDay
  }

  //* DELETE multiple tasks
  Future<void> deleteMultipleTasks(List<Task> tasks) async {
    for (var task in tasks) {
      await isar.writeTxn(() => isar.tasks.delete(task.id));
    }
    await findAll(); // Cập nhật toàn bộ tasks
    notifyListeners();
  }

  //*DELETE a subtask
  Future<void> deleteSubtask(int subtaskId, Task momTask) async {
    await isar.writeTxn(() => isar.subtasks.delete(subtaskId));
    await findAll(); // Cập nhật toàn bộ tasks
    findByDate(momTask.deadline);
    findByCategory(momTask.category);
    notifyListeners();
  }

  void bridgeFetch(DateTime deadline) {
    DateTime tempDate = deadline;
    findByDate(tempDate); // Sử dụng default notify = true
  }

  // Thêm method để refresh calendar events
  void refreshCalendarEvents() {
    notifyListeners();
  }
}
