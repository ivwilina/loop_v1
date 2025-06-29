const mongoose = require('mongoose');
const Schema = mongoose.Schema;

//* Schema định nghĩa cấu trúc dữ liệu cho nhiệm vụ (task)
//TODO: Attachments?
const taskSchema = new Schema({
    //* Tiêu đề nhiệm vụ
    title: {
        type: String,
        required: true,
        unique: false
    },
    //* Thời hạn hoàn thành nhiệm vụ
    deadline: {
        type: Date,
        required: false,
        unique: false
    },
    //* Trạng thái hiện tại của nhiệm vụ
    status: {
        type: String,
        enum: ['created', 'assigned', 'pending', 'in_review', 'completed', 'closed'],
        default: 'created',
        required: true
    },
    //* Mô tả chi tiết nhiệm vụ
    description: {
        type: String,
        required: false,
        unique: false
    },
    //* Cờ ưu tiên của nhiệm vụ (none: không có, low: thấp, medium: trung bình, high: cao, priority: ưu tiên)
    flag: {
        type: String,
        enum: ['none', 'low', 'medium', 'high', 'priority'],
        default: 'none',
        required: true
    },
    //* Người được gán nhiệm vụ
    assignee: {
        type: Schema.Types.ObjectId,
        ref: 'User',
        required: false,
        default: null
    },
    //* Danh sách các nhiệm vụ con
    subtasks: [{
        //* Tiêu đề nhiệm vụ con
        title: {
            type: String,
            required: true
        },
        //* Trạng thái nhiệm vụ con
        status: {
            type: String,
            enum: ['pending', 'completed'],
            default: 'pending'
        }
    }],
    //* Danh sách file đính kèm
    attachments: [{
        type: String,
        default: [],
    }],
    //* Thời gian tạo nhiệm vụ
    createTime: {
        type: Date,
        required: true
    },
    //* Thời gian đóng/hoàn thành nhiệm vụ
    closeTime: {
        type: Date,
        required: false,
        default: null
    },
    //* Lịch sử thay đổi trạng thái và hoạt động của nhiệm vụ
    logs: [{
        //* Hành động được thực hiện
        action: {
            type: String,
            enum: ['created', 'assigned', 'pending', 'in_review', 'completed', 'closed'], // Define possible actions
            required: true
        },
        //* Thời gian thực hiện hành động
        timestamp: {
            type: Date,
            default: Date.now, // Automatically set the current date and time
            required: true
        },
        //* Người thực hiện hành động
        performedBy: {
            type: Schema.Types.ObjectId,
            ref: 'User', // Reference to the User model
            required: true
        },
        //* Thông tin chi tiết về hành động
        details: {
            type: String,
            required: false // Optional field for additional information
        }
    }]
}, {
    timestamps: true, //* Tự động thêm createdAt và updatedAt
});

//* Xuất model Task để sử dụng trong các file khác
const Task = mongoose.model('Task', taskSchema, 'tasks');
module.exports = Task;