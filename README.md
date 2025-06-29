# LoopSource Graduation Project

## Tổng quan

LoopSource là hệ thống quản lý dự án, nhiệm vụ, nhóm và người dùng, gồm hai phần:
- **Backend**: Node.js + Express + MongoDB (RESTful API)
- **Frontend**: Flutter (đa nền tảng: Android, iOS, Web, Desktop)

---

## 1. Backend (Node.js/Express)

### Cấu trúc thư mục
```
backend/
  |-- controllers/   // Xử lý logic cho user, team, task, project
  |-- middlewares/   // Xác thực token, quyền truy cập
  |-- models/        // Định nghĩa schema Mongoose
  |-- routes/        // Định nghĩa các endpoint API
  |-- index.js       // Khởi động server
  |-- package.json   // Thông tin & dependencies
  |-- .env           // Biến môi trường (PORT, DATABASE_URL, JWT_SECRET)
```

### Cài đặt & chạy server
1. Cài Node.js & MongoDB
2. Cài dependencies:
   ```bash
   cd backend
   npm install
   ```
3. Tạo file `.env` (xem mẫu):
   ```env
   PORT=3000
   DATABASE_URL="mongodb://localhost:27017/loop_application_db"
   JWT_SECRET="your_secret_key"
   ```
4. Khởi động server:
   ```bash
   npm run dev
   # hoặc
   npm run serve
   ```
5. API sẽ chạy tại: `http://localhost:3000`

### Các endpoint chính
- `/user`   : Đăng ký, đăng nhập, lấy thông tin người dùng
- `/team`   : Quản lý nhóm
- `/task`   : Quản lý nhiệm vụ
- `/project`: Quản lý dự án

> Xem chi tiết trong các file `routes/*.js` và `controllers/*.js`

---

## 2. Frontend (Flutter)

### Cấu trúc thư mục
```
loop_application/
  |-- lib/
      |-- views/         // Giao diện các màn hình
      |-- controllers/   // State management
      |-- models/        // Định nghĩa model dữ liệu
      |-- theme/         // Chủ đề giao diện
      |-- widgets/       // Widget tái sử dụng
      |-- main.dart      // Điểm khởi động app
  |-- pubspec.yaml       // Thông tin & dependencies
```

### Cài đặt & chạy ứng dụng
1. Cài [Flutter SDK](https://docs.flutter.dev/get-started/install)
2. Cài dependencies:
   ```bash
   cd loop_application
   flutter pub get
   ```
3. Chạy ứng dụng:
   - Android/iOS: Kết nối thiết bị/simulator, rồi chạy:
     ```bash
     flutter run
     ```
   - Web:
     ```bash
     flutter run -d chrome
     ```
   - Desktop (Windows/macOS/Linux):
     ```bash
     flutter run -d windows  # hoặc -d macos, -d linux
     ```

### Tính năng chính
- Đăng ký/đăng nhập, quản lý người dùng
- Quản lý dự án, nhóm, nhiệm vụ, nhiệm vụ con
- Giao diện hiện đại, responsive, hỗ trợ đa nền tảng
- Đồng bộ dữ liệu với backend qua REST API

---

## 3. Ghi chú
- Đảm bảo MongoDB đang chạy local hoặc cloud (Atlas)
- Có thể cấu hình lại API endpoint trong code Flutter nếu backend không chạy ở localhost
- Để phát triển, nên chạy cả backend và frontend song song

---

## 4. Liên hệ & đóng góp
- Tác giả: [Tên của bạn]
- Đóng góp: Pull request hoặc liên hệ qua email

---

## 5. License
MIT

## Backend
```
cd backend
npm install
```

### Frontend
```
cd loop_application
flutter pub get
```
