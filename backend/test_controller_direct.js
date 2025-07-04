#!/usr/bin/env node

const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const Project = require('./models/project.model');

// Import và gọi trực tiếp function từ controller
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

const testController = async () => {
  try {
    // Lấy project đầu tiên
    const project = await Project.findOne();
    
    if (!project) {
      console.log('❌ No project found');
      return;
    }
    
    console.log('🧪 Testing controller for project:', project.name);
    console.log('📋 Project ID:', project._id);
    
    // Mock req/res
    const req = {
      params: {
        projectId: project._id.toString()
      }
    };
    
    const res = {
      statusCode: null,
      data: null,
      status: function(code) {
        this.statusCode = code;
        return this;
      },
      json: function(data) {
        this.data = data;
        return this;
      }
    };
    
    // Gọi controller
    await taskController.get_task_statistics(req, res);
    
    console.log('📊 Response Status:', res.statusCode);
    
    if (res.statusCode === 200 && res.data) {
      console.log('✅ Success! Member stats count:', res.data.memberStats ? res.data.memberStats.length : 0);
      
      if (res.data.memberStats && res.data.memberStats.length > 0) {
        console.log('\n👥 Member Statistics:');
        res.data.memberStats.forEach((member, index) => {
          console.log(`   ${index + 1}. ${member.fullName}`);
          console.log(`      Email: ${member.email}`);
          console.log(`      Total: ${member.totalTasks}, Completed: ${member.completedTasks}`);
          console.log(`      Rate: ${member.totalTasks > 0 ? Math.round((member.completedTasks / member.totalTasks) * 100) : 0}%`);
          console.log();
        });
      } else {
        console.log('⚠️  No member stats in response');
      }
    } else {
      console.log('❌ Error:', res.statusCode, res.data);
    }
    
  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

const main = async () => {
  await connectDB();
  await testController();
  process.exit(0);
};

main();
