const Task = require('../models/task.model');
const Project = require('../models/project.model');

//* Tạo nhiệm vụ mới
const create_task = async (req, res) => {
    try {
        // Tìm dự án mà nhiệm vụ thuộc về
        const project = await Project.findOne({ _id: req.body.projectId });
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        // Tạo nhiệm vụ mới
        const newTask = await Task.create({
            title: req.body.title,
            deadline: req.body.deadline || null,
            status: 'created', // Trạng thái mặc định luôn là 'created'
            description: req.body.description || '',
            flag: req.body.flag || 'none', // Cờ ưu tiên mặc định là 'none'
            assignee: req.body.assignee || null,
            subtasks: req.body.subtasks || [],
            attachments: req.body.attachments || [],
            createTime: Date.now(),
            closeTime: null,
            logs: [{
                action: 'created',
                timestamp: Date.now(),
                performedBy: req.body.createdBy,
                details: 'Task created'
            }]
        });

        // Nếu có người được gán, thay đổi trạng thái thành 'assigned'
        if (req.body.assignee) {
            newTask.status = 'assigned';
            newTask.logs.push({
                action: 'assigned',
                timestamp: Date.now(),
                performedBy: req.body.createdBy,
                details: 'Task assigned during creation'
            });
        }

        // Thêm ID nhiệm vụ vào dự án
        project.task.push(newTask);
        await project.save();

        res.status(201).json({
            message: 'Task created successfully',
            taskId: newTask._id
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Cập nhật nhiệm vụ
const update_task = async (req, res) => {
    try {
        // Tìm nhiệm vụ theo ID
        const task = await Task.findOne({ _id: req.body.taskId });
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Cập nhật các trường của nhiệm vụ
        task.title = req.body.title || task.title;
        task.deadline = req.body.deadline || task.deadline;
        task.status = req.body.status || task.status;
        task.description = req.body.description || task.description;
        task.flag = req.body.flag || task.flag; // Cập nhật cờ ưu tiên
        task.assignee = req.body.assignee || task.assignee;
        task.subtasks = req.body.subtasks || task.subtasks;
        task.attachments = req.body.attachments || task.attachments;

        // Thêm bản ghi log cho việc cập nhật
        task.logs.push({
            action: task.status, // Sử dụng trạng thái hiện tại làm hành động
            timestamp: Date.now(),
            performedBy: req.body.updatedBy,
            details: 'Task updated'
        });

        await task.save();

        res.status(200).json({
            message: 'Task updated successfully',
            taskId: task._id
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Cập nhật cờ ưu tiên của nhiệm vụ
const update_task_flag = async (req, res) => {
    try {
        const { taskId, flag } = req.body;
        
        // Kiểm tra flag có hợp lệ không
        const validFlags = ['none', 'low', 'medium', 'high', 'priority'];
        if (!validFlags.includes(flag)) {
            return res.status(400).json({ message: 'Invalid flag value' });
        }

        // Tìm nhiệm vụ theo ID
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        const oldFlag = task.flag;
        
        // Cập nhật cờ ưu tiên
        task.flag = flag;

        // Thêm bản ghi log
        task.logs.push({
            action: task.status, // Giữ nguyên trạng thái hiện tại
            timestamp: Date.now(),
            performedBy: req.user.id,
            details: `Flag changed from ${oldFlag} to ${flag}`
        });

        await task.save();

        res.status(200).json({
            message: 'Task flag updated successfully',
            task: {
                _id: task._id,
                title: task.title,
                flag: task.flag
            }
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Xóa nhiệm vụ
const delete_task = async (req, res) => {
    try {
        // Tìm và xóa nhiệm vụ theo ID
        const task = await Task.findOneAndDelete({ _id: req.body.taskId });
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Xóa ID nhiệm vụ khỏi dự án
        const project = await Project.findOne({ task: req.body.taskId });
        if (project) {
            project.task = null; // Xóa tham chiếu nhiệm vụ
            await project.save();
        }

        res.status(200).json({ message: 'Task deleted successfully' });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Lấy tất cả nhiệm vụ của một dự án
const get_task_of_project = async (req, res) => {
    try {
        console.log('Received projectId:', req.body.projectId);
        
        // Tìm dự án theo ID và populate trường task với thông tin chi tiết bao gồm assignee
        const project = await Project.findOne({ _id: req.body.projectId }).populate({
            path: 'task',
            populate: {
                path: 'assignee',
                select: 'displayName username email'
            }
        });
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        console.log('Found project:', project.name);
        console.log('Tasks found:', project.task.length);
        
        // Debug: Ghi log trạng thái nhiệm vụ
        project.task.forEach((task, index) => {
            console.log(`Task ${index}: ${task.title} - Status: ${task.status}`);
        });

        // Trả về (các) nhiệm vụ liên quan đến dự án
        res.status(200).json(project.task);
    } catch (error) {
        console.error('Error in get_task_of_project:', error);
        res.status(500).json({ error: error.message });
    }
};

//* Lấy thông tin nhiệm vụ theo ID nhiệm vụ
const get_task_information = async (req, res) => {
    try {
        // Tìm nhiệm vụ theo ID
        const task = await Task.findOne({ _id: req.body.taskId });
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Trả về thông tin chi tiết nhiệm vụ
        res.status(200).json(task);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

//* Cập nhật nhiệm vụ con của một nhiệm vụ (thêm, sửa, xóa)
const update_subtask = async (req, res) => {
    try {
        // Tìm nhiệm vụ theo ID
        const task = await Task.findOne({ _id: req.body.taskId });
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Xử lý thêm nhiệm vụ con mới
        if (req.body.action === 'add') {
            const newSubtask = {
                title: req.body.title,
                status: req.body.status || 'pending'
            };
            task.subtasks.push(newSubtask);

            // Thêm bản ghi log
            task.logs.push({
                action: 'subtask_added',
                timestamp: Date.now(),
                performedBy: req.body.updatedBy,
                details: `Subtask "${req.body.title}" added`
            });
        }

        // Xử lý sửa đổi nhiệm vụ con hiện có
        if (req.body.action === 'modify') {
            const subtaskIndex = task.subtasks.findIndex(subtask => subtask._id.toString() === req.body.subtaskId);
            if (subtaskIndex === -1) {
                return res.status(404).json({ message: 'Subtask not found' });
            }

            task.subtasks[subtaskIndex].title = req.body.title || task.subtasks[subtaskIndex].title;
            task.subtasks[subtaskIndex].status = req.body.status || task.subtasks[subtaskIndex].status;

            // Thêm bản ghi log
            task.logs.push({
                action: 'subtask_modified',
                timestamp: Date.now(),
                performedBy: req.body.updatedBy,
                details: `Subtask "${req.body.title}" modified`
            });
        }

        // Xử lý xóa nhiệm vụ con hiện có
        if (req.body.action === 'delete') {
            const subtaskIndex = task.subtasks.findIndex(subtask => subtask._id.toString() === req.body.subtaskId);
            if (subtaskIndex === -1) {
                return res.status(404).json({ message: 'Subtask not found' });
            }

            const deletedSubtask = task.subtasks[subtaskIndex];
            task.subtasks.splice(subtaskIndex, 1);

            // Thêm bản ghi log
            task.logs.push({
                action: 'subtask_deleted',
                timestamp: Date.now(),
                performedBy: req.body.updatedBy,
                details: `Subtask "${deletedSubtask.title}" deleted`
            });
        }

        // Lưu nhiệm vụ đã cập nhật
        await task.save();

        res.status(200).json({ message: 'Subtask updated successfully', taskId: task._id });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

//* Gán nhiệm vụ cho thành viên
const assign_task_to_member = async (req, res) => {
    try {
        const { taskId, memberId } = req.body;
        
        // Tìm nhiệm vụ
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Cập nhật người được gán nhiệm vụ và thay đổi trạng thái
        task.assignee = memberId;
        task.status = 'assigned'; // Trạng thái thay đổi thành assigned khi nhiệm vụ được gán
        
        // Thêm bản ghi log
        task.logs.push({
            action: 'assigned',
            timestamp: Date.now(),
            performedBy: req.user.id,
            details: `Task assigned to member ${memberId}`
        });

        await task.save();

        // Populate thông tin chi tiết assignee cho phản hồi
        await task.populate('assignee', 'displayName username email');

        res.status(200).json({
            message: 'Task assigned successfully',
            task: task
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Hủy gán nhiệm vụ khỏi thành viên
const unassign_task = async (req, res) => {
    try {
        const { taskId } = req.body;
        
        // Tìm nhiệm vụ
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Xóa người được gán
        task.assignee = null;
        
        // Thêm bản ghi log
        task.logs.push({
            action: 'assigned',
            timestamp: Date.now(),
            performedBy: req.user.id,
            details: 'Task unassigned'
        });

        await task.save();

        res.status(200).json({
            message: 'Task unassigned successfully',
            task: task
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Nhận nhiệm vụ bởi thành viên (cho các nhiệm vụ chưa được gán)
const take_task = async (req, res) => {
    try {
        const { taskId } = req.body;
        
        // Tìm nhiệm vụ
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Kiểm tra nếu nhiệm vụ đã được gán
        if (task.assignee) {
            return res.status(400).json({ message: 'Task is already assigned to someone else' });
        }

        // Chỉ cho phép nhận các nhiệm vụ có trạng thái 'created'
        if (task.status !== 'created') {
            return res.status(400).json({ message: 'Only unassigned tasks can be taken' });
        }

        // Cập nhật người được gán nhiệm vụ và trạng thái
        task.assignee = req.user.id;
        task.status = 'assigned';
        
        // Thêm bản ghi log
        task.logs.push({
            action: 'assigned',
            timestamp: Date.now(),
            performedBy: req.user.id,
            details: 'Member took the task'
        });

        await task.save();

        // Populate thông tin chi tiết assignee cho phản hồi
        await task.populate('assignee', 'displayName username email');

        res.status(200).json({
            message: 'Task taken successfully',
            task: task
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Cập nhật trạng thái nhiệm vụ với quyền hạn dựa trên vai trò
const update_task_status = async (req, res) => {
    try {
        const { taskId, newStatus } = req.body;
        
        // Tìm nhiệm vụ theo ID
        const task = await Task.findById(taskId);
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        const oldStatus = task.status;
        const userId = req.user.id;
        const userRole = req.userRole; // Từ middleware
        
        // Ghi log debug
        console.log(`Update task status request:`);
        console.log(`- Task ID: ${taskId}`);
        console.log(`- Current status in DB: ${oldStatus}`);
        console.log(`- Requested new status: ${newStatus}`);
        console.log(`- User role: ${userRole}`);
        console.log(`- User ID: ${userId}`);

        // Định nghĩa các chuyển đổi trạng thái được phép dựa trên vai trò
        const allowedTransitions = {
            member: {
                'assigned': ['pending'],
                'pending': ['in_review']
            },
            admin: {
                'created': ['assigned', 'pending', 'in_review', 'completed', 'closed'],
                'assigned': ['pending', 'in_review', 'completed', 'closed'],
                'pending': ['assigned', 'in_review', 'completed', 'closed'],
                'in_review': ['pending', 'completed', 'closed'],
                'completed': ['in_review', 'closed'],
                'closed': ['completed']
            },
            owner: {
                'created': ['assigned', 'pending', 'in_review', 'completed', 'closed'],
                'assigned': ['pending', 'in_review', 'completed', 'closed'],
                'pending': ['assigned', 'in_review', 'completed', 'closed'],
                'in_review': ['pending', 'completed', 'closed'],
                'completed': ['in_review', 'closed'],
                'closed': ['completed']
            }
        };

        // Kiểm tra nếu chuyển đổi được phép
        const roleTransitions = allowedTransitions[userRole] || allowedTransitions.member;
        const allowedStatuses = roleTransitions[oldStatus] || [];

        if (!allowedStatuses.includes(newStatus)) {
            return res.status(403).json({ 
                message: `You don't have permission to change status from ${oldStatus} to ${newStatus}` 
            });
        }

        // Đối với thành viên, kiểm tra xem họ có phải là người được gán không
        if (userRole === 'member' && task.assignee && task.assignee.toString() !== userId) {
            return res.status(403).json({ 
                message: 'You can only update status of tasks assigned to you' 
            });
        }

        // Cập nhật trạng thái nhiệm vụ
        task.status = newStatus;

        // Đặt closeTime nếu completed hoặc closed
        if (newStatus === 'completed' || newStatus === 'closed') {
            task.closeTime = Date.now();
        } else {
            task.closeTime = null;
        }

        // Thêm bản ghi log
        task.logs.push({
            action: newStatus,
            timestamp: Date.now(),
            performedBy: userId,
            details: `Status changed from ${oldStatus} to ${newStatus}`
        });

        await task.save();

        res.status(200).json({
            message: 'Task status updated successfully',
            task: {
                _id: task._id,
                title: task.title,
                status: task.status,
                closeTime: task.closeTime
            }
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Chuyển đổi trạng thái nhiệm vụ giữa pending và completed (đã lỗi thời - sử dụng update_task_status thay thế)
const toggle_task_status = async (req, res) => {
    try {
        // Tìm nhiệm vụ theo ID
        const task = await Task.findOne({ _id: req.body.taskId });
        if (!task) {
            return res.status(404).json({ message: 'Task not found' });
        }

        // Chuyển đổi trạng thái giữa 'pending' và 'completed'
        const oldStatus = task.status;
        const newStatus = task.status === 'completed' ? 'pending' : 'completed';
        task.status = newStatus;

        // Đặt closeTime nếu completed, xóa nếu pending
        if (newStatus === 'completed') {
            task.closeTime = Date.now();
        } else {
            task.closeTime = null;
        }

        // Thêm bản ghi log sử dụng trạng thái mới làm hành động (giá trị enum hợp lệ)
        task.logs.push({
            action: newStatus, // Sử dụng trạng thái mới trực tiếp vì nó là giá trị enum hợp lệ
            timestamp: Date.now(),
            performedBy: req.user ? req.user.id : req.body.userId,
            details: `Status changed from ${oldStatus} to ${newStatus}`
        });

        await task.save();

        res.status(200).json({
            message: 'Task status updated successfully',
            task: {
                _id: task._id,
                title: task.title,
                status: task.status,
                closeTime: task.closeTime
            }
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Lấy thống kê nhiệm vụ của dự án
const get_task_statistics = async (req, res) => {
    try {
        const projectId = req.params.projectId;
        
        // Tìm dự án và lấy tất cả nhiệm vụ
        const project = await Project.findOne({ _id: projectId }).populate('task');
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        const tasks = project.task;
        
        // Thống kê theo trạng thái
        const statusStats = {
            created: 0,
            assigned: 0,
            pending: 0,
            in_review: 0,
            completed: 0,
            closed: 0
        };

        // Thống kê theo cờ ưu tiên
        const flagStats = {
            none: 0,
            low: 0,
            medium: 0,
            high: 0,
            priority: 0
        };

        // Thống kê theo thời gian hoàn thành (7 ngày gần nhất)
        const completionStats = [];
        const today = new Date();
        for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];
            completionStats.push({
                date: dateStr,
                completed: 0,
                created: 0
            });
        }

        // Thống kê theo thời gian thay đổi trạng thái từ logs
        const statusChangeStats = [];
        for (let i = 6; i >= 0; i--) {
            const date = new Date(today);
            date.setDate(date.getDate() - i);
            const dateStr = date.toISOString().split('T')[0];
            statusChangeStats.push({
                date: dateStr,
                changes: 0
            });
        }

        // Xử lý từng nhiệm vụ
        tasks.forEach(task => {
            // Đếm theo trạng thái
            statusStats[task.status]++;
            
            // Đếm theo cờ ưu tiên
            flagStats[task.flag]++;

            // Đếm theo thời gian tạo (7 ngày gần nhất)
            const createDate = new Date(task.createTime);
            const createDateStr = createDate.toISOString().split('T')[0];
            const createStat = completionStats.find(stat => stat.date === createDateStr);
            if (createStat) {
                createStat.created++;
            }

            // Đếm theo thời gian hoàn thành (7 ngày gần nhất)
            if (task.closeTime) {
                const closeDate = new Date(task.closeTime);
                const closeDateStr = closeDate.toISOString().split('T')[0];
                const closeStat = completionStats.find(stat => stat.date === closeDateStr);
                if (closeStat) {
                    closeStat.completed++;
                }
            }

            // Đếm thay đổi trạng thái từ logs
            task.logs.forEach(log => {
                const logDate = new Date(log.timestamp);
                const logDateStr = logDate.toISOString().split('T')[0];
                const changeStat = statusChangeStats.find(stat => stat.date === logDateStr);
                if (changeStat) {
                    changeStat.changes++;
                }
            });
        });

        // Tính thời gian hoàn thành trung bình
        const completedTasks = tasks.filter(task => task.closeTime && task.createTime);
        let averageCompletionTime = 0;
        if (completedTasks.length > 0) {
            const totalTime = completedTasks.reduce((sum, task) => {
                const duration = new Date(task.closeTime) - new Date(task.createTime);
                return sum + duration;
            }, 0);
            averageCompletionTime = Math.round(totalTime / completedTasks.length / (1000 * 60 * 60 * 24)); // Số ngày
        }

        // Thống kê theo thành viên
        const memberStats = {};
        
        // Lấy thông tin thành viên từ project
        const User = require('../models/user.model');
        const memberIds = project.assignedMembers || [];
        
        console.log('Project members:', memberIds);
        console.log('Total tasks:', tasks.length);
        
        // Khởi tạo stats cho từng thành viên trong project
        for (const memberId of memberIds) {
            try {
                const member = await User.findById(memberId);
                if (member) {
                    memberStats[memberId.toString()] = {
                        fullName: member.displayName || 'Unknown User',
                        email: member.email || 'unknown@example.com',
                        avatar: member.avatar || null,
                        totalTasks: 0,
                        completedTasks: 0
                    };
                } else {
                    console.log('Member not found:', memberId);
                }
            } catch (err) {
                console.log('Error finding member:', memberId, err);
                // Thêm thành viên với thông tin mặc định nếu có lỗi
                memberStats[memberId.toString()] = {
                    fullName: 'Unknown User',
                    email: 'unknown@example.com',
                    avatar: null,
                    totalTasks: 0,
                    completedTasks: 0
                };
            }
        }

        // Đếm nhiệm vụ theo thành viên
        for (const task of tasks) {
            console.log('Task:', task.title, 'Assignee:', task.assignee, 'Status:', task.status);
            if (task.assignee) {
                const assigneeId = task.assignee.toString();
                
                // Nếu assignee chưa có trong memberStats, thêm vào
                if (!memberStats[assigneeId]) {
                    console.log('Adding new assignee to stats:', assigneeId);
                    memberStats[assigneeId] = {
                        fullName: 'Unknown User',
                        email: 'unknown@example.com',
                        avatar: null,
                        totalTasks: 0,
                        completedTasks: 0
                    };
                    
                    // Thử lấy thông tin thành viên từ database đồng bộ
                    try {
                        const user = await User.findById(assigneeId);
                        if (user) {
                            memberStats[assigneeId].fullName = user.displayName || 'Unknown User';
                            memberStats[assigneeId].email = user.email || 'unknown@example.com';
                            memberStats[assigneeId].avatar = user.avatar || null;
                        }
                    } catch (err) {
                        console.log('Error fetching assignee info:', err);
                    }
                }
                
                memberStats[assigneeId].totalTasks++;
                if (task.status === 'completed' || task.status === 'closed') {
                    memberStats[assigneeId].completedTasks++;
                }
            }
        }

        // Chuyển đổi thành array - chỉ hiển thị thành viên có nhiệm vụ
        const memberStatsArray = Object.values(memberStats).filter(member => member.totalTasks > 0);
        
        console.log('Final member stats:', memberStatsArray);

        // Trả về kết quả thống kê
        res.status(200).json({
            totalTasks: tasks.length,
            statusStats,
            flagStats,
            completionStats,
            statusChangeStats,
            averageCompletionTime,
            completedTasksCount: completedTasks.length,
            memberStats: memberStatsArray
        });
    } catch (error) {
        res.status(400).json({ message: error.message });
    }
};

//* Xuất tất cả các hàm để sử dụng trong routes
module.exports = {
    create_task,
    update_task,
    update_task_flag,
    delete_task,
    get_task_of_project,
    get_task_information,
    update_subtask,
    assign_task_to_member,
    unassign_task,
    take_task,
    update_task_status,
    toggle_task_status,
    get_task_statistics
};