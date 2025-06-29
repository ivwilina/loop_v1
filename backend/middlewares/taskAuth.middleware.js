const Team = require('../models/team.model');
const Project = require('../models/project.model');
const Task = require('../models/task.model');

//* Kiểm tra quyền hạn người dùng để quản lý nhiệm vụ (chỉ admin/owner)
const checkTaskPermission = (requiredRole = 'admin') => {
    return async (req, res, next) => {
        try {
            const userId = req.user.id;
            let projectId = req.body.projectId || req.params.projectId;

            // Nếu không có projectId, thử tìm từ taskId
            if (!projectId && (req.body.taskId || req.params.taskId)) {
                const taskId = req.body.taskId || req.params.taskId;
                
                // Tìm dự án chứa nhiệm vụ này
                const project = await Project.findOne({ 
                    task: taskId 
                });
                
                if (!project) {
                    return res.status(404).json({ message: 'Project not found for this task' });
                }
                
                projectId = project._id.toString();
            }

            if (!projectId) {
                return res.status(400).json({ message: 'Project ID is required' });
            }

            // Tìm dự án
            const project = await Project.findById(projectId);
            if (!project) {
                return res.status(404).json({ message: 'Project not found' });
            }

            // Tìm nhóm chứa dự án này
            const team = await Team.findOne({ 
                project: projectId 
            }).populate('members.member', '_id');
            
            if (!team) {
                return res.status(404).json({ message: 'Team not found for this project' });
            }

            // Tìm vai trò của người dùng trong nhóm
            const memberInfo = team.members.find(member => 
                member.member._id.toString() === userId
            );

            if (!memberInfo) {
                return res.status(403).json({ message: 'You are not a member of this team' });
            }

            const userRole = memberInfo.role;

            // Kiểm tra quyền hạn dựa trên vai trò yêu cầu
            if (requiredRole === 'owner') {
                if (userRole !== 'owner') {
                    return res.status(403).json({ 
                        message: 'Only team owners can perform this action' 
                    });
                }
            } else if (requiredRole === 'admin') {
                if (userRole !== 'owner' && userRole !== 'admin') {
                    return res.status(403).json({ 
                        message: 'Only team owners and admins can perform this action' 
                    });
                }
            }

            // Thêm thông tin vai trò người dùng, nhóm và dự án vào request để sử dụng tiếp
            req.userRole = userRole;
            req.team = team;
            req.project = project;
            
            next();
        } catch (error) {
            console.error('Task permission check error:', error);
            res.status(500).json({ error: error.message });
        }
    };
};

//* Lấy vai trò người dùng trong ngữ cảnh nhóm/dự án (cho tất cả thành viên)
const getUserRole = async (req, res, next) => {
    try {
        const userId = req.user.id;
        let projectId = req.body.projectId || req.params.projectId;

        // Nếu không có projectId, thử tìm từ taskId
        if (!projectId && (req.body.taskId || req.params.taskId)) {
            const taskId = req.body.taskId || req.params.taskId;
            
            // Tìm dự án chứa nhiệm vụ này
            const project = await Project.findOne({ 
                task: taskId 
            });
            
            if (!project) {
                return res.status(404).json({ message: 'Project not found for this task' });
            }
            
            projectId = project._id.toString();
        }

        if (!projectId) {
            return res.status(400).json({ message: 'Project ID is required' });
        }

        // Tìm dự án
        const project = await Project.findById(projectId);
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        // Tìm nhóm chứa dự án này
        const team = await Team.findOne({ 
            project: projectId 
        }).populate('members.member', '_id');
        
        if (!team) {
            return res.status(404).json({ message: 'Team not found for this project' });
        }

        // Tìm vai trò của người dùng trong nhóm
        const memberInfo = team.members.find(member => 
            member.member._id.toString() === userId
        );

        if (!memberInfo) {
            return res.status(403).json({ message: 'You are not a member of this team' });
        }

        const userRole = memberInfo.role;

        // Thêm thông tin vai trò người dùng, nhóm và dự án vào request để sử dụng tiếp
        req.userRole = userRole;
        req.team = team;
        req.project = project;
        
        next();
    } catch (error) {
        console.error('Get user role error:', error);
        res.status(500).json({ error: error.message });
    }
};

//* Xuất các middleware để sử dụng trong routes
module.exports = {
    checkTaskPermission,
    getUserRole
};
