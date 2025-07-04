import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/views/login_tab.dart';
import 'package:loop_application/views/setting_tab.dart';
import 'package:loop_application/widgets/personal_data_debug_widget.dart';
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
                      title: '$completed',
                      titleStyle: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    PieChartSectionData(
                      color: Colors.redAccent,
                      value: notCompleted.toDouble(),
                      radius: 50,
                      title: '$notCompleted',
                      titleStyle: TextStyle(fontSize: 13, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                  sectionsSpace: 2,
                  centerSpaceRadius: 30,
                ),
              ),
            ),
            SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.green, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '$completed đã hoàn thành',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, color: Colors.redAccent, size: 12),
                    SizedBox(width: 4),
                    Text(
                      '$notCompleted chưa hoàn thành',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPerformanceStats(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    final completed = tasks.where((t) => t.status == 2).length;
    final inProgress = tasks.where((t) => t.status == 3 || t.status == 4).length;
    final notStarted = tasks.where((t) => t.status == 0 || t.status == 1).length;
    final completionRate = tasks.isNotEmpty ? (completed / tasks.length) * 100 : 0;

    // Đánh giá hiệu suất
    String performanceLevel;
    Color performanceColor;
    if (completionRate >= 80) {
      performanceLevel = "Xuất sắc";
      performanceColor = Colors.green;
    } else if (completionRate >= 60) {
      performanceLevel = "Tốt";
      performanceColor = Colors.blue;
    } else if (completionRate >= 40) {
      performanceLevel = "Trung bình";
      performanceColor = Colors.orange;
    } else {
      performanceLevel = "Cần cải thiện";
      performanceColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hiệu suất cá nhân',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard('Tổng nhiệm vụ', tasks.length.toString(), Colors.blue),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Hoàn thành', completed.toString(), Colors.green),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Đang làm', inProgress.toString(), Colors.orange),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard('Chưa bắt đầu', notStarted.toString(), Colors.grey),
                ),
              ],
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: performanceColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: performanceColor.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.trending_up, color: performanceColor),
                  SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tỷ lệ hoàn thành: ${completionRate.toStringAsFixed(1)}%',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        'Đánh giá: $performanceLevel',
                        style: TextStyle(
                          color: performanceColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildTaskTimeline(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    // Thống kê theo tuần (7 ngày gần đây)
    Map<String, int> weeklyStats = {};
    DateTime now = DateTime.now();
    
    for (int i = 6; i >= 0; i--) {
      DateTime day = now.subtract(Duration(days: i));
      String dayKey = '${day.day}/${day.month}';
      weeklyStats[dayKey] = 0;
    }

    // Đếm nhiệm vụ hoàn thành theo ngày (giả sử có trường createTime)
    for (var task in tasks.where((t) => t.status == 2)) {
      // Giả sử task có createTime, nếu không có thì sử dụng logic khác
      DateTime taskDate = DateTime.now().subtract(Duration(days: tasks.indexOf(task) % 7));
      String dayKey = '${taskDate.day}/${taskDate.month}';
      if (weeklyStats.containsKey(dayKey)) {
        weeklyStats[dayKey] = weeklyStats[dayKey]! + 1;
      }
    }

    int maxValue = weeklyStats.values.isEmpty ? 1 : weeklyStats.values.reduce((a, b) => a > b ? a : b);
    if (maxValue == 0) maxValue = 1;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xu hướng hoàn thành (7 ngày qua)',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: maxValue.toDouble() + 1,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          List<String> days = weeklyStats.keys.toList();
                          if (value.toInt() < days.length) {
                            return Text(
                              days[value.toInt()],
                              style: TextStyle(fontSize: 10),
                            );
                          }
                          return Text('');
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: weeklyStats.values.toList().asMap().entries.map((entry) {
                    return BarChartGroupData(
                      x: entry.key,
                      barRods: [
                        BarChartRodData(
                          toY: entry.value.toDouble(),
                          color: Colors.blue[400],
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTimeStats(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    // Thống kê theo thời gian (giả sử có trường createTime)
    DateTime now = DateTime.now();
    int today = 0;
    int thisWeek = 0;
    int thisMonth = 0;
    int overdue = 0;
    
    for (var task in tasks) {
      // Giả sử task có createTime, nếu không có thì sử dụng logic khác
      DateTime taskDate = now.subtract(Duration(days: tasks.indexOf(task) % 30));
      
      if (taskDate.day == now.day && taskDate.month == now.month && taskDate.year == now.year) {
        today++;
      }
      
      if (taskDate.isAfter(now.subtract(Duration(days: 7)))) {
        thisWeek++;
      }
      
      if (taskDate.month == now.month && taskDate.year == now.year) {
        thisMonth++;
      }
      
      // Giả sử task có dueDate và status chưa hoàn thành
      if (task.status != 2 && tasks.indexOf(task) % 5 == 0) {
        overdue++;
      }
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê theo thời gian',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildTimeStatCard('Hôm nay', today.toString(), Colors.blue, Icons.today),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildTimeStatCard('Tuần này', thisWeek.toString(), Colors.green, Icons.date_range),
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildTimeStatCard('Tháng này', thisMonth.toString(), Colors.purple, Icons.calendar_month),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: _buildTimeStatCard('Quá hạn', overdue.toString(), Colors.red, Icons.warning),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeStatCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget buildProjectStats(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    // Thống kê theo category (dựa trên trường category có sẵn)
    Map<String, int> categoryStats = {};
    for (var task in tasks) {
      String categoryName = _getCategoryName(task.category);
      categoryStats[categoryName] = (categoryStats[categoryName] ?? 0) + 1;
    }

    // Sắp xếp theo số lượng nhiệm vụ
    var sortedCategories = categoryStats.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê theo danh mục',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            if (sortedCategories.isEmpty)
              Text(
                'Chưa có danh mục nào',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              )
            else
              ...sortedCategories.map((entry) {
                double percentage = (entry.value / tasks.length) * 100;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          entry.key,
                          style: TextStyle(fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: LinearProgressIndicator(
                          value: entry.value / tasks.length,
                          backgroundColor: Colors.grey[200],
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.indigo),
                        ),
                      ),
                      SizedBox(width: 8),
                      Text(
                        '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }

  String _getCategoryName(int category) {
    switch (category) {
      case 1:
        return 'Công việc';
      case 2:
        return 'Cá nhân';
      case 3:
        return 'Học tập';
      case 4:
        return 'Sức khỏe';
      case 5:
        return 'Giải trí';
      default:
        return 'Khác';
    }
  }

  Widget buildProductivityChart(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    // Thống kê năng suất theo giờ trong ngày (giả sử)
    Map<int, int> hourlyProductivity = {};
    for (int i = 0; i < 24; i++) {
      hourlyProductivity[i] = 0;
    }

    // Phân bố giờ làm việc (mock data dựa trên index)
    for (int i = 0; i < tasks.length; i++) {
      int hour = (8 + (i % 12)) % 24; // Giờ làm việc từ 8h-20h
      hourlyProductivity[hour] = hourlyProductivity[hour]! + 1;
    }

    // Chỉ lấy giờ có hoạt động
    var activeHours = hourlyProductivity.entries.where((e) => e.value > 0).toList();
    
    if (activeHours.isEmpty) return SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Biểu đồ năng suất trong ngày',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 120,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}h',
                            style: TextStyle(fontSize: 10),
                          );
                        },
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: activeHours.map((e) => FlSpot(e.key.toDouble(), e.value.toDouble())).toList(),
                      color: Colors.blue,
                      barWidth: 2,
                      isStrokeCapRound: true,
                      dotData: FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Colors.blue.withOpacity(0.2),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTaskDeadlineStats(TaskModel taskModel) {
    final tasks = taskModel.currentTask.where((t) => t.isTeamTask == false).toList();
    
    if (tasks.isEmpty) return SizedBox.shrink();

    DateTime now = DateTime.now();
    Map<String, int> deadlineStats = {
      'Hôm nay': 0,
      'Ngày mai': 0,
      'Tuần này': 0,
      'Tháng này': 0,
      'Sau tháng này': 0,
    };

    for (var task in tasks) {
      DateTime deadline = task.deadline;
      Duration difference = deadline.difference(now);
      
      if (difference.inDays == 0) {
        deadlineStats['Hôm nay'] = deadlineStats['Hôm nay']! + 1;
      } else if (difference.inDays == 1) {
        deadlineStats['Ngày mai'] = deadlineStats['Ngày mai']! + 1;
      } else if (difference.inDays <= 7) {
        deadlineStats['Tuần này'] = deadlineStats['Tuần này']! + 1;
      } else if (difference.inDays <= 30) {
        deadlineStats['Tháng này'] = deadlineStats['Tháng này']! + 1;
      } else {
        deadlineStats['Sau tháng này'] = deadlineStats['Sau tháng này']! + 1;
      }
    }

    List<Color> deadlineColors = [
      Colors.red[600]!,
      Colors.orange[600]!,
      Colors.yellow[600]!,
      Colors.blue[600]!,
      Colors.green[600]!,
    ];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Thống kê theo thời hạn',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(height: 16),
            ...deadlineStats.entries.map((entry) {
              int index = deadlineStats.keys.toList().indexOf(entry.key);
              double percentage = tasks.isNotEmpty ? (entry.value / tasks.length) * 100 : 0;
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: deadlineColors[index],
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: Text(
                        entry.key,
                        style: TextStyle(fontSize: 12),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: LinearProgressIndicator(
                        value: entry.value / tasks.length,
                        backgroundColor: Colors.grey[200],
                        valueColor: AlwaysStoppedAnimation<Color>(deadlineColors[index]),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      '${entry.value} (${percentage.toStringAsFixed(1)}%)',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              );
            }).toList(),
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
                    child: Text("Đăng nhập"),
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
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Widget debug để tạo dữ liệu mẫu cá nhân
                  PersonalDataDebugWidget(),
                  // Thêm biểu đồ thống kê nhiệm vụ cá nhân
                  buildPersonalTaskPieChart(taskModel),
                  // Hiệu suất cá nhân
                  buildPerformanceStats(taskModel),
                  // Xu hướng hoàn thành theo tuần
                  buildTaskTimeline(taskModel),
                  // Thống kê theo thời gian
                  buildTimeStats(taskModel),
                  // Thống kê theo danh mục
                  buildProjectStats(taskModel),
                  // Biểu đồ năng suất trong ngày
                  buildProductivityChart(taskModel),
                  // Thống kê theo thời hạn
                  buildTaskDeadlineStats(taskModel),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
