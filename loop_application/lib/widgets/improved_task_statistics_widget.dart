import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../apis/task_api.dart';
import '../theme/theme.dart'; // Import theme để sử dụng ColorSchemeExtension

class ImprovedTaskStatisticsWidget extends StatefulWidget {
  final String projectId;

  const ImprovedTaskStatisticsWidget({Key? key, required this.projectId})
    : super(key: key);

  @override
  State<ImprovedTaskStatisticsWidget> createState() =>
      _ImprovedTaskStatisticsWidgetState();
}

class _ImprovedTaskStatisticsWidgetState
    extends State<ImprovedTaskStatisticsWidget> {
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
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Không thể tải thống kê',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Lỗi kết nối hoặc dữ liệu',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor:
                    Theme.of(context).colorScheme.onPrimaryContainer,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (statisticsData == null) {
      return Center(
        child: Text(
          'Không có dữ liệu thống kê',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadStatistics,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewCards(),
            const SizedBox(height: 16),
            _buildStatusPieChart(),
            const SizedBox(height: 16),
            _buildFlagPieChart(),
            const SizedBox(height: 16),
            _buildCompletionBarChart(),
            const SizedBox(height: 16),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Tổng NV',
                value: totalTasks.toString(),
                icon: Icons.assignment,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'Hoàn thành',
                value: completedTasks.toString(),
                icon: Icons.check_circle,
                color:
                    Theme.of(
                      context,
                    ).colorScheme.secondary, // Sử dụng màu từ theme
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildStatCard(
                title: 'TB: ${averageTime}d',
                value:
                    '${totalTasks > 0 ? (completedTasks / totalTasks * 100).toStringAsFixed(0) : 0}%',
                icon: Icons.access_time,
                color:
                    Theme.of(
                      context,
                    ).colorScheme.tertiary, // Sử dụng màu từ theme
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
        border: Border.all(color: color.withOpacity(0.3), width: 1),
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
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 10,
              color: Theme.of(context).colorScheme.onSurface,
            ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
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
      'created': Theme.of(context).colorScheme.outline,
      'assigned': Theme.of(context).colorScheme.primaryContainer,
      'pending': Theme.of(context).colorScheme.tertiary, // Orange từ theme
      'in_review': Theme.of(
        context,
      ).colorScheme.primary.withOpacity(0.7), // Purple-ish
      'completed': Theme.of(context).colorScheme.secondary, // Green từ theme
      'closed': Theme.of(context).colorScheme.error,
    };

    final total = statusStats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return statusStats.entries.where((entry) => entry.value > 0).map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Theme.of(context).colorScheme.outline,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }).toList();
  }

  Widget _buildStatusLegend(Map<String, int> statusStats) {
    final colors = {
      'created': Theme.of(context).colorScheme.outline,
      'assigned': Theme.of(context).colorScheme.primaryContainer,
      'pending': Theme.of(context).colorScheme.tertiary, // Orange từ theme
      'in_review': Theme.of(
        context,
      ).colorScheme.primary.withOpacity(0.7), // Purple-ish
      'completed': Theme.of(context).colorScheme.secondary, // Green từ theme
      'closed': Theme.of(context).colorScheme.error,
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
                      color:
                          colors[entry.key] ??
                          Theme.of(context).colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${statusNames[entry.key] ?? entry.key}: ${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 250,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
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
      'none': Theme.of(context).colorScheme.outline,
      'low': Theme.of(context).colorScheme.success, // Green từ extension
      'medium': Theme.of(context).colorScheme.yellow, // Yellow từ extension
      'high': Theme.of(context).colorScheme.warning, // Orange từ extension
      'priority': Theme.of(context).colorScheme.error, // Red
    };

    final total = flagStats.values.fold(0, (sum, value) => sum + value);
    if (total == 0) return [];

    return flagStats.entries.where((entry) => entry.value > 0).map((entry) {
      final percentage = (entry.value / total * 100);
      return PieChartSectionData(
        color: colors[entry.key] ?? Theme.of(context).colorScheme.outline,
        value: entry.value.toDouble(),
        title: '${percentage.toStringAsFixed(0)}%',
        radius: 60,
        titleStyle: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.onPrimary,
        ),
      );
    }).toList();
  }

  Widget _buildFlagLegend(Map<String, int> flagStats) {
    final colors = {
      'none': Theme.of(context).colorScheme.outline,
      'low': Theme.of(context).colorScheme.success,
      'medium': Theme.of(context).colorScheme.yellow,
      'high': Theme.of(context).colorScheme.warning,
      'priority': Theme.of(context).colorScheme.error,
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
                      color:
                          colors[entry.key] ??
                          Theme.of(context).colorScheme.outline,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      '${flagNames[entry.key] ?? entry.key}: ${entry.value}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
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
                      TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                      ),
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
                          style: TextStyle(
                            fontSize: 8,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                        style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                  return FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    strokeWidth: 0.5,
                  );
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
            _buildLegendItem(
              'Tạo mới',
              Theme.of(context).colorScheme.primaryContainer,
            ),
            const SizedBox(width: 12),
            _buildLegendItem('Hoàn thành', const Color(0xff4CAF50)),
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
            color: Theme.of(context).colorScheme.primaryContainer,
            width: 6,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
          ),
          BarChartRodData(
            toY: (stat['completed'] ?? 0).toDouble(),
            color: const Color(0xff4CAF50),
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
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 180,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
              width: 1,
            ),
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
                      TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 10,
                      ),
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
                          style: TextStyle(
                            fontSize: 8,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
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
                        style: TextStyle(
                          fontSize: 8,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
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
                  return FlLine(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.3),
                    strokeWidth: 0.5,
                  );
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
            color: const Color(0xff9C27B0), // Purple
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
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontSize: 10,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
