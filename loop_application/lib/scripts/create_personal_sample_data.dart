import 'package:isar/isar.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/models/category.dart';
import 'package:loop_application/models/subtask.dart';

/// Script sinh dữ liệu mẫu cá nhân cho Isar database
/// Tạo 2-3 task mỗi ngày trong 1 tháng
/// 
/// Cách chạy:
/// 1. Mở terminal trong thư mục loop_application
/// 2. dart run lib/scripts/create_personal_sample_data.dart

void main() async {
  print('🚀 Bắt đầu sinh dữ liệu mẫu cá nhân...');
  
  try {
    // Mở Isar database với thư mục tạm thời
    final isar = await Isar.open([
      CategorySchema,
      TaskSchema,
      SubtaskSchema,
      UserSchema,
    ], directory: 'tmp_data');

    await createPersonalSampleData(isar);
    
    await isar.close();
    print('✅ Hoàn thành sinh dữ liệu mẫu cá nhân!');
    
  } catch (e) {
    print('❌ Lỗi khi sinh dữ liệu: $e');
  }
}

Future<void> createPersonalSampleData(Isar isar) async {
  print('📋 Tạo dữ liệu mẫu cá nhân...');

  // Xóa dữ liệu cũ
  await isar.writeTxn(() async {
    await isar.tasks.clear();
    await isar.users.clear();
  });
  print('🗑️ Đã xóa dữ liệu cũ');

  // Tạo user mẫu
  final testUser = User()
    ..username = 'testuser'
    ..displayName = 'Test User'
    ..email = 'test@example.com'
    ..token = 'test_token_123'
    ..userIdServer = 'test_server_id';

  await isar.writeTxn(() async {
    await isar.users.put(testUser);
  });
  print('👤 Đã tạo user test');

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

  // Tạo task cho 30 ngày (tháng 12/2024)
  final tasks = <Task>[];
  final baseDate = DateTime(2024, 12, 1);
  
  for (int day = 0; day < 30; day++) {
    final currentDate = baseDate.add(Duration(days: day));
    final tasksPerDay = 2 + (day % 2); // 2-3 task mỗi ngày
    
    for (int i = 0; i < tasksPerDay; i++) {
      final task = Task();
      
      // Thông tin cơ bản
      task.title = '${taskTemplates[day * tasksPerDay + i % taskTemplates.length]} - ${currentDate.day}/12';
      task.description = 'Nhiệm vụ được thực hiện vào ngày ${currentDate.day}/12/2024';
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
        task.note = 'Ghi chú cho task ngày ${currentDate.day}/12';
      }
      
      tasks.add(task);
    }
  }

  // Thêm một số task đặc biệt
  final specialTasks = [
    Task()
      ..title = 'Dự án quan trọng - Giai đoạn 1'
      ..description = 'Hoàn thành giai đoạn 1 của dự án quan trọng'
      ..category = 1
      ..isTeamTask = false
      ..deadline = DateTime(2024, 12, 15)
      ..status = 2
      ..flag = 4
      ..note = 'Dự án ưu tiên cao',
    
    Task()
      ..title = 'Dự án quan trọng - Giai đoạn 2'
      ..description = 'Hoàn thành giai đoạn 2 của dự án quan trọng'
      ..category = 1
      ..isTeamTask = false
      ..deadline = DateTime(2024, 12, 30)
      ..status = 3
      ..flag = 4
      ..note = 'Đang trong quá trình review',
    
    Task()
      ..title = 'Học tập và phát triển bản thân'
      ..description = 'Hoàn thành khóa học về công nghệ mới'
      ..category = 3
      ..isTeamTask = false
      ..deadline = DateTime(2024, 12, 25)
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

  print('\n📊 Thống kê dữ liệu được tạo:');
  print('   Total tasks: ${stats['total']}');
  print('   Pending: ${stats['pending']} | Completed: ${stats['completed']} | Review: ${stats['review']} | In Progress: ${stats['in_progress']}');
  print('   None: ${stats['none']} | Low: ${stats['low']} | Normal: ${stats['normal']} | High: ${stats['high']} | Urgent: ${stats['urgent']}');
  
  print('\n🎯 Thông tin user test:');
  print('   Username: testuser');
  print('   Display Name: Test User');
  print('   Email: test@example.com');
}
