# 🔐 Hướng dẫn đăng nhập với dữ liệu mẫu

## ✅ **Vấn đề đã được giải quyết**

Vấn đề "sai tên đăng nhập hoặc mật khẩu" đã được sửa chữa. Lỗi xảy ra do mật khẩu bị hash hai lần:
1. Một lần trong script setup 
2. Một lần nữa trong User model middleware

## 🔑 **Thông tin đăng nhập hợp lệ**

### Định dạng đăng nhập:
- **Username**: Sử dụng phần trước `@` của email
- **Password**: `password123` (cho tất cả users)

### Danh sách tài khoản mẫu:

#### 👑 **Team Owners (Chủ sở hữu)**
```
Username: nguyen.van.an
Password: password123
Email: nguyen.van.an@example.com
Role: Owner - Team Frontend

Username: vu.thi.phuong  
Password: password123
Email: vu.thi.phuong@example.com
Role: Owner - Team Backend

Username: trinh.van.kien
Password: password123
Email: trinh.van.kien@example.com
Role: Owner - Team DevOps
```

#### 🛡️ **Team Admins (Quản trị viên)**
```
Username: tran.thi.bao
Password: password123
Email: tran.thi.bao@example.com
Role: Admin - Team Frontend

Username: do.minh.quang
Password: password123
Email: do.minh.quang@example.com
Role: Admin - Team Backend

Username: dinh.thi.mai
Password: password123
Email: dinh.thi.mai@example.com
Role: Admin - Team DevOps
```

#### 👥 **Team Members (Thành viên)**
```
Username: le.minh.cuong
Password: password123
Email: le.minh.cuong@example.com
Role: Member - Team Frontend

Username: pham.thu.dung
Password: password123
Email: pham.thu.dung@example.com
Role: Member - Team Frontend

Username: hoang.van.em
Password: password123
Email: hoang.van.em@example.com
Role: Member - Team Frontend

Username: bui.thu.huong
Password: password123
Email: bui.thu.huong@example.com
Role: Member - Team Backend

Username: ly.van.hung
Password: password123
Email: ly.van.hung@example.com
Role: Member - Team Backend

Username: ngo.thi.lan
Password: password123
Email: ngo.thi.lan@example.com
Role: Member - Team Backend

Username: phan.minh.nam
Password: password123
Email: phan.minh.nam@example.com
Role: Member - Team DevOps

Username: vo.thu.oanh
Password: password123
Email: vo.thu.oanh@example.com
Role: Member - Team DevOps

Username: dang.van.phuc
Password: password123
Email: dang.van.phuc@example.com
Role: Member - Team DevOps
```

## 🧪 **Kiểm tra đăng nhập**

### Chạy test đăng nhập:
```bash
npm run test-login
```

### Debug thông tin đăng nhập:
```bash
npm run debug-login
```

## ⚠️ **Lưu ý quan trọng**

1. **Không sử dụng email làm username**: API đăng nhập chỉ chấp nhận username, không phải email
2. **Username format**: Luôn là phần trước `@` của email (ví dụ: `nguyen.van.an`)
3. **Password cố định**: Tất cả accounts đều dùng `password123`

## 🔧 **Troubleshooting**

### Nếu vẫn gặp lỗi đăng nhập:
1. Kiểm tra đúng username (không phải email)
2. Chạy `npm run debug-login` để xem dữ liệu thực tế
3. Chạy `npm run test-login` để test API
4. Chạy `npm run setup-data` để tạo lại dữ liệu nếu cần

### API Response thành công:
```json
{
  "message": "Đăng nhập thành công",
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "username": "nguyen.van.an",
  "displayName": "Nguyễn Văn An",
  "email": "nguyen.van.an@example.com",
  "userId": "68680d1cbccec35b4504243e"
}
```

### API Response lỗi:
```json
{
  "message": "Sai tên đăng nhập hoặc mật khẩu"
}
```
