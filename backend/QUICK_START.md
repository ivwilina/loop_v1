# Quick Start Guide - Sample Data Setup

## � Bước 0: Test dependencies
```bash
cd backend
npm run test-deps
```

## 🚀 Bước 1: Chạy Setup
```bash
npm run setup-data
```

## 📊 Bước 2: Kiểm tra dữ liệu
```bash
npm run check-data
```

## 🏃‍♂️ Bước 3: Khởi động server
```bash
npm run dev
```

## 📱 Bước 4: Test với Flutter app
1. Mở Flutter app
2. Đăng nhập với tài khoản mẫu:
   - Email: `nguyen.van.an@example.com`
   - Password: `password123`
3. Vào trang thống kê dự án
4. Kiểm tra widget thống kê thành viên

## 🔧 Bước 5: Debug (nếu cần)
```bash
# Test API trực tiếp
curl -X POST http://localhost:3000/user/login \
  -H "Content-Type: application/json" \
  -d '{"email":"nguyen.van.an@example.com","password":"password123"}'

# Lấy project statistics (thay {token} và {projectId})
curl -X GET http://localhost:3000/task/statistics/{projectId} \
  -H "Authorization: Bearer {token}"

# Debug member stats
curl -X GET http://localhost:3000/task/debug/members/{projectId} \
  -H "Authorization: Bearer {token}"
```

## 🧹 Reset dữ liệu (nếu cần)
```bash
npm run clean-data
npm run setup-data
```

## 📈 Kết quả mong đợi
- ✅ 3 teams (Frontend, Backend, DevOps)
- ✅ 15 users (5 mỗi team)  
- ✅ 10 projects (3-4 mỗi team)
- ✅ Hàng nghìn tasks với đầy đủ trạng thái
- ✅ Member statistics hoạt động trong Flutter app

## ❗ Troubleshooting
- **MongoDB không chạy**: `mongod` hoặc `brew services start mongodb-community` (macOS)
- **Port conflict**: Thay đổi port trong code hoặc kill process đang dùng port
- **Permission error**: Chạy với `sudo` (Linux/macOS) hoặc run as administrator (Windows)
- **Model not found**: Đảm bảo tất cả file model tồn tại trong thư mục `models/`

That's it! 🎉
