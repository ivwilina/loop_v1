const express = require('express');
const router = express.Router();

const controller = require('../controllers/user.controller');

//* Register a new user
router.post('/register', controller.register);

//* Login a user
router.post('/login', controller.login);

module.exports = router;