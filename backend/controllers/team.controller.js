const Team = require('../models/team.model');
const User = require('../models/user.model'); 

//* Create a new team

const create_team = async (req, res) => {
    try {
        // Find the user by username
        const user = await User.findOne({ username: req.body.username });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Create the team with the user's ID as the owner
        await Team.create({
            name: req.body.name,
            members: [{
                member: user._id, // Use the user ID as the owner
                role: 'owner', // Set the role of the owner
                joined_date: Date.now() // Automatically set the joined date
            }]
        });

        res.status(201).json({
            message: 'Team created successfully',
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//* Get all teams that a user is a member of
const get_user_teams = async (req, res) => {
    try {
        const teams = await Team.find({ 'members.member': req.params.userIdServer });
        res.status(200).json(teams);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//* Get all teams that a user is owner of
const get_user_owned_teams = async (req, res) => {
    try {
        const teams = await Team.find({ 'members': { $elemMatch: { member: req.params.userIdServer, role: 'owner' } } });
        res.status(200).json(teams);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//* Get all teams that a user is a member of not an owner
const get_user_member_teams = async (req, res) => {
    try {
        const teams = await Team.find({
            'members': { $elemMatch: { member: req.params.userIdServer, role: { $ne: 'owner' } } }
        });
        res.status(200).json(teams);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//* Add a user to a team
// Import the User model

const add_user_to_team = async (req, res) => {
    try {
        // Find the user by username
        const user = await User.findOne({ username: req.body.username });
        if (!user) {
            return res.status(404).json({ message: 'User not found' });
        }

        // Find the team by ID
        const team = await Team.findById(req.body.teamId);
        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }

        // Check if the requester has permission to add members
        const requesterIndex = team.members.findIndex(member => member.member.toString() === req.user.id);
        if (requesterIndex === -1) {
            return res.status(403).json({ message: 'You are not a member of this team' });
        }
        
        const requesterRole = team.members[requesterIndex].role;
        if (requesterRole === 'member') {
            return res.status(403).json({ message: 'Only admins and owners can add new members' });
        }

        // Check if the user is already a member of the team
        const isAlreadyMember = team.members.some(member => member.member.toString() === user._id.toString());
        if (isAlreadyMember) {
            return res.status(400).json({ message: 'User is already a member of this team' });
        }

        // Add the user to the team
        team.members.push({
            member: user._id,
            role: 'member', // Default role for new members
            joined_date: Date.now() // Automatically set the joined date
        });
        await team.save();

        res.status(200).json({ message: 'User added to team successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

const remove_user = async (req, res) => {
    try {
        // Debug log
        console.log('JWT decoded user:', req.user);
        console.log('Request body:', req.body);
        
        // Find the team by ID
        const team = await Team.findById(req.body.teamId);
        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }

        console.log('Team members:', team.members.map(m => ({ id: m.member.toString(), role: m.role })));
        console.log('Looking for requester with ID:', req.user.id);

        // Find the requester (person making the request) in the team
        const requesterIndex = team.members.findIndex(member => member.member.toString() === req.user.id);
        if (requesterIndex === -1) {
            return res.status(403).json({ message: 'You are not a member of this team' });
        }
        
        const requesterRole = team.members[requesterIndex].role;

        // Check if the user exists in the team
        const memberIndex = team.members.findIndex(member => member.member.toString() === req.body.userId);
        if (memberIndex === -1) {
            return res.status(404).json({ message: 'User is not a member of this team' });
        }

        const targetRole = team.members[memberIndex].role;

        // Permission checks based on requester's role
        if (requesterRole === 'member') {
            // Members can only remove themselves
            if (req.body.userId !== req.user.id) {
                return res.status(403).json({ message: 'Members can only remove themselves from the team' });
            }
        }

        if (requesterRole === 'admin') {
            // Admin cannot remove owners
            if (targetRole === 'owner') {
                return res.status(403).json({ message: 'Admins cannot remove owners from the team' });
            }
            
            // Admin cannot remove other admins (except themselves)
            if (targetRole === 'admin' && req.body.userId !== req.user.id) {
                return res.status(403).json({ message: 'Admins cannot remove other admins from the team' });
            }
        }

        // Prevent removing the last owner
        if (targetRole === 'owner') {
            const ownerCount = team.members.filter(member => member.role === 'owner').length;
            if (ownerCount <= 1) {
                return res.status(400).json({ message: 'Cannot remove the last owner from the team' });
            }
        }

        // Remove the user from the members array
        team.members.splice(memberIndex, 1);
        await team.save();

        res.status(200).json({ message: 'Member removed successfully' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};


//* Get team information by team ID
const get_team_by_id = async (req, res) => {
    try {
        const team = await Team.findById(req.params.teamId).populate('members.member', 'username displayName email');
        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }
        res.status(200).json(team);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

//* Change member role in team
const change_member_role = async (req, res) => {
    try {
        const { teamId, userId, newRole } = req.body;
        
        // Debug log
        console.log('JWT decoded user:', req.user);
        console.log('Request body:', req.body);
        
        // Validate role
        const validRoles = ['member', 'admin', 'owner'];
        if (!validRoles.includes(newRole)) {
            return res.status(400).json({ message: 'Invalid role. Must be member, admin, or owner' });
        }

        // Find the team by ID
        const team = await Team.findById(teamId);
        if (!team) {
            return res.status(404).json({ message: 'Team not found' });
        }

        console.log('Team members:', team.members.map(m => ({ id: m.member.toString(), role: m.role })));
        console.log('Looking for requester with ID:', req.user.id);

        // Find the requester (person making the request) in the team
        const requesterIndex = team.members.findIndex(member => member.member.toString() === req.user.id);
        if (requesterIndex === -1) {
            return res.status(403).json({ message: 'You are not a member of this team' });
        }
        
        const requesterRole = team.members[requesterIndex].role;

        // Find the target member in the team
        const memberIndex = team.members.findIndex(member => member.member.toString() === userId);
        if (memberIndex === -1) {
            return res.status(404).json({ message: 'User is not a member of this team' });
        }

        const currentRole = team.members[memberIndex].role;

        // Permission checks based on requester's role
        if (requesterRole === 'member') {
            return res.status(403).json({ message: 'Members cannot change roles of other members' });
        }

        if (requesterRole === 'admin') {
            // Admin cannot demote or promote owners
            if (currentRole === 'owner') {
                return res.status(403).json({ message: 'Admins cannot change the role of owners' });
            }
            
            // Admin cannot promote someone to owner
            if (newRole === 'owner') {
                return res.status(403).json({ message: 'Admins cannot promote members to owner' });
            }
            
            // Admin cannot change role of another admin
            if (currentRole === 'admin' && userId !== req.user.id) {
                return res.status(403).json({ message: 'Admins cannot change the role of other admins' });
            }
        }

        // Check if trying to change the last owner
        if (currentRole === 'owner' && newRole !== 'owner') {
            const ownerCount = team.members.filter(member => member.role === 'owner').length;
            if (ownerCount <= 1) {
                return res.status(400).json({ message: 'Cannot change role of the last owner. Team must have at least one owner.' });
            }
        }

        // Prevent self-demotion if you're the last owner
        if (req.user.id === userId && currentRole === 'owner' && newRole !== 'owner') {
            const ownerCount = team.members.filter(member => member.role === 'owner').length;
            if (ownerCount <= 1) {
                return res.status(400).json({ message: 'You cannot demote yourself as you are the last owner of this team.' });
            }
        }

        // Update the member's role
        team.members[memberIndex].role = newRole;
        await team.save();

        res.status(200).json({ 
            message: 'Member role updated successfully',
            member: {
                userId: userId,
                newRole: newRole,
                previousRole: currentRole
            }
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

module.exports = {
    create_team,
    get_user_teams,
    add_user_to_team,
    get_user_owned_teams,
    get_user_member_teams,
    get_team_by_id,
    remove_user,
    change_member_role
}