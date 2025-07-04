import 'package:flutter/material.dart';
import 'package:isar/isar.dart';
import 'package:loop_application/models/task.dart';

/// Service để tạo dữ liệu mẫu cá nhân
/// Sử dụng trong ứng dụng Flutter để tạo dữ liệu test
class PersonalDataService {
  static Future<void> createPersonalSampleData(Isar isar) async {
    debugPrint('📋 Bắt đầu tạo dữ liệu mẫu cá nhân...');

    // Xóa tất cả task cá nhân cũ
    await isar.writeTxn(() async {
      final allTasks = await isar.tasks.where().findAll();
      final personalTasks = allTasks.where((t) => t.isTeamTask == false).toList();
      final taskIds = personalTasks.map((t) => t.id).toList();
      await isar.tasks.deleteAll(taskIds);
    });
    debugPrint('🗑️ Đã xóa dữ liệu cũ');

    // Danh sách task templates
    final taskTemplates = [
      'Hoàn thành báo cáo hàng tuần',
      'Tham gia cuộc họp team',
      'Review code của đồng nghiệp',
      'Cập nhật tài liệu dự án',
      'Nghiên cứu công nghệ mới',
      'Sửa lỗi trong hệ thống',
      'Phát triển tính năng mới',
      'Kiểm tra và test ứng dụng',
      'Backup dữ liệu quan trọng',
      'Tối ưu hóa hiệu suất',
      'Chuẩn bị presentation',
      'Liên hệ với khách hàng',
      'Phân tích yêu cầu mới',
      'Thiết kế giao diện',
      'Viết unit test',
      'Refactor code cũ',
      'Học khóa học online',
      'Lập kế hoạch sprint',
      'Đọc tài liệu kỹ thuật',
      'Thảo luận với mentor'
    ];

    // Tạo task cho 30 ngày (1 tháng)
    final tasks = <Task>[];
    final baseDate = DateTime.now().subtract(const Duration(days: 30));
    
    for (int day = 0; day < 30; day++) {
      final currentDate = baseDate.add(Duration(days: day));
      final tasksPerDay = 2 + (day % 2); // 2-3 task mỗi ngày
      
      for (int i = 0; i < tasksPerDay; i++) {
        final task = Task();
        
        // Thông tin cơ bản
        task.title = '${taskTemplates[(day * tasksPerDay + i) % taskTemplates.length]} - ${currentDate.day}/${currentDate.month}';
        task.description = 'Nhiệm vụ được thực hiện vào ngày ${currentDate.day}/${currentDate.month}/${currentDate.year}';
        task.isTeamTask = false; // Task cá nhân
        task.teamTaskId = null;
        
        // Category (1: Công việc, 2: Cá nhân, 3: Học tập, 4: Sức khỏe, 5: Giải trí)
        task.category = 1 + (i % 5);
        
        // Deadline (1-7 ngày sau ngày tạo)
        task.deadline = currentDate.add(Duration(days: 1 + (i % 7)));
        
        // Status (1: pending, 2: completed, 3: review, 4: in_progress)
        final statusRand = (day + i) % 10;
        if (statusRand < 5) {
          task.status = 2; // 50% completed
        } else if (statusRand < 7) {
          task.status = 3; // 20% review
        } else if (statusRand < 9) {
          task.status = 4; // 20% in_progress
        } else {
          task.status = 1; // 10% pending
        }
        
        // Flag (0: none, 1: low, 2: normal, 3: high, 4: urgent)
        task.flag = i % 5;
        
        // Note ngẫu nhiên
        if (i % 3 == 0) {
          task.note = 'Ghi chú cho task ngày ${currentDate.day}/${currentDate.month}';
        }
        
        tasks.add(task);
      }
    }

    // Thêm một số task đặc biệt
    final now = DateTime.now();
    final specialTasks = [
      Task()
        ..title = 'Dự án quan trọng - Giai đoạn 1'
        ..description = 'Hoàn thành giai đoạn 1 của dự án quan trọng'
        ..category = 1
        ..isTeamTask = false
        ..deadline = now.add(const Duration(days: 15))
        ..status = 2
        ..flag = 4
        ..note = 'Dự án ưu tiên cao',
      
      Task()
        ..title = 'Dự án quan trọng - Giai đoạn 2'
        ..description = 'Hoàn thành giai đoạn 2 của dự án quan trọng'
        ..category = 1
        ..isTeamTask = false
        ..deadline = now.add(const Duration(days: 30))
        ..status = 3
        ..flag = 4
        ..note = 'Đang trong quá trình review',
      
      Task()
        ..title = 'Học tập và phát triển bản thân'
        ..description = 'Hoàn thành khóa học về công nghệ mới'
        ..category = 3
        ..isTeamTask = false
        ..deadline = now.add(const Duration(days: 25))
        ..status = 1
        ..flag = 2
        ..note = 'Mục tiêu phát triển cá nhân',
    ];

    tasks.addAll(specialTasks);

    // Lưu tất cả task vào Isar
    await isar.writeTxn(() async {
      await isar.tasks.putAll(tasks);
    });

    // Thống kê
    final stats = {
      'total': tasks.length,
      'pending': tasks.where((t) => t.status == 1).length,
      'completed': tasks.where((t) => t.status == 2).length,
      'review': tasks.where((t) => t.status == 3).length,
      'in_progress': tasks.where((t) => t.status == 4).length,
      'none': tasks.where((t) => t.flag == 0).length,
      'low': tasks.where((t) => t.flag == 1).length,
      'normal': tasks.where((t) => t.flag == 2).length,
      'high': tasks.where((t) => t.flag == 3).length,
      'urgent': tasks.where((t) => t.flag == 4).length,
    };

    debugPrint('📊 Thống kê dữ liệu được tạo:');
    debugPrint('   Total tasks: ${stats['total']}');
    debugPrint('   Pending: ${stats['pending']} | Completed: ${stats['completed']} | Review: ${stats['review']} | In Progress: ${stats['in_progress']}');
    debugPrint('   None: ${stats['none']} | Low: ${stats['low']} | Normal: ${stats['normal']} | High: ${stats['high']} | Urgent: ${stats['urgent']}');
    
    debugPrint('✅ Hoàn thành tạo ${tasks.length} task mẫu cá nhân!');
  }

  /// Kiểm tra dữ liệu cá nhân hiện có
  static Future<Map<String, dynamic>> getPersonalDataStats(Isar isar) async {
    final allTasks = await isar.tasks.where().findAll();
    final personalTasks = allTasks.where((t) => t.isTeamTask == false).toList();
    
    return {
      'total': personalTasks.length,
      'pending': personalTasks.where((t) => t.status == 1).length,
      'completed': personalTasks.where((t) => t.status == 2).length,
      'review': personalTasks.where((t) => t.status == 3).length,
      'in_progress': personalTasks.where((t) => t.status == 4).length,
      'categories': {
        'work': personalTasks.where((t) => t.category == 1).length,
        'personal': personalTasks.where((t) => t.category == 2).length,
        'learning': personalTasks.where((t) => t.category == 3).length,
        'health': personalTasks.where((t) => t.category == 4).length,
        'entertainment': personalTasks.where((t) => t.category == 5).length,
      }
    };
  }

  /// Xóa tất cả dữ liệu cá nhân
  static Future<void> clearPersonalData(Isar isar) async {
    await isar.writeTxn(() async {
      final allTasks = await isar.tasks.where().findAll();
      final personalTasks = allTasks.where((t) => t.isTeamTask == false).toList();
      final taskIds = personalTasks.map((t) => t.id).toList();
      await isar.tasks.deleteAll(taskIds);
    });
    debugPrint('🗑️ Đã xóa tất cả dữ liệu cá nhân');
  }
}
