#!/usr/bin/env node

const express = require('express');
const mongoose = require('mongoose');
const bodyParser = require('body-parser');

// Import models
const Project = require('./models/project.model');
const Task = require('./models/task.model');
const User = require('./models/user.model');

// Connect to MongoDB
mongoose.connect('mongodb://localhost:27017/your-database-name', {
  useNewUrlParser: true,
  useUnifiedTopology: true,
});

async function debugMemberStats(projectId) {
  try {
    console.log('=== Debug Member Stats ===');
    console.log('Project ID:', projectId);
    
    // 1. Tìm project
    const project = await Project.findOne({ _id: projectId }).populate('task');
    if (!project) {
      console.log('❌ Project not found');
      return;
    }
    
    console.log('✅ Project found:', project.name);
    console.log('📋 Project members:', project.member);
    console.log('📝 Total tasks:', project.task.length);
    
    // 2. Kiểm tra thành viên
    for (const memberId of project.member || []) {
      const member = await User.findById(memberId);
      if (member) {
        console.log(`👤 Member: ${member.fullName} (${member.email})`);
      } else {
        console.log(`❌ Member not found: ${memberId}`);
      }
    }
    
    // 3. Kiểm tra assignments
    const assignmentCounts = {};
    project.task.forEach(task => {
      if (task.assignee) {
        assignmentCounts[task.assignee] = (assignmentCounts[task.assignee] || 0) + 1;
        console.log(`📋 Task "${task.title}" assigned to: ${task.assignee} (${task.status})`);
      } else {
        console.log(`📋 Task "${task.title}" not assigned`);
      }
    });
    
    console.log('📊 Assignment counts:', assignmentCounts);
    
    // 4. Chạy logic thống kê
    const memberStats = {};
    
    // Khởi tạo stats cho từng thành viên
    for (const memberId of project.member || []) {
      const member = await User.findById(memberId);
      if (member) {
        memberStats[memberId.toString()] = {
          fullName: member.fullName || 'Unknown User',
          email: member.email || 'unknown@example.com',
          avatar: member.avatar || null,
          totalTasks: 0,
          completedTasks: 0
        };
      }
    }
    
    // Đếm nhiệm vụ
    project.task.forEach(task => {
      if (task.assignee) {
        const assigneeId = task.assignee.toString();
        
        if (!memberStats[assigneeId]) {
          memberStats[assigneeId] = {
            fullName: 'Unknown User',
            email: 'unknown@example.com',
            avatar: null,
            totalTasks: 0,
            completedTasks: 0
          };
        }
        
        memberStats[assigneeId].totalTasks++;
        if (task.status === 'completed' || task.status === 'closed') {
          memberStats[assigneeId].completedTasks++;
        }
      }
    });
    
    const memberStatsArray = Object.values(memberStats).filter(member => member.totalTasks > 0);
    
    console.log('📈 Final member stats:');
    memberStatsArray.forEach(member => {
      console.log(`  - ${member.fullName}: ${member.completedTasks}/${member.totalTasks} tasks`);
    });
    
    console.log('=== End Debug ===');
    
  } catch (error) {
    console.error('❌ Error:', error.message);
  }
}

// Sử dụng
const projectId = process.argv[2];
if (!projectId) {
  console.log('Usage: node debug_member_stats.js <project-id>');
  process.exit(1);
}

debugMemberStats(projectId).then(() => {
  process.exit(0);
});
