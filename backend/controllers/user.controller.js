const { stat } = require('fs');
const User = require('../models/user.model');
const bcrypt = require('bcryptjs');
const { console } = require('inspector');
const jwt = require('jsonwebtoken');
const path = require('path');
const { send } = require('process');

//* Register a new user
const register = async (req, res) => {
    try {
        if (await User.findOne({ username: req.body.username })) {
            return res.status(409).json({ message: 'Tên đăng nhập đã tồn tại' });
        } else {
            const newUser = await User.create({
                username: req.body.username,
                password: req.body.password,
                email: req.body.email,
                displayName: req.body.displayName,
            });
            res.status(201).json([{ message: 'Đăng kí thành công' }]);
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
};

//* Login a user
const login = async (req, res) => {
    try {
        const user = await User.findOne({ username: req.body.username });
        if (user != null) {
            if (await bcrypt.compare(req.body.password, user.password)) {
                const token = jwt.sign(
                    { id: user._id, username: user.username },
                    process.env.JWT_SECRET,
                    { expiresIn: '365d' }
                );
                res.status(200).json({
                    message: 'Đăng nhập thành công',
                    token: token,
                    username: user.username,
                    displayName: user.displayName,
                    email: user.email,
                    userId: user._id,
                });
            }
            else {
                return res.status(401).json({ message: 'Sai tên đăng nhập hoặc mật khẩu' });
            }
        } else {
            return res.status(404).json({ message: 'Sai tên đăng nhập hoặc mật khẩu' });
        }
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
}

module.exports = {
    register,
    login
}