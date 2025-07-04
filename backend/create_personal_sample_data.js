const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const Task = require('./models/task.model');
const User = require('./models/user.model');

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/loop_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

// Danh sách task templates
const taskTemplates = [
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

const priorities = ['none', 'low', 'medium', 'high', 'priority'];
const statuses = ['created', 'assigned', 'pending', 'in_review', 'completed', 'closed'];

// Hàm tạo ngày ngẫu nhiên trong tháng
function getRandomDateInMonth(year = 2024, month = 11) {
  const day = Math.floor(Math.random() * 30) + 1;
  return new Date(year, month, day);
}

// Hàm tạo deadline ngẫu nhiên
function getRandomDeadline(createdDate) {
  const daysToAdd = Math.floor(Math.random() * 10) + 1; // 1-10 ngày
  const deadline = new Date(createdDate);
  deadline.setDate(deadline.getDate() + daysToAdd);
  return deadline;
}

// Hàm sinh dữ liệu mẫu cho user cá nhân
async function createPersonalSampleData() {
  try {
    console.log('🚀 Bắt đầu sinh dữ liệu mẫu cá nhân...');

    // Tạo hoặc tìm user test
    let testUser = await User.findOne({ email: 'test@example.com' });
    
    if (!testUser) {
      const hashedPassword = await bcrypt.hash('123456', 10);
      testUser = new User({
        name: 'Test User',
        email: 'test@example.com',
        password: hashedPassword,
        position: 'Developer',
        department: 'IT',
        phone: '0123456789',
        avatar: 'https://example.com/avatar.jpg'
      });
      await testUser.save();
      console.log('✅ Đã tạo user test');
    }

    // Xóa các task cũ của user này
    await Task.deleteMany({ createdBy: testUser._id });
    console.log('🗑️ Đã xóa dữ liệu cũ');

    // Tạo 2-3 task mỗi ngày trong tháng 12/2024
    const tasks = [];
    for (let day = 1; day <= 30; day++) {
      const tasksPerDay = Math.floor(Math.random() * 2) + 2; // 2-3 task/ngày
      
      for (let i = 0; i < tasksPerDay; i++) {
        const createdDate = new Date(2024, 11, day); // Tháng 12/2024
        const taskName = taskTemplates[Math.floor(Math.random() * taskTemplates.length)];
        const priority = priorities[Math.floor(Math.random() * priorities.length)];
        
        // Phân phối trạng thái có trọng số
        let status;
        const rand = Math.random();
        if (rand < 0.5) status = 'completed';     // 50% completed
        else if (rand < 0.7) status = 'in_review'; // 20% in_review
        else if (rand < 0.85) status = 'pending';  // 15% pending
        else status = 'created';                   // 15% created

        // Tạo thời gian hoàn thành cho task đã completed
        let closeTime = null;
        if (status === 'completed') {
          closeTime = new Date(createdDate);
          closeTime.setHours(createdDate.getHours() + Math.floor(Math.random() * 8) + 1);
        }

        const task = {
          title: `${taskName} - Ngày ${day}/12`, // Sửa từ 'name' thành 'title'
          description: `Nhiệm vụ ${taskName.toLowerCase()} được thực hiện vào ngày ${day}/12/2024`,
          flag: priority, // Sửa từ 'priority' thành 'flag'
          status: status,
          deadline: getRandomDeadline(createdDate),
          assignee: testUser._id, // Thêm assignee
          createTime: createdDate,
          closeTime: closeTime,
          // Thêm logs
          logs: [{
            action: 'created',
            timestamp: createdDate,
            performedBy: testUser._id,
            details: `Task được tạo vào ngày ${day}/12/2024`
          }]
        };

        // Thêm log completed nếu task đã hoàn thành
        if (status === 'completed' && closeTime) {
          task.logs.push({
            action: 'completed',
            timestamp: closeTime,
            performedBy: testUser._id,
            details: 'Task đã được hoàn thành'
          });
        }

        tasks.push(task);
      }
    }

    // Thêm một số task đặc biệt
    const specialTasks = [
      {
        title: 'Dự án quan trọng - Giai đoạn 1',
        description: 'Hoàn thành giai đoạn 1 của dự án quan trọng',
        flag: 'high',
        status: 'completed',
        deadline: new Date(2024, 11, 15),
        assignee: testUser._id,
        createTime: new Date(2024, 11, 1),
        closeTime: new Date(2024, 11, 10),
        logs: [
          {
            action: 'created',
            timestamp: new Date(2024, 11, 1),
            performedBy: testUser._id,
            details: 'Dự án quan trọng được tạo'
          },
          {
            action: 'completed',
            timestamp: new Date(2024, 11, 10),
            performedBy: testUser._id,
            details: 'Hoàn thành giai đoạn 1'
          }
        ]
      },
      {
        title: 'Dự án quan trọng - Giai đoạn 2',
        description: 'Hoàn thành giai đoạn 2 của dự án quan trọng',
        flag: 'high',
        status: 'in_review',
        deadline: new Date(2024, 11, 30),
        assignee: testUser._id,
        createTime: new Date(2024, 11, 11),
        logs: [
          {
            action: 'created',
            timestamp: new Date(2024, 11, 11),
            performedBy: testUser._id,
            details: 'Giai đoạn 2 được tạo'
          },
          {
            action: 'in_review',
            timestamp: new Date(2024, 11, 20),
            performedBy: testUser._id,
            details: 'Chuyển sang review'
          }
        ]
      },
      {
        title: 'Học tập và phát triển bản thân',
        description: 'Hoàn thành khóa học về công nghệ mới',
        flag: 'medium',
        status: 'created',
        deadline: new Date(2024, 11, 25),
        assignee: testUser._id,
        createTime: new Date(2024, 11, 5),
        logs: [
          {
            action: 'created',
            timestamp: new Date(2024, 11, 5),
            performedBy: testUser._id,
            details: 'Tạo mục tiêu học tập'
          }
        ]
      }
    ];

    tasks.push(...specialTasks);

    // Lưu tất cả task vào database
    await Task.insertMany(tasks);
    console.log(`✅ Đã tạo ${tasks.length} task mẫu cho user cá nhân`);

    // Thống kê
    const stats = {
      total: tasks.length,
      created: tasks.filter(t => t.status === 'created').length,
      assigned: tasks.filter(t => t.status === 'assigned').length,
      pending: tasks.filter(t => t.status === 'pending').length,
      in_review: tasks.filter(t => t.status === 'in_review').length,
      completed: tasks.filter(t => t.status === 'completed').length,
      closed: tasks.filter(t => t.status === 'closed').length,
      none: tasks.filter(t => t.flag === 'none').length,
      low: tasks.filter(t => t.flag === 'low').length,
      medium: tasks.filter(t => t.flag === 'medium').length,
      high: tasks.filter(t => t.flag === 'high').length,
      priority: tasks.filter(t => t.flag === 'priority').length
    };

    console.log('\n📊 Thống kê dữ liệu được tạo:');
    console.log(`   Total tasks: ${stats.total}`);
    console.log(`   Created: ${stats.created} | Assigned: ${stats.assigned} | Pending: ${stats.pending}`);
    console.log(`   In Review: ${stats.in_review} | Completed: ${stats.completed} | Closed: ${stats.closed}`);
    console.log(`   None: ${stats.none} | Low: ${stats.low} | Medium: ${stats.medium} | High: ${stats.high} | Priority: ${stats.priority}`);

    console.log('\n🎯 Thông tin đăng nhập:');
    console.log('   Email: test@example.com');
    console.log('   Password: 123456');
    console.log('\n✅ Hoàn thành sinh dữ liệu mẫu cá nhân!');

  } catch (error) {
    console.error('❌ Lỗi khi sinh dữ liệu:', error);
  } finally {
    mongoose.connection.close();
  }
}

// Chạy script
createPersonalSampleData();
