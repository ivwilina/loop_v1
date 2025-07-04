#!/usr/bin/env node

const mongoose = require('mongoose');
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
    await mongoose.connect(dbUrl, {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    });
    console.log('✅ Connected to MongoDB:', dbUrl);
  } catch (error) {
    console.error('❌ MongoDB connection failed:', error);
    process.exit(1);
  }
};

// Kiểm tra dữ liệu
const checkData = async () => {
  try {
    console.log('📊 Checking database contents...\n');

    // Đếm collections
    const teamCount = await Team.countDocuments();
    const userCount = await User.countDocuments();
    const projectCount = await Project.countDocuments();
    const taskCount = await Task.countDocuments();

    console.log('📈 Collection counts:');
    console.log(`  - Teams: ${teamCount}`);
    console.log(`  - Users: ${userCount}`);
    console.log(`  - Projects: ${projectCount}`);
    console.log(`  - Tasks: ${taskCount}\n`);

    if (teamCount === 0 && userCount === 0 && projectCount === 0 && taskCount === 0) {
      console.log('⚠️  Database is empty. Run "npm run setup-data" to create sample data.\n');
      return;
    }

    // Hiển thị teams
    console.log('👥 Teams:');
    const teams = await Team.find().populate({
      path: 'members.member',
      select: 'displayName email'
    });
    for (const team of teams) {
      console.log(`  📁 ${team.name}`);
      console.log(`     Members: ${team.members.length}`);
      console.log(`     Projects: ${team.project.length}`);
      
      // Hiển thị thành viên theo role
      const owner = team.members.find(m => m.role === 'owner');
      const admin = team.members.find(m => m.role === 'admin');
      const regularMembers = team.members.filter(m => m.role === 'member');
      
      if (owner && owner.member) {
        console.log(`     👑 Owner: ${owner.member.displayName || 'Unknown'}`);
      }
      if (admin && admin.member) {
        console.log(`     🛡️  Admin: ${admin.member.displayName || 'Unknown'}`);
      }
      if (regularMembers.length > 0) {
        const memberNames = regularMembers.slice(0, 3).map(m => m.member ? (m.member.displayName || 'Unknown') : 'Unknown').join(', ');
        console.log(`     👥 Members: ${memberNames}${regularMembers.length > 3 ? '...' : ''}`);
      }
      console.log();
    }

    // Hiển thị projects với thống kê
    console.log('📋 Projects with task statistics:');
    const projects = await Project.find().populate('task');
    for (const project of projects) {
      const tasks = project.task;
      const statusCounts = {
        created: 0,
        assigned: 0,
        pending: 0,
        in_review: 0,
        completed: 0,
        closed: 0
      };

      tasks.forEach(task => {
        if (statusCounts.hasOwnProperty(task.status)) {
          statusCounts[task.status]++;
        }
      });

      console.log(`  📂 ${project.name}`);
      console.log(`     Total tasks: ${tasks.length}`);
      console.log(`     Status breakdown: Created(${statusCounts.created}) Assigned(${statusCounts.assigned}) Pending(${statusCounts.pending}) Review(${statusCounts.in_review}) Completed(${statusCounts.completed}) Closed(${statusCounts.closed})`);
      console.log(`     Members: ${project.member ? project.member.length : 0}`);
      console.log();
    }

    // Thống kê tasks theo thời gian
    console.log('📅 Task creation timeline (last 7 days):');
    const sevenDaysAgo = new Date();
    sevenDaysAgo.setDate(sevenDaysAgo.getDate() - 7);

    const recentTasks = await Task.find({
      createTime: { $gte: sevenDaysAgo }
    }).sort({ createTime: -1 });

    const tasksByDate = {};
    recentTasks.forEach(task => {
      const date = task.createTime.toISOString().split('T')[0];
      tasksByDate[date] = (tasksByDate[date] || 0) + 1;
    });

    for (const [date, count] of Object.entries(tasksByDate)) {
      console.log(`  📅 ${date}: ${count} tasks`);
    }

    if (Object.keys(tasksByDate).length === 0) {
      console.log('  📅 No tasks created in the last 7 days');
    }

    console.log();

    // Sample project ID cho testing
    if (projects.length > 0) {
      console.log('🔧 Sample data for testing:');
      console.log(`  Sample Project ID: ${projects[0]._id}`);
      console.log(`  Sample Project Name: ${projects[0].name}`);
      console.log();
      
      console.log('💡 Test API endpoints:');
      console.log(`  GET /task/statistics/${projects[0]._id}`);
      console.log(`  GET /task/debug/members/${projects[0]._id}`);
      console.log();
    }

    // Sample user cho login
    const sampleUser = await User.findOne();
    if (sampleUser) {
      console.log('🔑 Sample login credentials:');
      console.log(`  Email: ${sampleUser.email}`);
      console.log(`  Password: password123`);
      console.log();
    }

    console.log('✅ Data check completed!');

  } catch (error) {
    console.error('❌ Error checking data:', error);
    throw error;
  }
};

// Hàm chạy chính
const main = async () => {
  try {
    await connectDB();
    await checkData();
    process.exit(0);
  } catch (error) {
    console.error('❌ Check failed:', error);
    process.exit(1);
  }
};

// Chạy nếu file được gọi trực tiếp
if (require.main === module) {
  main();
}

module.exports = {
  checkData,
  connectDB
};
