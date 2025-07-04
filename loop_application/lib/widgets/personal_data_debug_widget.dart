import 'package:flutter/material.dart';
import 'package:loop_application/services/personal_data_service.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:provider/provider.dart';

/// Widget debug để tạo và quản lý dữ liệu mẫu cá nhân
class PersonalDataDebugWidget extends StatefulWidget {
  const PersonalDataDebugWidget({super.key});

  @override
  State<PersonalDataDebugWidget> createState() => _PersonalDataDebugWidgetState();
}

class _PersonalDataDebugWidgetState extends State<PersonalDataDebugWidget> {
  bool _isLoading = false;
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await PersonalDataService.getPersonalDataStats(TaskModel.isar);
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      debugPrint('Lỗi khi tải thống kê: $e');
    }
  }

  Future<void> _createSampleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PersonalDataService.createPersonalSampleData(TaskModel.isar);
      
      // Refresh TaskModel
      if (mounted) {
        Provider.of<TaskModel>(context, listen: false).findAll();
      }
      
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Đã tạo dữ liệu mẫu cá nhân thành công!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi tạo dữ liệu mẫu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _clearData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await PersonalDataService.clearPersonalData(TaskModel.isar);
      
      // Refresh TaskModel
      if (mounted) {
        Provider.of<TaskModel>(context, listen: false).findAll();
      }
      
      await _loadStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('🗑️ Đã xóa dữ liệu cá nhân thành công!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi xóa dữ liệu: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.science, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Dữ liệu mẫu cá nhân',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            if (_stats != null) ...[
              Text(
                'Thống kê hiện tại:',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Tổng', _stats!['total']?.toString() ?? '0'),
                        _buildStatItem('Hoàn thành', _stats!['completed']?.toString() ?? '0'),
                        _buildStatItem('Đang làm', _stats!['pending']?.toString() ?? '0'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Danh mục: Công việc ${_stats!['categories']?['work'] ?? 0} | '
                      'Cá nhân ${_stats!['categories']?['personal'] ?? 0} | '
                      'Học tập ${_stats!['categories']?['learning'] ?? 0}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _createSampleData,
                    icon: _isLoading 
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.add_circle),
                    label: const Text('Tạo dữ liệu mẫu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearData,
                    icon: const Icon(Icons.delete_forever),
                    label: const Text('Xóa dữ liệu'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            Text(
              'Tạo ~75 task cá nhân (2-3 task/ngày trong 1 tháng)',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.blue,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
