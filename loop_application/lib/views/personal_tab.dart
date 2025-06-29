import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/login_tab.dart';
import 'package:loop_application/views/setting_tab.dart';
import 'package:provider/provider.dart';

class PersonalTab extends StatefulWidget {
  const PersonalTab({super.key});

  @override
  State<PersonalTab> createState() => _PersonalTabState();
}

class _PersonalTabState extends State<PersonalTab> {
  void fetchUserLoggedIn() {
    Provider.of<UserController>(context, listen: false).getUser();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserLoggedIn();
  }

  Widget buildPersonalTaskPieChart(TaskModel taskModel) {
    // Lấy danh sách nhiệm vụ cá nhân từ controller
    final tasks =
        taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    final int completed = tasks.where((t) => t.status == 2).length;
    final int notCompleted = tasks.length - completed;

    if (tasks.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          "Bạn chưa có nhiệm vụ cá nhân nào.",
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Thống kê nhiệm vụ cá nhân',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: PieChart(
                PieChartData(
                  sections: [
                    PieChartSectionData(
                      color: Colors.green,
                      value: completed.toDouble(),
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: notCompleted.toDouble(),
                      radius: 50,
                      titleStyle: TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              spacing: 8,
              children: [
                Icon(Icons.circle, color: Colors.green),
                Text(
                  '$completed đã hoàn thành',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
            Row(
              spacing: 8,
              children: [
                Icon(Icons.circle, color: Colors.redAccent),
                Text(
                  '$notCompleted chưa hoàn thành',
                  style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    final taskModel = context.watch<TaskModel>();
    List<User> users = userController.users;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cá Nhân'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingTab()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (users.isNotEmpty)
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      child: Text(
                        users.first.displayName.isNotEmpty
                            ? users.first.displayName[0].toUpperCase()
                            : users.first.username[0].toUpperCase(),
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                    ),
                    SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          users.first.displayName,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Theme.of(context).colorScheme.onPrimaryContainer,
                          ),
                        ),
                        Text(
                          users.first.email,
                          style: TextStyle(
                            fontSize: 13,
                            color: Theme.of(context).colorScheme.onPrimaryContainer.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          else
            Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginTab(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text("Đăng nhập", style: normalText),
                  ),
                  SizedBox(width: 10),
                  Text(
                    "Để sử dụng đầy đủ tính năng",
                    style: TextStyle(fontSize: 16),
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          // Thêm biểu đồ thống kê nhiệm vụ cá nhân
          buildPersonalTaskPieChart(taskModel),
        ],
      ),
    );
  }
}
