# Setup Sample Data

## Mô tả
Script này tạo bộ dữ liệu mẫu hoàn chỉnh cho hệ thống quản lý dự án, bao gồm:

- **3 nhóm**: Frontend, Backend, DevOps
- **15 người dùng**: 5 người mỗi nhóm
- **10 dự án**: 3 dự án cho Frontend, 4 dự án cho Backend, 3 dự án cho DevOps
- **Nhiệm vụ**: 0-7 nhiệm vụ/ngày trong 60 ngày (khoảng 2 tháng) cho mỗi dự án
- **Trạng thái đầy đủ**: created, assigned, pending, in_review, completed, closed
- **Flags đầy đủ**: none, low, medium, high, priority
- **Logs chi tiết**: Theo dõi lịch sử thay đổi của từng nhiệm vụ

## Cài đặt và chạy

### 1. Chuẩn bị
```bash
# Đảm bảo MongoDB đang chạy
mongod

# Cài đặt dependencies (nếu chưa có)
npm install
```

### 2. Chạy setup
```bash
# Chạy script tạo dữ liệu mẫu
node setup_sample_data.js

# Hoặc thêm vào package.json scripts và chạy:
npm run setup-data
```

### 3. Kiểm tra dữ liệu
```bash
# Kết nối MongoDB và kiểm tra
mongo
use your-database-name

# Kiểm tra collections
db.teams.count()
db.users.count() 
db.projects.count()
db.tasks.count()

# Xem dữ liệu mẫu
db.teams.find().pretty()
db.users.find({}, {fullName: 1, email: 1}).pretty()
db.projects.find({}, {name: 1, description: 1}).pretty()
```

## Cấu trúc dữ liệu được tạo

### Teams (3 nhóm)
- **Team Frontend**: Đội phát triển giao diện người dùng
- **Team Backend**: Đội phát triển hệ thống backend  
- **Team DevOps**: Đội vận hành và triển khai hệ thống

### Users (15 người)
Mỗi nhóm có 5 thành viên với:
- Tên đầy đủ (tiếng Việt)
- Email duy nhất
- Mật khẩu mặc định: `password123`
- Được phân bổ vào từng team

### Projects (10 dự án)
- **Frontend** (3 dự án): E-commerce Website, Mobile App UI, Admin Dashboard
- **Backend** (4 dự án): API Gateway, Microservices, Database Optimization, Authentication Service
- **DevOps** (3 dự án): CI/CD Pipeline, Container Platform, Monitoring System

### Tasks (nhiều nhiệm vụ)
Mỗi dự án có:
- 0-7 nhiệm vụ/ngày trong 60 ngày
- Trạng thái ngẫu nhiên từ created đến completed
- Flags ưu tiên ngẫu nhiên
- Assignee từ thành viên trong nhóm
- Logs theo dõi lịch sử thay đổi
- Thời gian tạo và hoàn thành realistic

## Thông tin đăng nhập

### Tài khoản mẫu
- **Email**: Bất kỳ email nào từ danh sách users
- **Password**: `password123`

### Ví dụ tài khoản:
```
Frontend Team:
- nguyen.van.an@example.com
- tran.thi.bao@example.com
- le.minh.cuong@example.com
- pham.thu.dung@example.com
- hoang.van.em@example.com

Backend Team:
- vu.thi.phuong@example.com
- do.minh.quang@example.com
- bui.thu.huong@example.com
- ly.van.hung@example.com
- ngo.thi.lan@example.com

DevOps Team:
- trinh.van.kien@example.com
- dinh.thi.mai@example.com
- phan.minh.nam@example.com
- vo.thu.oanh@example.com
- dang.van.phuc@example.com
```

## Test API

Sau khi setup, bạn có thể test các API:

### 1. Login
```bash
POST /user/login
{
  "email": "nguyen.van.an@example.com",
  "password": "password123"
}
```

### 2. Get projects
```bash
GET /project/all
Headers: Authorization: Bearer <token>
```

### 3. Get task statistics
```bash
GET /task/statistics/{projectId}
Headers: Authorization: Bearer <token>
```

### 4. Debug member stats
```bash
GET /task/debug/members/{projectId}  
Headers: Authorization: Bearer <token>
```

## Xóa dữ liệu

Nếu muốn xóa và tạo lại dữ liệu:
```bash
# Script sẽ tự động xóa dữ liệu cũ trước khi tạo mới
node setup_sample_data.js
```

Hoặc xóa thủ công:
```bash
mongo
use your-database-name
db.dropDatabase()
```

## Tùy chỉnh

Bạn có thể tùy chỉnh dữ liệu trong file `setup_sample_data.js`:

- **Số lượng teams**: Thay đổi mảng `sampleData.teams`
- **Số lượng users**: Thay đổi mảng `sampleData.users`
- **Số lượng projects**: Thay đổi mảng `sampleData.projects`
- **Task templates**: Thay đổi mảng `sampleData.taskTemplates`
- **Thời gian**: Thay đổi biến `twoMonthsAgo` và vòng lặp 60 ngày
- **Số tasks/ngày**: Thay đổi `getRandomInt(0, 7)` thành giá trị khác

## Troubleshooting

### Lỗi kết nối MongoDB
```bash
# Kiểm tra MongoDB có đang chạy
ps aux | grep mongod

# Khởi động MongoDB
mongod

# Kiểm tra port
netstat -an | grep 27017
```

### Lỗi model không tìm thấy
Đảm bảo các file model tồn tại:
- `models/user.model.js`
- `models/team.model.js`
- `models/project.model.js`
- `models/task.model.js`

### Lỗi bcrypt
```bash
# Cài đặt lại bcrypt
npm uninstall bcrypt
npm install bcrypt
```

## Kết quả mong đợi

Sau khi chạy thành công, bạn sẽ thấy:
```
🎉 Sample data creation completed!
📊 Summary:
  - Teams: 3
  - Users: 15
  - Projects: 10
  - Tasks: [số lượng ngẫu nhiên]

📋 Team distribution:
  - Team Frontend: 5 users, 3 projects
  - Team Backend: 5 users, 4 projects
  - Team DevOps: 5 users, 3 projects
```

Giờ bạn có thể test widget thống kê với dữ liệu thực tế đầy đủ!
