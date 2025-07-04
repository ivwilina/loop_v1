const mongoose = require('mongoose');
const User = require('./models/user.model');
const Task = require('./models/task.model');
const bcrypt = require('bcryptjs');

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/loop_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
})
.then(() => console.log('✅ Connected to MongoDB'))
.catch(err => console.error('❌ MongoDB connection error:', err));

// Tạo dữ liệu mẫu phong phú cho thống kê
async function createRichSampleData() {
  try {
    console.log('🚀 Creating rich sample data for statistics...');
    
    // Xóa dữ liệu cũ
    await User.deleteMany({});
    await Task.deleteMany({});
    
    // Tạo user mẫu
    const hashedPassword = await bcrypt.hash('123456', 10);
    const user = new User({
      username: 'testuser',
      email: 'test@example.com',
      displayName: 'Test User',
      password: hashedPassword
    });
    await user.save();
    console.log('✅ Created user:', user.displayName);
    
    // Tạo nhiệm vụ cá nhân đa dạng
    const personalTasks = [];
    
    // Tạo 100 nhiệm vụ cá nhân với dữ liệu đa dạng
    for (let i = 0; i < 100; i++) {
      const createTime = generateCreatedDate(i);
      const task = {
        title: generateTaskTitle(i),
        description: generateTaskDescription(i),
        status: generateWeightedStatus(), // Trạng thái có trọng số
        flag: generateWeightedFlag(), // Ưu tiên có trọng số
        deadline: generateDeadline(i),
        createTime: createTime, // Thêm trường bắt buộc
        attachments: Math.random() > 0.7 ? ['file1.pdf', 'file2.docx'] : [],
        logs: [{
          action: 'created',
          timestamp: createTime,
          performedBy: user._id,
          details: 'Personal task created'
        }]
      };
      personalTasks.push(task);
    }
    
    // Tạo một số nhiệm vụ nhóm với assignee
    for (let i = 0; i < 20; i++) {
      const createTime = new Date(Date.now() - Math.random() * 30 * 24 * 60 * 60 * 1000);
      const task = {
        title: `Team Task ${i + 1}`,
        description: `Team task description ${i + 1}`,
        status: ['created', 'assigned', 'pending', 'in_review', 'completed', 'closed'][Math.floor(Math.random() * 6)],
        flag: ['none', 'low', 'medium', 'high', 'priority'][Math.floor(Math.random() * 5)],
        deadline: new Date(Date.now() + Math.random() * 30 * 24 * 60 * 60 * 1000),
        createTime: createTime,
        assignee: user._id, // Nhiệm vụ nhóm có assignee
        attachments: [],
        logs: [{
          action: 'created',
          timestamp: createTime,
          performedBy: user._id,
          details: 'Team task created'
        }]
      };
      personalTasks.push(task);
    }
    
    // Lưu tất cả tasks
    await Task.insertMany(personalTasks);
    console.log(`✅ Created ${personalTasks.length} tasks`);
    
    // Hiển thị thống kê
    await displayStatistics();
    
  } catch (error) {
    console.error('❌ Error creating sample data:', error);
  }
}

// Tạo title đa dạng
function generateTaskTitle(index) {
  const types = [
    'Phát triển', 'Kiểm thử', 'Thiết kế', 'Tài liệu', 'Nghiên cứu',
    'Coding', 'Debug', 'Review', 'UI Design', 'API Development',
    'Testing', 'Documentation', 'Research', 'Planning', 'Meeting'
  ];
  const subjects = [
    'Login Module', 'Dashboard', 'API Endpoint', 'Database Schema',
    'User Interface', 'Mobile App', 'Web Service', 'Authentication',
    'Data Migration', 'Performance Optimization', 'Security Audit',
    'Code Review', 'System Architecture', 'Project Planning'
  ];
  
  const type = types[index % types.length];
  const subject = subjects[index % subjects.length];
  return `${type} - ${subject} ${index + 1}`;
}

// Tạo description đa dạng
function generateTaskDescription(index) {
  const descriptions = [
    'Thực hiện phát triển tính năng mới cho hệ thống quản lý nhiệm vụ',
    'Kiểm thử và tìm lỗi trong module đăng nhập của ứng dụng',
    'Thiết kế giao diện người dùng cho trang dashboard chính',
    'Viết tài liệu hướng dẫn sử dụng cho người dùng cuối',
    'Nghiên cứu và đánh giá công nghệ mới phù hợp với dự án',
    'Implement new authentication system with JWT tokens',
    'Debug performance issues in the main application',
    'Create responsive design for mobile devices',
    'Write unit tests for critical business logic',
    'Optimize database queries for better performance',
    'Conduct security audit for the entire system',
    'Review and merge pull requests from team members',
    'Plan and estimate tasks for the upcoming sprint',
    'Integrate third-party APIs for enhanced functionality',
    'Refactor legacy code to improve maintainability'
  ];
  
  const base = descriptions[index % descriptions.length];
  const complexity = Math.floor(Math.random() * 3);
  
  if (complexity === 0) {
    return base;
  } else if (complexity === 1) {
    return base + ' Cần phối hợp với team khác và có deadline gấp.';
  } else {
    return base + ' Đây là nhiệm vụ phức tạp đòi hỏi nghiên cứu sâu, phối hợp nhiều bộ phận và có thể ảnh hưởng đến toàn bộ hệ thống. Cần thực hiện theo từng giai đoạn và có kế hoạch rollback.';
  }
}

// Tạo trạng thái có trọng số (realistic distribution)
function generateWeightedStatus() {
  const weights = [
    { status: 'created', weight: 10 },    // Mới tạo
    { status: 'assigned', weight: 15 },   // Đã giao
    { status: 'completed', weight: 40 },  // Hoàn thành
    { status: 'pending', weight: 20 },    // Đang làm
    { status: 'in_review', weight: 10 },  // Xem xét
    { status: 'closed', weight: 5 }       // Đóng
  ];
  
  const totalWeight = weights.reduce((sum, item) => sum + item.weight, 0);
  let random = Math.random() * totalWeight;
  
  for (const item of weights) {
    random -= item.weight;
    if (random <= 0) {
      return item.status;
    }
  }
  return 'created';
}

// Tạo ưu tiên có trọng số
function generateWeightedFlag() {
  const weights = [
    { flag: 'none', weight: 30 },     // Không có
    { flag: 'low', weight: 25 },      // Thấp
    { flag: 'medium', weight: 25 },   // Trung bình
    { flag: 'high', weight: 15 },     // Cao
    { flag: 'priority', weight: 5 }   // Ưu tiên
  ];
  
  const totalWeight = weights.reduce((sum, item) => sum + item.weight, 0);
  let random = Math.random() * totalWeight;
  
  for (const item of weights) {
    random -= item.weight;
    if (random <= 0) {
      return item.flag;
    }
  }
  return 'none';
}

// Tạo deadline đa dạng
function generateDeadline(index) {
  const now = new Date();
  const options = [
    // Hôm nay
    new Date(now.getFullYear(), now.getMonth(), now.getDate(), 23, 59, 59),
    // Ngày mai
    new Date(now.getFullYear(), now.getMonth(), now.getDate() + 1, 23, 59, 59),
    // Tuần này
    new Date(now.getTime() + Math.random() * 7 * 24 * 60 * 60 * 1000),
    // Tháng này
    new Date(now.getTime() + Math.random() * 30 * 24 * 60 * 60 * 1000),
    // Sau tháng này
    new Date(now.getTime() + (30 + Math.random() * 90) * 24 * 60 * 60 * 1000),
    // Quá khứ (quá hạn)
    new Date(now.getTime() - Math.random() * 30 * 24 * 60 * 60 * 1000)
  ];
  
  const weights = [5, 8, 25, 35, 20, 7]; // Trọng số cho các khoảng thời gian
  const totalWeight = weights.reduce((sum, w) => sum + w, 0);
  let random = Math.random() * totalWeight;
  
  for (let i = 0; i < weights.length; i++) {
    random -= weights[i];
    if (random <= 0) {
      return options[i];
    }
  }
  
  return options[0];
}

// Tạo ngày tạo
function generateCreatedDate(index) {
  const now = new Date();
  return new Date(now.getTime() - Math.random() * 90 * 24 * 60 * 60 * 1000);
}

// Hiển thị thống kê
async function displayStatistics() {
  try {
    console.log('\n📊 STATISTICS SUMMARY:');
    console.log('=' * 50);
    
    const totalTasks = await Task.countDocuments();
    const personalTasks = await Task.countDocuments({ assignee: null }); // Không có assignee = cá nhân
    const teamTasks = await Task.countDocuments({ assignee: { $ne: null } }); // Có assignee = nhóm
    
    console.log(`📋 Total Tasks: ${totalTasks}`);
    console.log(`👤 Personal Tasks: ${personalTasks}`);
    console.log(`👥 Team Tasks: ${teamTasks}`);
    
    // Thống kê theo trạng thái
    console.log('\n📈 STATUS DISTRIBUTION:');
    const statusStats = await Task.aggregate([
      { $match: { assignee: null } }, // Chỉ nhiệm vụ cá nhân
      { $group: { _id: '$status', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    
    const statusNames = {
      'created': 'Mới tạo',
      'assigned': 'Đã giao',
      'pending': 'Đang làm',
      'in_review': 'Xem xét',
      'completed': 'Hoàn thành',
      'closed': 'Đóng'
    };
    statusStats.forEach(stat => {
      const name = statusNames[stat._id] || 'Unknown';
      console.log(`  ${name}: ${stat.count}`);
    });
    
    // Thống kê theo ưu tiên
    console.log('\n🚩 PRIORITY DISTRIBUTION:');
    const priorityStats = await Task.aggregate([
      { $match: { assignee: null } }, // Chỉ nhiệm vụ cá nhân
      { $group: { _id: '$flag', count: { $sum: 1 } } },
      { $sort: { _id: 1 } }
    ]);
    
    const priorityNames = {
      'none': 'Không có',
      'low': 'Thấp',
      'medium': 'Trung bình',
      'high': 'Cao',
      'priority': 'Ưu tiên'
    };
    priorityStats.forEach(stat => {
      const name = priorityNames[stat._id] || 'Unknown';
      console.log(`  ${name}: ${stat.count}`);
    });
    
    // Thống kê theo danh mục (bỏ qua vì backend không có category)
    console.log('\n📂 CATEGORY DISTRIBUTION:');
    console.log('  (Backend schema does not have category field)');
    
    // Thống kê theo thời hạn
    console.log('\n⏰ DEADLINE DISTRIBUTION:');
    const now = new Date();
    const today = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const tomorrow = new Date(today.getTime() + 24 * 60 * 60 * 1000);
    const nextWeek = new Date(today.getTime() + 7 * 24 * 60 * 60 * 1000);
    const nextMonth = new Date(today.getTime() + 30 * 24 * 60 * 60 * 1000);
    
    const deadlineToday = await Task.countDocuments({ 
      assignee: null,
      deadline: { $gte: today, $lt: tomorrow }
    });
    
    const deadlineTomorrow = await Task.countDocuments({ 
      assignee: null,
      deadline: { $gte: tomorrow, $lt: new Date(tomorrow.getTime() + 24 * 60 * 60 * 1000) }
    });
    
    const deadlineThisWeek = await Task.countDocuments({ 
      assignee: null,
      deadline: { $gte: tomorrow, $lt: nextWeek }
    });
    
    const deadlineThisMonth = await Task.countDocuments({ 
      assignee: null,
      deadline: { $gte: nextWeek, $lt: nextMonth }
    });
    
    const deadlineOverdue = await Task.countDocuments({ 
      assignee: null,
      deadline: { $lt: today }
    });
    
    console.log(`  Hôm nay: ${deadlineToday}`);
    console.log(`  Ngày mai: ${deadlineTomorrow}`);
    console.log(`  Tuần này: ${deadlineThisWeek}`);
    console.log(`  Tháng này: ${deadlineThisMonth}`);
    console.log(`  Quá hạn: ${deadlineOverdue}`);
    
    // Tỷ lệ hoàn thành
    const completedTasks = await Task.countDocuments({ assignee: null, status: 'completed' });
    const completionRate = personalTasks > 0 ? ((completedTasks / personalTasks) * 100).toFixed(1) : '0.0';
    console.log(`\n✅ COMPLETION RATE: ${completionRate}%`);
    
    // Nhiệm vụ có attachment
    const tasksWithAttachment = await Task.countDocuments({ 
      assignee: null,
      attachments: { $exists: true, $ne: [] }
    });
    console.log(`📎 Tasks with attachments: ${tasksWithAttachment}`);
    
    // Nhiệm vụ có description
    const tasksWithDescription = await Task.countDocuments({ 
      assignee: null,
      description: { $exists: true, $ne: null, $ne: '' }
    });
    console.log(`📝 Tasks with description: ${tasksWithDescription}`);
    
    console.log('\n✅ Sample data created successfully!');
    console.log('🎯 You can now test the personal statistics widgets in Flutter app');
    
  } catch (error) {
    console.error('❌ Error displaying statistics:', error);
  }
}

// Chạy script
if (require.main === module) {
  createRichSampleData()
    .then(() => {
      console.log('\n🎉 Rich sample data creation completed!');
      process.exit(0);
    })
    .catch(error => {
      console.error('❌ Script failed:', error);
      process.exit(1);
    });
}

module.exports = { createRichSampleData };
