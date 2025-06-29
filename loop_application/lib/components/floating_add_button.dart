import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:provider/provider.dart';

class FloatingAddButton extends StatefulWidget {
  final DateTime defaultNewTaskDate;
  // final DateTime? checkDate;
  const FloatingAddButton({
    super.key,
    required this.defaultNewTaskDate,
    // this.checkDate,
  });

  @override
  State<FloatingAddButton> createState() => _FloatingAddButtonState();
}

class _FloatingAddButtonState extends State<FloatingAddButton> {
  String taskTitle = 'Nhiệm vụ mới';
  DateTime selectedDueDate = DateTime.now();
  Map<int, String> subtask = {};
  List<Widget> subtaskWidgets = [];
  int tempSubtaskCount = 0;

  @override
  void initState() {
    super.initState();
  }

  //* Floating button
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        setState(() {
          selectedDueDate = widget.defaultNewTaskDate;
          subtask = {};
          subtaskWidgets = [];
          tempSubtaskCount = 0;
          taskTitle = "Nhiệm vụ mới";
          // generateSubtaskWidgets();
        });
        await showTaskInputDialog(context);
      },
      backgroundColor: Theme.of(context).colorScheme.primary,
      shape: CircleBorder(),
      foregroundColor: Theme.of(context).colorScheme.inversePrimary,
      child: const Icon(Icons.add_circle_outline_outlined),
    );
  }

  //* Create task dialog
  Future<void> showTaskInputDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              child: Container(
                width: 370,
                height: 500,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(13),
                ),
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                child: Column(
                  spacing: 10,
                  children: [
                    //* Task title input
                    TextFormField(
                      style: normalText,
                      initialValue: taskTitle,
                      textInputAction: TextInputAction.done,
                      maxLines: null,
                      onChanged: (value) => taskTitle = value,
                      decoration: InputDecoration(
                        label: Text('Tiêu đề', style: normalText),
                        alignLabelWithHint: true,
                        floatingLabelStyle: TextStyle(
                          fontSize: 20,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                            width: 2,
                          ),
                        ),
                      ),
                    ),

                    //* Deadline option
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            DateTime? pickedDueDate =
                                await customDateTimePicker(context: context);
                            if (pickedDueDate != null) {
                              setState(() {
                                selectedDueDate = pickedDueDate;
                              });
                            }
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              DateFormat(
                                'yyyy-MM-dd HH:mm',
                              ).format(selectedDueDate),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    //* Subtask option
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          var tempEntries = <int, String>{
                            tempSubtaskCount: 'Nhiệm vụ con mới',
                          };
                          tempSubtaskCount++;
                          subtask.addEntries(tempEntries.entries);
                        });
                      },
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        spacing: 5,
                        children: [
                          const Text("Thêm nhiệm vụ con", style: normalText),
                          Icon(Icons.add),
                        ],
                      ),
                    ),
                    //* Subtask list
                    Expanded(
                      child: ListView(
                        children: [
                          Column(
                            children:
                                subtask.entries.map((e) {
                                  return Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Expanded(
                                        child: TextFormField(
                                          key: Key(e.key.toString()),
                                          initialValue: e.value,
                                          onChanged: (inputSubtask) {
                                            subtask.update(
                                              e.key,
                                              (value) => inputSubtask,
                                            );
                                          },
                                          decoration: InputDecoration(
                                            focusedBorder: UnderlineInputBorder(
                                              borderSide: BorderSide(
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primaryContainer,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            subtask.remove(e.key);
                                          });
                                        },
                                        child: Icon(Icons.delete),
                                      ),
                                    ],
                                  );
                                }).toList(),
                          ),
                        ],
                      ),
                    ),

                    //* Action buttons
                    Row(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Hủy', style: normalText),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            createTask();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                          child: const Text('Tạo', style: normalText),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void createTask() {
    if (subtask.isEmpty) {
      Provider.of<TaskModel>(context, listen: false).createLocalTask(
        taskTitle,
        false,
        selectedDueDate,
        widget.defaultNewTaskDate,
      );
    } else {
      Provider.of<TaskModel>(
        context,
        listen: false,
      ).createLocalTaskWithSubtasks(
        taskTitle,
        false,
        selectedDueDate,
        subtask.entries.map((e) => (e.value)).toList(),
        widget.defaultNewTaskDate,
      );
    }
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
