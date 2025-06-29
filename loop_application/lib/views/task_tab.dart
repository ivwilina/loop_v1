import 'package:flutter/material.dart';
import 'package:loop_application/components/floating_add_button.dart';
import 'package:loop_application/components/task_tab_task_item.dart';
import 'package:loop_application/models/category.dart';
import 'package:loop_application/controllers/category_model.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:provider/provider.dart';

class TaskTab extends StatefulWidget {
  const TaskTab({super.key});

  @override
  State<TaskTab> createState() => _TaskTabState();
}

//TODO: make it beautiful like team view

class _TaskTabState extends State<TaskTab> {
  int _selectedCategory = 2;

  //* Read all categories from database
  void readCategories() {
    Provider.of<CategoryModel>(context, listen: false).fetchCategories();
  }

  //* Read selected category
  void readSelectedCategory(int id) {
    Provider.of<CategoryModel>(
      context,
      listen: false,
    ).fetchSelectedCategory(id);
  }

  //* Update category

  //* Delete category

  //* Read task in selected category
  void readTaskInSelectedCategory(int category) {
    Provider.of<TaskModel>(context, listen: false).findByCategory(category);
  }

  @override
  void initState() {
    _selectedCategory = 2;
    readCategories();
    readTaskInSelectedCategory(_selectedCategory);
    readSelectedCategory(_selectedCategory);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    //* Get screen width
    double screenWidth = MediaQuery.sizeOf(context).width;

    final taskModel = context.watch<TaskModel>();

    final categoryModel = context.watch<CategoryModel>();

    List<Category> currentCategories = categoryModel.currentCategory;

    // print(currentCategories.toString());

    List<Category> holderSelectedCategory = categoryModel.selectedCategory;

    List<Task> tasksInCategory = taskModel.currentTask;

    // print(tasksInCategory.toString());

    List<Task> pendingTask =
        tasksInCategory.where((e) => e.status == 1).toList();
    List<Task> completedTask =
        tasksInCategory.where((e) => e.status == 2).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Nhiệm vụ'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      floatingActionButton: FloatingAddButton(
        defaultNewTaskDate: DateTime.now(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        children: [
          //TODO: Make this dynamic
          //TODO: Make tasks can view in sorted list
          _listOfCategories(screenWidth, context, currentCategories),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        holderSelectedCategory.isNotEmpty
                            ? holderSelectedCategory.first.title
                            : 'Chưa chọn danh mục',
                        style: normalText,
                      ),
                      Row(
                        spacing: 25,
                        children: [
                          // Icon(Icons.grid_view_outlined),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                builder: (BuildContext context) {
                                  return Container(
                                    width: screenWidth,
                                    padding: EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(15),
                                      ),
                                    ),
                                    child: Column(
                                      spacing: 10,
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        GestureDetector(
                                          onTap: () async {
                                            String newCategoryTitle =
                                                holderSelectedCategory
                                                    .first
                                                    .title;
                                            await showDialog(
                                              context: context,
                                              builder: (BuildContext context) {
                                                return AlertDialog(
                                                  title: Text(
                                                    "Đổi tên danh mục",
                                                    style: normalText,
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                  content: TextFormField(
                                                    initialValue:
                                                        holderSelectedCategory
                                                            .first
                                                            .title,
                                                    style: normalText,
                                                    onChanged: (value) {
                                                      newCategoryTitle = value;
                                                    },
                                                    decoration: InputDecoration(
                                                      border: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          width: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                        ),
                                                      ),
                                                      focusedBorder: OutlineInputBorder(
                                                        borderSide: BorderSide(
                                                          width: 1,
                                                          color:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  actions: [
                                                    ElevatedButton(
                                                      onPressed: () {
                                                        Navigator.pop(context);
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                      ),
                                                      child: const Text(
                                                        'Hủy',
                                                        style: normalText,
                                                      ),
                                                    ),
                                                    ElevatedButton(
                                                      onPressed: () async {
                                                        await Provider.of<
                                                          CategoryModel
                                                        >(
                                                          context,
                                                          listen: false,
                                                        ).updateCategory(
                                                          holderSelectedCategory
                                                              .first
                                                              .id,
                                                          newCategoryTitle,
                                                        );
                                                        Navigator.pop(context);
                                                        setState(() {
                                                          readSelectedCategory(
                                                            _selectedCategory,
                                                          );
                                                        });
                                                      },
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primaryContainer,
                                                      ),
                                                      child: const Text(
                                                        'Lưu',
                                                        style: normalText,
                                                      ),
                                                    ),
                                                  ],
                                                );
                                              },
                                            );
                                            Navigator.pop(context);
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 10,
                                            ),
                                            child: const Text(
                                              'Đổi tên danh mục',
                                              style: normalText,
                                            ),
                                          ),
                                        ),
                                        if (!holderSelectedCategory
                                            .first
                                            .isDefault)
                                          GestureDetector(
                                            onTap: () async {
                                              await showDialog(
                                                context: context,
                                                builder: (
                                                  BuildContext context,
                                                ) {
                                                  return AlertDialog(
                                                    title: Text(
                                                      "Xóa danh mục",
                                                      style: normalText,
                                                    ),
                                                    backgroundColor:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.primary,
                                                    content: Text(
                                                      "Bạn có chắc chắn muốn xóa danh mục này không? Tất cả nhiệm vụ trong danh mục này sẽ bị xóa.",
                                                      style: normalText,
                                                    ),
                                                    actions: [
                                                      ElevatedButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                        ),
                                                        child: const Text(
                                                          'Hủy',
                                                          style: normalText,
                                                        ),
                                                      ),
                                                      ElevatedButton(
                                                        onPressed: () async {
                                                          final List<Task>
                                                          tasksToDelete =
                                                              tasksInCategory;
                                                          await Provider.of<
                                                            TaskModel
                                                          >(
                                                            context,
                                                            listen: false,
                                                          ).deleteMultipleTasks(
                                                            tasksToDelete,
                                                          );
                                                          await Provider.of<
                                                            CategoryModel
                                                          >(
                                                            context,
                                                            listen: false,
                                                          ).deleteCategory(
                                                            holderSelectedCategory
                                                                .first
                                                                .id,
                                                          );
                                                          Navigator.pop(
                                                            context,
                                                          );
                                                        },
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor:
                                                              Theme.of(context)
                                                                  .colorScheme
                                                                  .primaryContainer,
                                                        ),
                                                        child: const Text(
                                                          'Xóa',
                                                          style: normalText,
                                                        ),
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                              Navigator.pop(context);
                                              setState(() {
                                                _selectedCategory = 2;
                                                readTaskInSelectedCategory(
                                                  _selectedCategory,
                                                );
                                                readSelectedCategory(
                                                  _selectedCategory,
                                                );
                                              });
                                            },
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 10,
                                                    horizontal: 10,
                                                  ),
                                              child: const Text(
                                                'Xóa danh mục',
                                                style: normalText,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  );
                                },
                              );
                            },
                            child: Icon(Icons.more_vert_outlined),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          border: BorderDirectional(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                        ),
                        width: screenWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Text(
                          'Chưa hoàn thành (${pendingTask.length})',
                          style: normalText,
                        ),
                      ),
                      Column(
                        children:
                            pendingTask.map((e) {
                              return TaskTabTaskItem(task: e);
                            }).toList(),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary,
                          border: BorderDirectional(
                            top: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                              width: 1,
                            ),
                          ),
                        ),
                        width: screenWidth,
                        padding: EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 5,
                        ),
                        child: Text(
                          'Đã hoàn thành (${completedTask.length})',
                          style: normalText,
                        ),
                      ),
                      Column(
                        children:
                            completedTask.map((e) {
                              return TaskTabTaskItem(task: e);
                            }).toList(),
                      ),
                      SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Container _listOfCategories(
    double screenWidth,
    BuildContext context,
    List<Category> currentCategories,
  ) {
    return Container(
      width: screenWidth,
      height: 50,
      padding: EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        border: BorderDirectional(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outline,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              shrinkWrap: true,
              itemCount: currentCategories.length,
              itemBuilder: (context, index) {
                final categoryItem = currentCategories[index];
                return GestureDetector(
                  onTap: () async {
                    setState(() {
                      _selectedCategory = categoryItem.id;
                      readTaskInSelectedCategory(_selectedCategory);
                      readSelectedCategory(_selectedCategory);
                    });
                  },
                  child: Container(
                    padding: EdgeInsets.only(right: 25),
                    child: Center(
                      child: Text(categoryItem.title, style: normalText),
                    ),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await showCreateNewCategoryDialog();
              setState(() {});
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            child: const Text('Tạo mới', style: normalText),
          ),
        ],
      ),
    );
  }

  //* Show create new category dialog
  Future<void> showCreateNewCategoryDialog() async {
    String newCategoryTitle = "Danh mục mới";
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Tạo danh mục mới", style: normalText),
          backgroundColor: Theme.of(context).colorScheme.primary,
          content: TextFormField(
            initialValue: newCategoryTitle,
            style: normalText,
            onChanged: (value) {
              newCategoryTitle = value;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                  width: 1,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
            ),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text('Hủy', style: normalText),
            ),
            ElevatedButton(
              onPressed: () async {
                //* Create new Category with inputed title
                await Provider.of<CategoryModel>(
                  context,
                  listen: false,
                ).createCategory(newCategoryTitle);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: const Text('Tạo', style: normalText),
            ),
          ],
        );
      },
    );
  }
}
