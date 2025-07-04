#!/usr/bin/env node

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('./models/user.model');
const Project = require('./models/project.model');
const Task = require('./models/task.model');
const Team = require('./models/team.model');

// Kết nối MongoDB
const connectDB = async () => {
  try {
    const dbUrl = process.env.DATABASE_URL || 'mongodb://localhost:27017/loop_application_db';
    await mongoose.connect(dbUrl);
    console.log('✅ Connected to MongoDB:', dbUrl);
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Dữ liệu mẫu
const sampleData = {
  teams: [
    {
      name: 'Team Frontend',
      description: 'Đội phát triển giao diện người dùng',
      avatar: null
    },
    {
      name: 'Team Backend', 
      description: 'Đội phát triển hệ thống backend',
      avatar: null
    },
    {
      name: 'Team DevOps',
      description: 'Đội vận hành và triển khai hệ thống',
      avatar: null
    }
  ],
  
  users: [
    // Team Frontend (5 người)
    { fullName: 'Nguyễn Văn An', email: 'nguyen.van.an@example.com', teamIndex: 0, role: 'owner' },
    { fullName: 'Trần Thị Bảo', email: 'tran.thi.bao@example.com', teamIndex: 0, role: 'admin' },
    { fullName: 'Lê Minh Cường', email: 'le.minh.cuong@example.com', teamIndex: 0, role: 'member' },
    { fullName: 'Phạm Thu Dung', email: 'pham.thu.dung@example.com', teamIndex: 0, role: 'member' },
    { fullName: 'Hoàng Văn Em', email: 'hoang.van.em@example.com', teamIndex: 0, role: 'member' },
    
    // Team Backend (5 người)
    { fullName: 'Vũ Thị Phương', email: 'vu.thi.phuong@example.com', teamIndex: 1, role: 'owner' },
    { fullName: 'Đỗ Minh Quang', email: 'do.minh.quang@example.com', teamIndex: 1, role: 'admin' },
    { fullName: 'Bùi Thu Hương', email: 'bui.thu.huong@example.com', teamIndex: 1, role: 'member' },
    { fullName: 'Lý Văn Hùng', email: 'ly.van.hung@example.com', teamIndex: 1, role: 'member' },
    { fullName: 'Ngô Thị Lan', email: 'ngo.thi.lan@example.com', teamIndex: 1, role: 'member' },
    
    // Team DevOps (5 người)
    { fullName: 'Trịnh Văn Kiên', email: 'trinh.van.kien@example.com', teamIndex: 2, role: 'owner' },
    { fullName: 'Đinh Thị Mai', email: 'dinh.thi.mai@example.com', teamIndex: 2, role: 'admin' },
    { fullName: 'Phan Minh Nam', email: 'phan.minh.nam@example.com', teamIndex: 2, role: 'member' },
    { fullName: 'Võ Thu Oanh', email: 'vo.thu.oanh@example.com', teamIndex: 2, role: 'member' },
    { fullName: 'Đặng Văn Phúc', email: 'dang.van.phuc@example.com', teamIndex: 2, role: 'member' }
  ],

  projects: [
    // Team Frontend projects
    { 
      name: 'E-commerce Website', 
      description: 'Xây dựng website thương mại điện tử',
      teamIndex: 0 
    },
    { 
      name: 'Mobile App UI', 
      description: 'Thiết kế giao diện ứng dụng di động',
      teamIndex: 0 
    },
    { 
      name: 'Admin Dashboard', 
      description: 'Trang quản trị hệ thống',
      teamIndex: 0 
    },
    
    // Team Backend projects  
    { 
      name: 'API Gateway', 
      description: 'Xây dựng cổng API trung tâm',
      teamIndex: 1 
    },
    { 
      name: 'Microservices', 
      description: 'Phát triển kiến trúc microservices',
      teamIndex: 1 
    },
    { 
      name: 'Database Optimization', 
      description: 'Tối ưu hóa cơ sở dữ liệu',
      teamIndex: 1 
    },
    { 
      name: 'Authentication Service', 
      description: 'Dịch vụ xác thực và phân quyền',
      teamIndex: 1 
    },
    
    // Team DevOps projects
    { 
      name: 'CI/CD Pipeline', 
      description: 'Xây dựng pipeline tự động',
      teamIndex: 2 
    },
    { 
      name: 'Container Platform', 
      description: 'Triển khai nền tảng container',
      teamIndex: 2 
    },
    { 
      name: 'Monitoring System', 
      description: 'Hệ thống giám sát và cảnh báo',
      teamIndex: 2 
    }
  ],

  taskTemplates: [
    // Frontend tasks
    'Thiết kế giao diện trang chủ',
    'Implement responsive design',
    'Tối ưu hóa performance frontend',
    'Viết unit test cho components',
    'Setup webpack configuration',
    'Tích hợp với API backend',
    'Implement user authentication UI',
    'Thiết kế form validation',
    'Optimize bundle size',
    'Cross-browser testing',
    
    // Backend tasks
    'Thiết kế database schema',
    'Implement REST API endpoints',
    'Setup authentication middleware',
    'Viết integration tests',
    'Optimize database queries',
    'Setup logging system',
    'Implement caching strategy',
    'API documentation',
    'Security vulnerability scan',
    'Performance monitoring',
    
    // DevOps tasks
    'Setup Docker containers',
    'Configure Kubernetes cluster',
    'Setup monitoring dashboard',
    'Implement CI/CD pipeline',
    'Database backup strategy',
    'Security hardening',
    'Load balancer configuration',
    'SSL certificate setup',
    'Log aggregation setup',
    'Disaster recovery plan'
  ]
};

// Utility functions
const getRandomInt = (min, max) => Math.floor(Math.random() * (max - min + 1)) + min;
const getRandomElement = (array) => array[Math.floor(Math.random() * array.length)];
const getRandomDate = (start, end) => new Date(start.getTime() + Math.random() * (end.getTime() - start.getTime()));

const statuses = ['created', 'assigned', 'pending', 'in_review', 'completed', 'closed'];
const flags = ['none', 'low', 'medium', 'high', 'priority'];

// Tạo dữ liệu
const createSampleData = async () => {
  try {
    console.log('🧹 Cleaning existing data...');
    await User.deleteMany({});
    await Team.deleteMany({});
    await Project.deleteMany({});
    await Task.deleteMany({});

    console.log('👥 Creating teams...');
    const teams = [];
    for (const teamData of sampleData.teams) {
      const team = await Team.create({
        name: teamData.name,
        description: teamData.description,
        avatar: teamData.avatar,
        member: [],
        project: [],
        createTime: new Date()
      });
      teams.push(team);
      console.log(`  ✅ Created team: ${team.name}`);
    }

    console.log('👤 Creating users...');
    const users = [];
    // Không hash mật khẩu ở đây, để User model middleware xử lý
    
    for (const userData of sampleData.users) {
      // Tạo username từ email (lấy phần trước @)
      const username = userData.email.split('@')[0];
      
      const user = await User.create({
        username: username,
        displayName: userData.fullName,
        email: userData.email,
        password: 'password123', // Plain text password, sẽ được hash bởi middleware
        createTime: new Date()
      });
      users.push({ ...user.toObject(), teamIndex: userData.teamIndex, role: userData.role });
      
      // Thêm user vào team
      await Team.findByIdAndUpdate(
        teams[userData.teamIndex]._id,
        { $push: { 
          members: {
            member: user._id,
            role: userData.role,
            joined_date: new Date()
          }
        }}
      );
      
      console.log(`  ✅ Created user: ${userData.fullName} (${teams[userData.teamIndex].name}) - Role: ${userData.role}`);
    }

    console.log('📋 Creating projects...');
    const projects = [];
    for (const projectData of sampleData.projects) {
      const teamMembers = users.filter(u => u.teamIndex === projectData.teamIndex);
      const project = await Project.create({
        name: projectData.name,
        description: projectData.description,
        assignedMembers: teamMembers.map(u => u._id),
        task: [],
        createTime: new Date()
      });
      projects.push({ ...project.toObject(), teamIndex: projectData.teamIndex });
      
      // Thêm project vào team
      await Team.findByIdAndUpdate(
        teams[projectData.teamIndex]._id,
        { $push: { project: project._id } }
      );
      
      console.log(`  ✅ Created project: ${project.name}`);
    }

    console.log('📝 Creating tasks...');
    const now = new Date();
    const twoMonthsAgo = new Date(now.getTime() - 60 * 24 * 60 * 60 * 1000); // 60 ngày trước
    
    let totalTasks = 0;
    for (const project of projects) {
      const teamMembers = users.filter(u => u.teamIndex === project.teamIndex);
      const projectTasks = [];
      
      // Tạo tasks cho 60 ngày
      for (let day = 0; day < 60; day++) {
        const currentDate = new Date(twoMonthsAgo.getTime() + day * 24 * 60 * 60 * 1000);
        const tasksPerDay = getRandomInt(0, 7);
        
        for (let i = 0; i < tasksPerDay; i++) {
          const assignee = getRandomElement(teamMembers);
          const status = getRandomElement(statuses);
          const flag = getRandomElement(flags);
          const title = getRandomElement(sampleData.taskTemplates);
          
          // Tạo thời gian ngẫu nhiên trong ngày
          const createTime = new Date(currentDate);
          createTime.setHours(getRandomInt(8, 18), getRandomInt(0, 59), getRandomInt(0, 59));
          
          // Tính thời gian đóng nếu task đã hoàn thành
          let closeTime = null;
          if (status === 'completed' || status === 'closed') {
            const daysToComplete = getRandomInt(1, 14); // 1-14 ngày để hoàn thành
            closeTime = new Date(createTime.getTime() + daysToComplete * 24 * 60 * 60 * 1000);
          }
          
          // Tạo logs cho task
          const logs = [
            {
              action: 'created',
              timestamp: createTime,
              performedBy: assignee._id,
              details: 'Task created'
            }
          ];
          
          if (status !== 'created') {
            logs.push({
              action: 'assigned',
              timestamp: new Date(createTime.getTime() + 60000), // 1 phút sau
              performedBy: assignee._id,
              details: 'Task assigned'
            });
          }
          
          if (status === 'pending') {
            logs.push({
              action: 'pending',
              timestamp: new Date(createTime.getTime() + getRandomInt(3600000, 86400000)), // 1-24h sau
              performedBy: assignee._id,
              details: 'Changed status to pending'
            });
          }
          
          if (status === 'in_review') {
            logs.push({
              action: 'in_review',
              timestamp: new Date(createTime.getTime() + getRandomInt(3600000, 86400000)),
              performedBy: assignee._id,
              details: 'Changed status to in_review'
            });
          }
          
          if (status === 'completed' || status === 'closed') {
            logs.push({
              action: 'completed',
              timestamp: closeTime,
              performedBy: assignee._id,
              details: 'Task completed'
            });
          }

          const task = await Task.create({
            title: `${title} - ${project.name}`,
            description: `Chi tiết thực hiện ${title.toLowerCase()} cho dự án ${project.name}`,
            deadline: new Date(createTime.getTime() + getRandomInt(7, 30) * 24 * 60 * 60 * 1000), // 7-30 ngày deadline
            status: status,
            flag: flag,
            assignee: assignee._id,
            subtasks: [],
            attachments: [],
            createTime: createTime,
            closeTime: closeTime,
            logs: logs
          });
          
          projectTasks.push(task._id);
          totalTasks++;
        }
      }
      
      // Cập nhật project với danh sách tasks
      await Project.findByIdAndUpdate(
        project._id,
        { task: projectTasks }
      );
      
      console.log(`  ✅ Created ${projectTasks.length} tasks for project: ${project.name}`);
    }

    console.log('\n🎉 Sample data creation completed!');
    console.log(`📊 Summary:`);
    console.log(`  - Teams: ${teams.length}`);
    console.log(`  - Users: ${users.length}`);
    console.log(`  - Projects: ${projects.length}`);
    console.log(`  - Tasks: ${totalTasks}`);
    
    console.log('\n📋 Team distribution:');
    for (let i = 0; i < teams.length; i++) {
      const teamUsers = users.filter(u => u.teamIndex === i);
      const teamProjects = projects.filter(p => p.teamIndex === i);
      console.log(`  - ${teams[i].name}: ${teamUsers.length} users, ${teamProjects.length} projects`);
    }

    console.log('\n🔑 Default credentials:');
    console.log('  - Email: [any user email from above]');
    console.log('  - Password: password123');
    
    console.log('\n💡 Example API calls:');
    console.log('  - Get project statistics: GET /task/statistics/{projectId}');
    console.log('  - Debug member stats: GET /task/debug/members/{projectId}');

  } catch (error) {
    console.error('❌ Error creating sample data:', error);
    throw error;
  }
};

// Hàm chạy chính
const main = async () => {
  try {
    await connectDB();
    await createSampleData();
    console.log('\n✅ Setup completed successfully!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Setup failed:', error);
    process.exit(1);
  }
};

// Chạy nếu file được gọi trực tiếp
if (require.main === module) {
  main();
}

module.exports = {
  createSampleData,
  connectDB
};
