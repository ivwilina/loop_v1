const express = require('express');
const router = express.Router();
const tokenAuth = require('../middlewares/tokenAuth.middleware');
const { checkProjectPermission } = require('../middlewares/projectAuth.middleware');
const controller = require('../controllers/project.controller');

// Route to create a new project (owner only)
router.post('/create', tokenAuth, checkProjectPermission('owner'), controller.create_project);

// Route to update a project (admin/owner)
router.put('/update', tokenAuth, checkProjectPermission('admin'), controller.update_project);

// Route to delete a project (admin/owner)
router.delete('/delete', tokenAuth, checkProjectPermission('admin'), controller.delete_project);

// Route to get all projects of a team (any team member)
router.post('/team', tokenAuth, controller.get_project_of_team);

// Route to get project information by project ID (any team member)
router.get('/info', tokenAuth, controller.get_project_infomation);

// Route to assign members to project (admin/owner)
router.post('/assign-members', tokenAuth, checkProjectPermission('admin'), controller.assign_members_to_project);

// Route to remove members from project (admin/owner)
router.post('/remove-members', tokenAuth, checkProjectPermission('admin'), controller.remove_members_from_project);

// Route to get project with assigned members (any team member)
router.post('/with-members', tokenAuth, controller.get_project_with_members);

module.exports = router;