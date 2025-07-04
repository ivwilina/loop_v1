#!/usr/bin/env node

const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Project = require('./models/project.model');
const User = require('./models/user.model');
const Task = require('./models/task.model');

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

const debugProjectData = async () => {
  try {
    console.log('🔍 Debugging project data...\n');
    
    // Lấy project đầu tiên
    const project = await Project.findOne();
    
    if (!project) {
      console.log('❌ No project found');
      return;
    }
    
    console.log('📋 Project:', project.name);
    console.log('📋 Project ID:', project._id);
    console.log('👥 Assigned Members count:', project.assignedMembers ? project.assignedMembers.length : 0);
    console.log('📝 Tasks count:', project.task ? project.task.length : 0);
    
    // Hiển thị thông tin thành viên
    if (project.assignedMembers && project.assignedMembers.length > 0) {
      console.log('\n👥 Assigned Members:');
      for (let i = 0; i < project.assignedMembers.length; i++) {
        const memberId = project.assignedMembers[i];
        console.log(`   ${i + 1}. ID: ${memberId}`);
        
        try {
          const user = await User.findById(memberId);
          if (user) {
            console.log(`      Name: ${user.displayName}`);
            console.log(`      Email: ${user.email}`);
          } else {
            console.log(`      User not found!`);
          }
        } catch (err) {
          console.log(`      Error fetching user: ${err.message}`);
        }
      }
    }
    
    // Lấy tasks của project
    console.log('\n📝 Project Tasks:');
    const tasks = await Task.find({ _id: { $in: project.task } });
    console.log(`   Found ${tasks.length} tasks`);
    
    // Thống kê assignee trong tasks
    const assigneeMap = {};
    tasks.forEach(task => {
      if (task.assignee) {
        const assigneeId = task.assignee.toString();
        if (!assigneeMap[assigneeId]) {
          assigneeMap[assigneeId] = { totalTasks: 0, completedTasks: 0 };
        }
        assigneeMap[assigneeId].totalTasks++;
        if (task.status === 'completed' || task.status === 'closed') {
          assigneeMap[assigneeId].completedTasks++;
        }
      }
    });
    
    console.log('\n📊 Task assignments:');
    for (const [assigneeId, stats] of Object.entries(assigneeMap)) {
      const user = await User.findById(assigneeId);
      console.log(`   ${user ? user.displayName : 'Unknown'}: ${stats.totalTasks} tasks (${stats.completedTasks} completed)`);
    }
    
  } catch (error) {
    console.error('❌ Debug error:', error);
  }
};

const main = async () => {
  await connectDB();
  await debugProjectData();
  process.exit(0);
};

main();
