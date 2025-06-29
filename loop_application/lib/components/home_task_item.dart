import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/task_view.dart';
import 'package:provider/provider.dart';

class HomeTaskItem extends StatelessWidget {
  final Task task;
  const HomeTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              Provider.of<TaskModel>(context, listen: false).deleteTask(task);
            },
            icon: Icons.delete,
            flex: 1,
            label: 'Xóa',
            backgroundColor: Colors.red,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskView(taskId: task.id)),
          );
        },
        child: Container(
          padding: EdgeInsets.only(top: 5, right: 25, bottom: 5, left: 15),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 10,
            children: [
              Row(
                spacing: 10,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfe8430),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      spacing: 5,
                      children: [
                        Icon(
                          Icons.timelapse_outlined,
                          color: Theme.of(context).colorScheme.primary,
                          size: 20,
                        ),
                        Text(
                          DateFormat("HH:mm").format(task.deadline),
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (task.isTeamTask)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 5, vertical: 5),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: Icon(
                        Icons.group_outlined,
                        color: Theme.of(context).colorScheme.primary,
                        size: 16,
                      ),
                    ),
                ],
              ),
              Row(
                children: [
                  if (task.status == 2)
                    Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          end: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 7,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<TaskModel>(
                            context,
                            listen: false,
                          ).changeStatusLocal(task);
                        },
                        child: Icon(
                          Icons.task_alt_outlined,
                          color: Theme.of(context).colorScheme.primaryContainer,
                        ),
                      ),
                    )
                  else if (task.status == 1)
                    Container(
                      decoration: BoxDecoration(
                        border: BorderDirectional(
                          end: BorderSide(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1,
                          ),
                        ),
                      ),
                      padding: EdgeInsets.symmetric(
                        vertical: 15,
                        horizontal: 7,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Provider.of<TaskModel>(
                            context,
                            listen: false,
                          ).changeStatusLocal(task);
                        },
                        child: Icon(Icons.circle_outlined, color: Colors.grey),
                      ),
                    ),

                  Container(
                    padding: EdgeInsets.only(left: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: MediaQuery.of(context).size.width - 100,
                          child: Text(
                            task.title,
                            style: normalText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (task.subtasks.isNotEmpty)
                          Text(
                            "${task.subtasks.length.toString()} nhiệm vụ con",
                            style: TextStyle(
                              fontSize: 16,
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
