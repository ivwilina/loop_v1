const Team = require('../models/team.model');

// Check if user has permission to manage projects (owner only for create, admin/owner for other operations)
const checkProjectPermission = (requiredRole = 'admin') => {
    return async (req, res, next) => {
        try {
            const userId = req.user.id;
            const teamId = req.body.teamId || req.params.teamId;

            if (!teamId) {
                return res.status(400).json({ message: 'Team ID is required' });
            }

            // Find team and populate members
            const team = await Team.findById(teamId).populate('members.member', '_id');
            
            if (!team) {
                return res.status(404).json({ message: 'Team not found' });
            }

            // Find user's role in the team
            const memberInfo = team.members.find(member => 
                member.member._id.toString() === userId
            );

            if (!memberInfo) {
                return res.status(403).json({ message: 'You are not a member of this team' });
            }

            const userRole = memberInfo.role;

            // Check permission based on required role
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

            // Add user role and team info to request for further use
            req.userRole = userRole;
            req.team = team;
            
            next();
        } catch (error) {
            console.error('Project permission check error:', error);
            res.status(500).json({ error: error.message });
        }
    };
};

module.exports = {
    checkProjectPermission
};
