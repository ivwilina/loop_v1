#!/usr/bin/env node

const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
require('dotenv').config();

// Import models
const User = require('./models/user.model');

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

const debugLogin = async () => {
  try {
    console.log('🔍 Debugging login data...\n');
    
    // Lấy tất cả users
    const users = await User.find().limit(5);
    console.log(`Found ${users.length} users\n`);
    
    for (const user of users) {
      console.log(`👤 User: ${user.displayName}`);
      console.log(`   Username: ${user.username}`);
      console.log(`   Email: ${user.email}`);
      console.log(`   Password hash: ${user.password}`);
      
      // Test password comparison
      const testPassword = 'password123';
      const isMatch = await bcrypt.compare(testPassword, user.password);
      console.log(`   Password '${testPassword}' matches: ${isMatch}`);
      
      // Test với email làm username
      const userByEmail = await User.findOne({ username: user.email });
      console.log(`   Found by email as username: ${userByEmail ? 'YES' : 'NO'}`);
      
      console.log('---\n');
    }
    
    // Test đăng nhập thực tế
    console.log('🧪 Testing login scenarios...\n');
    
    const testCases = [
      { username: 'nguyen.van.an@example.com', password: 'password123' },
      { username: 'nguyen.van.an', password: 'password123' },
      { username: 'tran.thi.bao@example.com', password: 'password123' },
      { username: 'tran.thi.bao', password: 'password123' }
    ];
    
    for (const testCase of testCases) {
      console.log(`Testing: ${testCase.username} / ${testCase.password}`);
      
      const user = await User.findOne({ username: testCase.username });
      if (user) {
        const isMatch = await bcrypt.compare(testCase.password, user.password);
        console.log(`   ✅ User found: ${user.displayName}`);
        console.log(`   Password match: ${isMatch}`);
      } else {
        console.log(`   ❌ User not found`);
      }
      console.log();
    }
    
  } catch (error) {
    console.error('❌ Debug error:', error);
  }
};

const main = async () => {
  await connectDB();
  await debugLogin();
  process.exit(0);
};

main();
