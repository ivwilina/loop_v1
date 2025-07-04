#!/usr/bin/env node

const mongoose = require('mongoose');
require('dotenv').config();

// Import models và controller
const Project = require('./models/project.model');
const taskController = require('./controllers/task.controller');

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

// Mock Express req/res objects
const createMockReq = (params) => ({
  params: params
});

const createMockRes = () => {
  const res = {};
  res.status = (code) => {
    res.statusCode = code;
    return res;
  };
  res.json = (data) => {
    res.data = data;
    return res;
  };
  return res;
};

const testMemberStats = async () => {
  try {
    // Lấy project đầu tiên
    const project = await Project.findOne().populate('assignedMembers', 'displayName email');
    
    if (!project) {
      console.log('❌ No project found');
      return;
    }
    
    console.log('🔍 Testing member stats for project:', project.name);
    console.log('📋 Project ID:', project._id);
    console.log('👥 Project members:', project.assignedMembers.length);
    
    // Hiển thị thông tin thành viên
    project.assignedMembers.forEach((member, index) => {
      console.log(`   ${index + 1}. ${member.displayName} (${member.email})`);
    });
    
    console.log('\n📊 Calling statistics controller...');
    
    // Gọi controller trực tiếp
    const req = createMockReq({ projectId: project._id.toString() });
    const res = createMockRes();
    
    // Call task statistics controller
    await taskController.get_task_statistics(req, res);
    
    console.log('✅ Controller Response Status:', res.statusCode);
    
    if (res.statusCode === 200 && res.data) {
      console.log('📊 Total tasks:', res.data.totalTasks);
      console.log('👥 Member stats count:', res.data.memberStats ? res.data.memberStats.length : 0);
      
      if (res.data.memberStats && res.data.memberStats.length > 0) {
        console.log('\n📈 Member Statistics:');
        res.data.memberStats.forEach((member, index) => {
          console.log(`   ${index + 1}. ${member.fullName || 'Unknown'}`);
          console.log(`      Email: ${member.email || 'N/A'}`);
          console.log(`      Total tasks: ${member.totalTasks || 0}`);
          console.log(`      Completed: ${member.completedTasks || 0}`);
          console.log(`      Completion rate: ${member.totalTasks > 0 ? Math.round((member.completedTasks / member.totalTasks) * 100) : 0}%`);
          console.log();
        });
      } else {
        console.log('⚠️  No member stats returned');
        console.log('📋 Full response:', JSON.stringify(res.data, null, 2));
      }
    } else {
      console.log('❌ Controller Error:', res.statusCode, res.data);
    }
    
  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

const main = async () => {
  await connectDB();
  await testMemberStats();
  process.exit(0);
};

main();
