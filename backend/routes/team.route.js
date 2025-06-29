const express = require('express');
const router = express.Router();
const tokenAuth = require('../middlewares/tokenAuth.middleware');
const controller = require('../controllers/team.controller');


//* Create a new team
router.post('/new', tokenAuth, controller.create_team);

//* Get all teams that a user is a member of
router.get('/get/:userIdServer', tokenAuth, controller.get_user_teams);

//* Get all teams that a user is owner of
router.get('/get/owned/:userIdServer', tokenAuth, controller.get_user_owned_teams);

//* Get all teams that a user is a member of not an owner
router.get('/get/joined/:userIdServer', tokenAuth, controller.get_user_member_teams);

//* Add a user to a team
router.post('/update/add', tokenAuth, controller.add_user_to_team);

//* Remove a user
router.post('/update/remove', tokenAuth, controller.remove_user);

//* Change member role
router.put('/update/role', tokenAuth, controller.change_member_role);

//* Get team by ID
router.get('/info/:teamId', tokenAuth, controller.get_team_by_id);

module.exports = router;