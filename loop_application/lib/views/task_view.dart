import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:loop_application/controllers/task_model.dart';

class TaskView extends StatefulWidget {
  final int taskId;

  const TaskView({super.key, required this.taskId});

  @override
  State<TaskView> createState() => _TaskViewState();
}

class _TaskViewState extends State<TaskView> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  // void getTaskInfo(int taskId) {
  //   Provider.of<TaskModel>(context, listen: false).fetchTaskById(taskId);
  // }

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _descriptionController = TextEditingController();
    // getTaskInfo(widget.taskId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final taskModel = context.watch<TaskModel>();
    final task = taskModel.findById(widget.taskId);

    _titleController.text = task.title;
    _descriptionController.text = task.note ?? '';

    // print(task.subtasks.length);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Thông tin nhiệm vụ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            spacing: 10,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title Field
              Flexible(
                child: TextField(
                  textInputAction: TextInputAction.done,
                  maxLines: null,
                  onEditingComplete: () {
                    Provider.of<TaskModel>(
                      context,
                      listen: false,
                    ).updateTaskTitle(task, _titleController.text);
                  },
                  onSubmitted: (_) {
                    Provider.of<TaskModel>(
                      context,
                      listen: false,
                    ).updateTaskTitle(task, _titleController.text);
                  },
                  style: normalText,
                  controller: _titleController,
                  decoration: InputDecoration(
                    alignLabelWithHint: true,
                    labelText: 'Tiêu đề',
                    floatingLabelStyle: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        width: 2.0,
                      ),
                    ),
                  ),
                ),
              ),
              // Description Field
              TextField(
                maxLines: null,
                textInputAction: TextInputAction.done,
                onEditingComplete: () {
                  Provider.of<TaskModel>(
                    context,
                    listen: false,
                  ).updateTaskNote(task, _descriptionController.text);
                },
                onSubmitted: (_) {
                  Provider.of<TaskModel>(
                    context,
                    listen: false,
                  ).updateTaskNote(task, _descriptionController.text);
                },
                style: normalText,
                controller: _descriptionController,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Ghi chú',
                  labelStyle: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  floatingLabelStyle: TextStyle(
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      width: 2.0,
                    ),
                  ),
                ),
              ),
              // Deadline Picker
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    spacing: 10,
                    children: [
                      Text('Thời hạn', style: normalText),
                      Icon(Icons.timelapse_outlined),
                    ],
                  ),
                  Row(
                    spacing: 10,
                    children: [
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          padding: EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                        ),
                        onPressed: () async {
                          DateTime? tempDate = await customDateTimePicker(
                            context: context,
                            initialDate: task.deadline,
                          );
                          if (tempDate != null) {
                            Provider.of<TaskModel>(
                              context,
                              listen: false,
                            ).updateTaskDeadline(task, tempDate);
                          }
                        },
                        child: Text(
                          DateFormat('yyyy-MM-dd HH:mm').format(task.deadline),
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              // Completion Toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (task.status == 2)
                    Text('Đã hoàn thành', style: normalText)
                  else if (task.status == 1)
                    Text('Chưa hoàn thành', style: normalText),
                  //TODO: Team task
                  // Transform.scale(
                  //   scale: 1.5,
                  //   child: Checkbox(
                  //     value: task.status,
                  //     activeColor:
                  //         Theme.of(context).colorScheme.primaryContainer,
                  //     onChanged: (value) {
                  //       Provider.of<TaskModel>(
                  //         context,
                  //         listen: false,
                  //       ).checkCompletedTask(task);
                  //     },
                  //   ),
                  // ),
                ],
              ),

              GestureDetector(
                onTap: () {
                  Provider.of<TaskModel>(
                    context,
                    listen: false,
                  ).createSubtask("Nhiệm vụ con", task);
                },
                child: Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Nhiệm vụ con', style: normalText),
                    Icon(Icons.add, size: 30),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children:
                          task.subtasks.map((subtask) {
                            return Padding(
                              padding: const EdgeInsets.only(left: 20),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    spacing: 10,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          Provider.of<TaskModel>(
                                            context,
                                            listen: false,
                                          ).deleteSubtask(subtask.id, task);
                                        },
                                        child: Icon(
                                          Icons.delete,
                                          size: 25,
                                          color: Colors.red,
                                        ),
                                      ),
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                            0.6,
                                        child: TextFormField(
                                          initialValue: subtask.title,
                                          onEditingComplete: () {
                                            Provider.of<TaskModel>(
                                              context,
                                              listen: false,
                                            ).updateSubtaskTitle(
                                              subtask.id,
                                              subtask.title,
                                              task,
                                            );
                                          },
                                          onChanged: (value) {
                                            subtask.title = value;
                                          },
                                          style: normalText,
                                          decoration: InputDecoration(
                                            border: InputBorder.none,
                                            hintText: 'Tiêu đề',
                                            hintStyle: TextStyle(
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Checkbox(
                                    value: subtask.isCompleted,
                                    activeColor:
                                        Theme.of(
                                          context,
                                        ).colorScheme.primaryContainer,
                                    onChanged: (value) {
                                      setState(() {
                                        Provider.of<TaskModel>(
                                          context,
                                          listen: false,
                                        ).checkCompletedSubtask(
                                          subtask.id,
                                          task,
                                        );
                                      });
                                    },
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //* Custom DateTimePicker
  Future<DateTime?> customDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: Locale('vi'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff007AFF),
              onPrimary: Color(0xFFFFFFFF),
              onSurface: Color(0xff000000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return null;

    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff007AFF),
              onPrimary: Color(0xFFFFFFFF),
              onSurface: Color(0xff000000),
              secondary: Color(0xff007AFF),
              onSecondary: Color(0xFFFFFFFF),
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
  }
}
