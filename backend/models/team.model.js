const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//* Schema định nghĩa cấu trúc dữ liệu cho nhóm (team)
const teamSchema = new Schema({
    //* Tên nhóm
    name: {
        type: String,
        required: true,
        unique: false
    },
    //* Danh sách thành viên trong nhóm
    members: [{
        //* Thông tin thành viên
        member: {
            type: Schema.Types.ObjectId,
            ref: 'User',
            required: true
        },
        //* Vai trò của thành viên trong nhóm (member: thành viên, admin: quản trị viên, owner: chủ sở hữu)
        role: {
            type: String,
            enum: ['member', 'admin','owner'],
            default: 'applicant'
        },
        //* Ngày tham gia nhóm
        joined_date: {
            type: Date,
            default: Date.now
        }
    }],
    //* Danh sách dự án thuộc nhóm
    project: [{
        required: false,
        type: Schema.Types.ObjectId,
        ref: 'Project'
    }]
},
{
    timestamps: true, //* Tự động thêm createdAt và updatedAt
}
);

//* Xuất model Team để sử dụng trong các file khác
const team = mongoose.model('Team', teamSchema, 'teams');
module.exports = team;