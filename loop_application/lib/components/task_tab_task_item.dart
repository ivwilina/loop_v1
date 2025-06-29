import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:loop_application/models/category.dart';
import 'package:loop_application/controllers/category_model.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/task_view.dart';
import 'package:provider/provider.dart';

class TaskTabTaskItem extends StatelessWidget {
  final Task task;

  const TaskTabTaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final categoryModel = context.watch<CategoryModel>();

    List<Category> currentCategories = categoryModel.currentCategory;

    return Slidable(
      endActionPane: ActionPane(
        motion: ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (context) {
              int oldCategory = task.category;
              showModalBottomSheet(
                context: context,
                builder: (BuildContext context) {
                  return Container(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.4,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text('Chuyển tới danh mục', style: normalText),
                        Expanded(
                          child: ListView(
                            children: [
                              Column(
                                children:
                                    currentCategories.map((e) {
                                      return GestureDetector(
                                        onTap: () {
                                          Provider.of<TaskModel>(
                                            context,
                                            listen: false,
                                          ).updateTaskCategory(task, e.id);
                                          Navigator.pop(context);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 10,
                                          ),
                                          height: 50,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.folder_open_outlined,
                                                color:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .onPrimary,
                                              ),
                                              SizedBox(width: 20),
                                              Expanded(
                                                child: Text(
                                                  e.title,
                                                  style: normalText,
                                                ),
                                              ),
                                              if (task.category == e.id)
                                                Icon(
                                                  Icons
                                                      .arrow_circle_left_outlined,
                                                  color:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .primaryContainer,
                                                ),
                                            ],
                                          ),
                                        ),
                                      );
                                    }).toList(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
              Provider.of<TaskModel>(
                context,
                listen: false,
              ).findByCategory(oldCategory);
            },
            icon: Icons.move_to_inbox,
            flex: 1,
            label: 'Đổi',
            backgroundColor: Colors.blue,
          ),
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
            MaterialPageRoute(
              builder: (context) {
                return TaskView(taskId: task.id);
              },
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                spacing: 10,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  //TODO: handle team task
                  if (task.status == 2)
                    GestureDetector(
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
                    )
                  else if (task.status == 1)
                    GestureDetector(
                      onTap: () {
                        Provider.of<TaskModel>(
                          context,
                          listen: false,
                        ).changeStatusLocal(task);
                      },
                      child: Icon(Icons.circle_outlined, color: Colors.grey),
                    ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        spacing: 5,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFfe8430),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Row(
                              spacing: 5,
                              children: [
                                Icon(
                                  Icons.timelapse_outlined,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 16,
                                ),
                                Text(
                                  DateFormat(
                                    "yyyy-MM-dd HH:mm",
                                  ).format(task.deadline),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (task.isTeamTask)
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 5,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
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
                      Container(
                        padding: EdgeInsets.only(right: 10),
                        width: MediaQuery.of(context).size.width - 100,
                        child: Text(
                          task.title,
                          style: normalText,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),

                      Text(
                        task.subtasks.isNotEmpty
                            ? '${task.subtasks.length} nhiệm vụ con'
                            : 'Không có nhiệm vụ con',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              if (task.category == 1)
                GestureDetector(
                  onTap: () {
                    // int oldCategory = task.category;
                    Provider.of<TaskModel>(
                      context,
                      listen: false,
                    ).markAsFavorite(task);
                    // Provider.of<TaskModel>(context, listen: false).fetchTaskInCategory(oldCategory);
                  },
                  child: Icon(Icons.star),
                )
              else
                GestureDetector(
                  onTap: () {
                    Provider.of<TaskModel>(
                      context,
                      listen: false,
                    ).markAsFavorite(task);
                  },
                  child: Icon(Icons.star_border_outlined),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
