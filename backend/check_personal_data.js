const mongoose = require('mongoose');
const Task = require('./models/task.model');
const User = require('./models/user.model');

// Kết nối MongoDB
mongoose.connect('mongodb://localhost:27017/loop_db', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function checkPersonalData() {
  try {
    console.log('🔍 Kiểm tra dữ liệu cá nhân...\n');

    // Tìm user test
    const testUser = await User.findOne({ email: 'test@example.com' });
    if (!testUser) {
      console.log('❌ Không tìm thấy user test');
      return;
    }

    console.log('👤 User test:');
    console.log(`   ID: ${testUser._id}`);
    console.log(`   Name: ${testUser.name}`);
    console.log(`   Email: ${testUser.email}\n`);

    // Lấy tất cả task của user này
    const tasks = await Task.find({ assignee: testUser._id });
    console.log(`📋 Tổng số task: ${tasks.length}\n`);

    // Thống kê theo trạng thái
    const statusStats = {};
    tasks.forEach(task => {
      statusStats[task.status] = (statusStats[task.status] || 0) + 1;
    });

    console.log('📊 Thống kê theo trạng thái:');
    Object.entries(statusStats).forEach(([status, count]) => {
      console.log(`   ${status}: ${count}`);
    });

    // Thống kê theo flag
    const flagStats = {};
    tasks.forEach(task => {
      flagStats[task.flag] = (flagStats[task.flag] || 0) + 1;
    });

    console.log('\n🏳️ Thống kê theo flag:');
    Object.entries(flagStats).forEach(([flag, count]) => {
      console.log(`   ${flag}: ${count}`);
    });

    // Thống kê theo ngày tạo
    const dailyStats = {};
    tasks.forEach(task => {
      const date = task.createTime.toISOString().split('T')[0];
      dailyStats[date] = (dailyStats[date] || 0) + 1;
    });

    console.log('\n📅 Thống kê theo ngày tạo (top 10):');
    const topDays = Object.entries(dailyStats)
      .sort(([,a], [,b]) => b - a)
      .slice(0, 10);
    
    topDays.forEach(([date, count]) => {
      console.log(`   ${date}: ${count} task(s)`);
    });

    // Hiển thị một số task mẫu
    console.log('\n📝 Một số task mẫu:');
    tasks.slice(0, 5).forEach((task, index) => {
      console.log(`   ${index + 1}. ${task.title}`);
      console.log(`      Status: ${task.status} | Flag: ${task.flag}`);
      console.log(`      Created: ${task.createTime.toLocaleDateString()}`);
      console.log(`      Deadline: ${task.deadline ? task.deadline.toLocaleDateString() : 'N/A'}`);
      console.log(`      Logs: ${task.logs.length} entries\n`);
    });

    console.log('✅ Kiểm tra dữ liệu hoàn tất!');

  } catch (error) {
    console.error('❌ Lỗi khi kiểm tra dữ liệu:', error);
  } finally {
    mongoose.connection.close();
  }
}

// Chạy script
checkPersonalData();
