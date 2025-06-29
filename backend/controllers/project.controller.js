const Project = require('../models/project.model');
const Team = require('../models/team.model');
const User = require('../models/user.model');

const create_project = async (req, res) => {
    try {
        const team = await Team.findOne({ _id: req.body.teamId });
        if (!team) { 
            return res.status(404).json({ message: 'Team not found' }); 
        }

        const project = await Project.create({
            name: req.body.projectName,
            createdBy: req.user.id // Set creator
        });
        
        team.project.push(project._id);
        await team.save();

        res.status(201).json({
            message: 'Project created successfully',
            projectId: project._id
        });
    } catch (error) {
        console.error('Create project error:', error);
        res.status(500).json({ error: error.message });
    }
}

// Assign members to project (admin/owner only)
const assign_members_to_project = async (req, res) => {
    try {
        const { projectId, memberIds } = req.body;

        // Validate input
        if (!projectId || !Array.isArray(memberIds)) {
            return res.status(400).json({ 
                message: 'Project ID and member IDs array are required' 
            });
        }

        // Find project
        const project = await Project.findById(projectId);
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        // Validate that all members exist and are part of the team
        const team = req.team; // From middleware
        const teamMemberIds = team.members.map(member => member.member._id.toString());
        
        for (const memberId of memberIds) {
            if (!teamMemberIds.includes(memberId)) {
                return res.status(400).json({ 
                    message: `Member ${memberId} is not part of this team` 
                });
            }
        }

        // Add members to project (avoid duplicates)
        const currentAssignedIds = project.assignedMembers.map(id => id.toString());
        const newMemberIds = memberIds.filter(id => !currentAssignedIds.includes(id));
        
        project.assignedMembers.push(...newMemberIds);
        await project.save();

        // Populate assigned members for response
        await project.populate('assignedMembers', 'username displayName email');

        res.status(200).json({
            message: 'Members assigned to project successfully',
            project: {
                _id: project._id,
                name: project.name,
                assignedMembers: project.assignedMembers
            }
        });
    } catch (error) {
        console.error('Assign members to project error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Remove members from project (admin/owner only)
const remove_members_from_project = async (req, res) => {
    try {
        const { projectId, memberIds } = req.body;

        // Validate input
        if (!projectId || !Array.isArray(memberIds)) {
            return res.status(400).json({ 
                message: 'Project ID and member IDs array are required' 
            });
        }

        // Find project
        const project = await Project.findById(projectId);
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        // Remove members from project
        project.assignedMembers = project.assignedMembers.filter(
            memberId => !memberIds.includes(memberId.toString())
        );
        await project.save();

        // Populate assigned members for response
        await project.populate('assignedMembers', 'username displayName email');

        res.status(200).json({
            message: 'Members removed from project successfully',
            project: {
                _id: project._id,
                name: project.name,
                assignedMembers: project.assignedMembers
            }
        });
    } catch (error) {
        console.error('Remove members from project error:', error);
        res.status(500).json({ error: error.message });
    }
};

// Get project with assigned members
const get_project_with_members = async (req, res) => {
    try {
        const { projectId } = req.body;

        const project = await Project.findById(projectId)
            .populate('assignedMembers', 'username displayName email')
            .populate('createdBy', 'username displayName');

        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        res.status(200).json(project);
    } catch (error) {
        console.error('Get project with members error:', error);
        res.status(500).json({ error: error.message });
    }
};

const update_project = async (req,res) => {
    try {
        const project = await Project.findOne({_id: req.body.projectId});
        if(!project) {return res.status(404).json({message:'Project not found'})};
        project.name = req.body.newName;
        await project.save();
        res.status(200).json({
            message: 'Project updated successfully',
            projectId:  project._id
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const delete_project = async (req,res) => {
    try {
        const project = await Project.findOneAndDelete({ _id: req.body.projectId });
        if (!project) {
            return res.status(404).json({ message: 'Project not found' });
        }

        const team = await Team.findOne({ project: req.body.projectId });
        if (team) {
            team.project = team.project.filter(projId => projId.toString() !== req.body.projectId);
            await team.save();
        }

        res.status(200).json({ message: 'Project deleted successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const get_project_of_team = async (req,res) => {
    try {
        const team = await Team.findOne({ _id: req.body.teamId }).populate({
            path: 'project',
            select: '_id name assignedMembers createdBy',
            populate: [
                {
                    path: 'assignedMembers',
                    select: 'username displayName email'
                },
                {
                    path: 'createdBy',
                    select: 'username displayName'
                }
            ]
        });

        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }

        res.status(200).json(team.project);
    } catch (error) {
        console.error('Get projects of team error:', error);
        res.status(500).json({ error: error.message });
    }
};

const get_project_infomation = async (req,res) => {
    try {
        const team = await Team.findOne({ _id: req.body.teamId }).populate({
            path: 'project',
            select: '_id name assignedMembers createdBy',
            populate: [
                {
                    path: 'assignedMembers',
                    select: 'username displayName email'
                },
                {
                    path: 'createdBy',
                    select: 'username displayName'
                }
            ]
        });

        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }

        res.status(200).json(team.project);
    } catch (error) {
        console.error('Get project information error:', error);
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    create_project,
    update_project,
    get_project_infomation,
    get_project_of_team,
    delete_project,
    assign_members_to_project,
    remove_members_from_project,
    get_project_with_members
};