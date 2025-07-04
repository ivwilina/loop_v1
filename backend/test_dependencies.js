#!/usr/bin/env node

// Test script để kiểm tra dependencies và models
console.log('🔍 Testing dependencies...');

try {
  const mongoose = require('mongoose');
  console.log('✅ mongoose loaded');
  
  const bcrypt = require('bcryptjs');
  console.log('✅ bcryptjs loaded');
  
  require('dotenv').config();
  console.log('✅ dotenv loaded');
  
  console.log('📊 Environment variables:');
  console.log('  PORT:', process.env.PORT);
  console.log('  DATABASE_URL:', process.env.DATABASE_URL);
  console.log('  JWT_SECRET:', process.env.JWT_SECRET ? '[SET]' : '[NOT SET]');
  
} catch (error) {
  console.error('❌ Dependency error:', error.message);
  process.exit(1);
}

console.log('\n🔍 Testing models...');

try {
  const User = require('./models/user.model');
  console.log('✅ User model loaded');
  
  const Project = require('./models/project.model');
  console.log('✅ Project model loaded');
  
  const Task = require('./models/task.model');
  console.log('✅ Task model loaded');
  
  const Team = require('./models/team.model');
  console.log('✅ Team model loaded');
  
} catch (error) {
  console.error('❌ Model error:', error.message);
  console.error('Make sure all model files exist in ./models/ directory');
  process.exit(1);
}

console.log('\n✅ All dependencies and models loaded successfully!');
console.log('💡 You can now run: npm run setup-data');
