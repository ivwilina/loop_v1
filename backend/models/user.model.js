const mongoose = require('mongoose');
// const { use } = require('react');
const bcrypt = require('bcryptjs');
const Schema = mongoose.Schema;

//* Schema định nghĩa cấu trúc dữ liệu cho người dùng (user)
const userSchema = new Schema({
    //* Tên đăng nhập (duy nhất)
    username: {
        type: String,
        required: true,
        unique: true,
        trim: true
    },
    //* Mật khẩu (tối thiểu 6 ký tự)
    password: {
        type: String,
        required: true,
        minlength: 6
    },
    //* Địa chỉ email (duy nhất, định dạng email hợp lệ)
    email: {
        type: String,
        required: true,
        unique: true,
        trim: true,
        lowercase: true,
        match: /.+\@.+\..+/
    },
    //* Tên hiển thị
    displayName: {
        type: String,
        required: true,
        trim: true
    }
}, 
{
    timestamps: true, //* Tự động thêm createdAt và updatedAt
}
)

//* Middleware để mã hóa mật khẩu trước khi lưu vào database
userSchema.pre('save', function(next) {
    if (this.isModified('password')) {
        this.password = bcrypt.hashSync(this.password, 10);
    }
    next();
});

//* Xuất model User để sử dụng trong các file khác
const user = mongoose.model('User', userSchema, 'users');
module.exports = user;