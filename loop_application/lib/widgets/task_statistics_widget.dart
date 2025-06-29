import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../apis/task_api.dart';

class TaskStatisticsWidget extends StatefulWidget {
  final String projectId;

  const TaskStatisticsWidget({Key? key, required this.projectId})
    : super(key: key);

  @override
  State<TaskStatisticsWidget> createState() => _TaskStatisticsWidgetState();
}

class _TaskStatisticsWidgetState extends State<TaskStatisticsWidget> {
  Map<String, dynamic>? statisticsData;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final data = await TaskApi.getTaskStatistics(widget.projectId);
      setState(() {
        statisticsData = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thống kê',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              error!,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (statisticsData == null) {
      return const Center(child: Text('Không có dữ liệu thống kê'));
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tổng quan
            _buildOverviewCards(),
            const SizedBox(height: 16),

            // Biểu đồ tròn trạng thái
            _buildStatusPieChart(),
            const SizedBox(height: 16),

            // Biểu đồ tròn ưu tiên
            _buildFlagPieChart(),
            const SizedBox(height: 16),

            // Biểu đồ cột hoàn thành theo thời gian
            _buildCompletionBarChart(),
            const SizedBox(height: 16),

            // Biểu đồ cột thay đổi trạng thái
            _buildStatusChangeBarChart(),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards() {
    final totalTasks = statisticsData!['totalTasks'] ?? 0;
    final completedTasks = statisticsData!['completedTasksCount'] ?? 0;
    final averageTime = statisticsData!['averageCompletionTime'] ?? 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tổng quan',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Tổng NV',
                value: totalTasks.toString(),
                icon: Icons.assignment,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Hoàn thành',
                value: completedTasks.toString(),
                icon: Icons.check_circle,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'TB: ${averageTime}d',
                value:
                    '${totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(0) : 0}%',
                icon: Icons.access_time,
                color: Colors.orange,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontSize: 10),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart() {
    final statusStats = Map<String, int>.from(
      statisticsData!['statusStats'] ?? {},
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân bố trạng thái nhiệm vụ',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 40,
                    sections: _buildStatusPieChartSections(statusStats),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildStatusLegend(statusStats)),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildStatusPieChartSections(
    Map<String, int> statusStats,
  ) {
    final colors = {
      'created': Colors.grey,
      'assigned': Colors.blue,
      'pending': Colors.orange,
      'in_review': Colors.purple,
      'completed': Colors.green,
      'closed': Colors.red,
    };

    final total = statusStats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return statusStats.entries.where((entry) => entry.value > 0).map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildStatusLegend(Map<String, int> statusStats) {
    final colors = {
      'created': Colors.grey,
      'assigned': Colors.blue,
      'pending': Colors.orange,
      'in_review': Colors.purple,
      'completed': Colors.green,
      'closed': Colors.red,
    };

    final statusNames = {
      'created': 'Đã tạo',
      'assigned': 'Đã gán',
      'pending': 'Đang làm',
      'in_review': 'Đang duyệt',
      'completed': 'Hoàn thành',
      'closed': 'Đã đóng',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          statusStats.entries.where((entry) => entry.value > 0).map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${statusNames[entry.key] ?? entry.key}: ${entry.value}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildFlagPieChart() {
    final flagStats = Map<String, int>.from(statisticsData!['flagStats'] ?? {});

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Phân bố mức độ ưu tiên',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                flex: 3,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 1,
                    centerSpaceRadius: 40,
                    sections: _buildFlagPieChartSections(flagStats),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: _buildFlagLegend(flagStats)),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildFlagPieChartSections(
    Map<String, int> flagStats,
  ) {
    final colors = {
      'none': Colors.grey[400]!,
      'low': Colors.green,
      'medium': Colors.yellow[700]!,
      'high': Colors.orange,
      'priority': Colors.red,
    };

    final total = flagStats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return flagStats.entries.where((entry) => entry.value > 0).map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Colors.grey,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildFlagLegend(Map<String, int> flagStats) {
    final colors = {
      'none': Colors.grey[400]!,
      'low': Colors.green,
      'medium': Colors.yellow[700]!,
      'high': Colors.orange,
      'priority': Colors.red,
    };

    final flagNames = {
      'none': 'Không có',
      'low': 'Thấp',
      'medium': 'Trung bình',
      'high': 'Cao',
      'priority': 'Ưu tiên',
    };

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          flagStats.entries.where((entry) => entry.value > 0).map((entry) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 1),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: colors[entry.key] ?? Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${flagNames[entry.key] ?? entry.key}: ${entry.value}',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }

  Widget _buildCompletionBarChart() {
    final completionStats = List<Map<String, dynamic>>.from(
      statisticsData!['completionStats'] ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhiệm vụ tạo và hoàn thành (7 ngày)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxCompletionValue(completionStats) + 1,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = completionStats[group.x.toInt()]['date'];
                    final value = rod.toY.round();
                    final type = rodIndex == 0 ? 'Tạo mới' : 'Hoàn thành';
                    return BarTooltipItem(
                      '$date\n$type: $value',
                      const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < completionStats.length) {
                        final date =
                            completionStats[value.toInt()]['date'] as String;
                        final parts = date.split('-');
                        return Text(
                          '${parts[2]}/${parts[1]}',
                          style: const TextStyle(fontSize: 8),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 8),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildCompletionBarGroups(completionStats),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLegendItem('Tạo mới', Colors.blue),
            const SizedBox(width: 12),
            _buildLegendItem('Hoàn thành', Colors.green),
          ],
        ),
      ],
    );
  }

  double _getMaxCompletionValue(List<Map<String, dynamic>> completionStats) {
    double max = 0;
    for (final stat in completionStats) {
      final created = (stat['created'] ?? 0).toDouble();
      final completed = (stat['completed'] ?? 0).toDouble();
      if (created > max) max = created;
      if (completed > max) max = completed;
    }
    return max;
  }

  List<BarChartGroupData> _buildCompletionBarGroups(
    List<Map<String, dynamic>> completionStats,
  ) {
    return completionStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (stat['created'] ?? 0).toDouble(),
            color: Colors.blue,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          BarChartRodData(
            toY: (stat['completed'] ?? 0).toDouble(),
            color: Colors.green,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildStatusChangeBarChart() {
    final statusChangeStats = List<Map<String, dynamic>>.from(
      statisticsData!['statusChangeStats'] ?? [],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hoạt động thay đổi trạng thái (7 ngày)',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: _getMaxStatusChangeValue(statusChangeStats) + 1,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final date = statusChangeStats[group.x.toInt()]['date'];
                    final value = rod.toY.round();
                    return BarTooltipItem(
                      '$date\nThay đổi: $value',
                      const TextStyle(color: Colors.white, fontSize: 10),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() >= 0 &&
                          value.toInt() < statusChangeStats.length) {
                        final date =
                            statusChangeStats[value.toInt()]['date'] as String;
                        final parts = date.split('-');
                        return Text(
                          '${parts[2]}/${parts[1]}',
                          style: const TextStyle(fontSize: 8),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 20,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 8),
                      );
                    },
                  ),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(color: Colors.grey[300]!, strokeWidth: 0.5);
                },
              ),
              borderData: FlBorderData(show: false),
              barGroups: _buildStatusChangeBarGroups(statusChangeStats),
            ),
          ),
        ),
      ],
    );
  }

  double _getMaxStatusChangeValue(
    List<Map<String, dynamic>> statusChangeStats,
  ) {
    double max = 0;
    for (final stat in statusChangeStats) {
      final changes = (stat['changes'] ?? 0).toDouble();
      if (changes > max) max = changes;
    }
    return max;
  }

  List<BarChartGroupData> _buildStatusChangeBarGroups(
    List<Map<String, dynamic>> statusChangeStats,
  ) {
    return statusChangeStats.asMap().entries.map((entry) {
      final index = entry.key;
      final stat = entry.value;

      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (stat['changes'] ?? 0).toDouble(),
            color: Colors.purple,
            width: 12,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
        ],
      );
    }).toList();
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10),
        ),
      ],
    );
  }
}
