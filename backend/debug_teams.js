#!/usr/bin/env node

const mongoose = require('mongoose');
require('dotenv').config();

// Import models
const User = require('./models/user.model');
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

const debugTeams = async () => {
  try {
    console.log('🔍 Debugging team data...\n');
    
    // Lấy tất cả teams
    const teams = await Team.find();
    console.log(`Found ${teams.length} teams\n`);
    
    for (const team of teams) {
      console.log(`📁 Team: ${team.name}`);
      console.log(`   Members count: ${team.members.length}`);
      
      // Lấy thông tin chi tiết từng member
      for (let i = 0; i < team.members.length; i++) {
        const memberInfo = team.members[i];
        console.log(`   Member ${i + 1}:`);
        console.log(`     - ID: ${memberInfo.member}`);
        console.log(`     - Role: ${memberInfo.role}`);
        console.log(`     - Joined: ${memberInfo.joined_date}`);
        
        // Tìm user info
        const user = await User.findById(memberInfo.member);
        if (user) {
          console.log(`     - Name: ${user.displayName}`);
          console.log(`     - Email: ${user.email}`);
        } else {
          console.log(`     - User not found!`);
        }
        console.log();
      }
      console.log('---\n');
    }
    
  } catch (error) {
    console.error('❌ Debug error:', error);
  }
};

const main = async () => {
  await connectDB();
  await debugTeams();
  process.exit(0);
};

main();
