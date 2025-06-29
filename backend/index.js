const express = require('express');
const mongoose = require('mongoose');
const cors = require('cors');
const dotenv = require('dotenv');
dotenv.config();

const app = express();

app.use(cors());
app.use(express.json());

//! Import routes
const userRoutes = require('./routes/user.route');
const teamRoutes = require('./routes/team.route');
const taskRoutes = require('./routes/task.route');
const projectRoutes = require('./routes/project.route');

//! Use routes
app.use('/user', userRoutes);
app.use('/team', teamRoutes);
app.use('/task', taskRoutes);
app.use('/project', projectRoutes);

//! Connect to MongoDB
mongoose.connect(process.env.DATABASE_URL)
.then(() => {
    console.log('Connected to database');
    const port = process.env.PORT || 5001;
    app.listen(port, () => {
        console.log(`Server is running on http://localhost:${port}`);
    });
}).catch(err => {
    console.error('Connection failed!', err);
});