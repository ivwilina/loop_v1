const mongoose = require('mongoose')
const Schema = mongoose.Schema

//* Schema định nghĩa cấu trúc dữ liệu cho dự án (project)
const projectSchema = new Schema({
    //* Tên dự án
    name : {
        type: String,
        required: false
    },
    //* Danh sách nhiệm vụ thuộc dự án
    task : [{
        type: Schema.Types.ObjectId,
        ref: 'Task',
        required: false
    }],
    //* Danh sách thành viên được gán vào dự án
    assignedMembers: [{
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: false
    }],
    //* Người tạo dự án
    createdBy: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: false
    }
}, {
    timestamps: true //* Tự động thêm createdAt và updatedAt
})

//* Xuất model Project để sử dụng trong các file khác
const project = mongoose.model('Project',projectSchema,'projects')
module.exports = project