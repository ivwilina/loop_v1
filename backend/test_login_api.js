#!/usr/bin/env node

const mongoose = require('mongoose');
require('dotenv').config();

// Import models và controllers
const User = require('./models/user.model');
const userController = require('./controllers/user.controller');

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
const createMockReq = (body) => ({
  body: body
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

const testLogin = async () => {
  try {
    console.log('🧪 Testing login API...\n');
    
    const testCases = [
      { username: 'nguyen.van.an', password: 'password123', expected: 'SUCCESS' },
      { username: 'tran.thi.bao', password: 'password123', expected: 'SUCCESS' },
      { username: 'nguyen.van.an', password: 'wrongpassword', expected: 'FAIL' },
      { username: 'nonexistent', password: 'password123', expected: 'FAIL' },
      { username: 'nguyen.van.an@example.com', password: 'password123', expected: 'FAIL' }, // Email as username
    ];
    
    for (const testCase of testCases) {
      console.log(`Testing: ${testCase.username} / ${testCase.password}`);
      
      const req = createMockReq({
        username: testCase.username,
        password: testCase.password
      });
      
      const res = createMockRes();
      
      // Call login controller
      await userController.login(req, res);
      
      console.log(`   Status: ${res.statusCode}`);
      console.log(`   Response: ${JSON.stringify(res.data, null, 2)}`);
      console.log(`   Expected: ${testCase.expected}, Got: ${res.statusCode === 200 ? 'SUCCESS' : 'FAIL'}`);
      console.log('---\n');
    }
    
    // Hiển thị thông tin đăng nhập hợp lệ
    console.log('✅ Valid login credentials:\n');
    const users = await User.find().limit(5);
    for (const user of users) {
      console.log(`👤 ${user.displayName}:`);
      console.log(`   Username: ${user.username}`);
      console.log(`   Password: password123`);
      console.log(`   Email: ${user.email}`);
      console.log();
    }
    
  } catch (error) {
    console.error('❌ Test error:', error);
  }
};

const main = async () => {
  await connectDB();
  await testLogin();
  process.exit(0);
};

main();
