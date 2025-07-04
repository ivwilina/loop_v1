# 🚀 Hướng Dẫn Cài Đặt Loop Application

## ⚡ Cài Đặt Nhanh

### 1. Cài đặt Backend (Node.js)
```bash
cd backend
npm install
npm run create-rich-data  # Sinh dữ liệu mẫu cho server (team, project)
npm run serve             # Chạy server
```

### 2. Cài đặt Frontend (Flutter)
```bash
cd loop_application
flutter pub get
flutter run
```

**Tạo dữ liệu mẫu cá nhân:**
- Mở ứng dụng Flutter và vào tab "Cá Nhân"
- Nhấn nút "Tạo dữ liệu mẫu" để tạo 75 task cá nhân
- Dữ liệu được lưu cục bộ bằng Isar database

## 🔧 Yêu Cầu Hệ Thống

- **Node.js** v14+ (cho backend)
- **MongoDB** (local hoặc MongoDB Atlas) (cho backend)
- **Flutter** SDK v3.0+ (cho frontend)
- **Android Studio** hoặc **VS Code**

**Lưu ý**: Dữ liệu cá nhân được lưu cục bộ bằng Isar database, không cần kết nối server.

## 📱 Đăng Nhập Test

- **Email**: `test@example.com`
- **Password**: `123456`

## 🎯 Tính Năng Chính

- ✅ **Quản lý task cá nhân** (lưu cục bộ bằng Isar)
- 📊 **Thống kê hiệu suất cá nhân** (biểu đồ, báo cáo)
- 👥 **Quản lý team** (qua server)
- 📈 **Báo cáo chi tiết** (cá nhân và team)
- 🔄 **Đồng bộ offline/online**

## 🔨 Commands Hữu Ích

### Backend:
```bash
npm run dev                    # Chạy với nodemon
npm run create-rich-data       # Sinh dữ liệu mẫu cho server (team, project)
npm run check-data             # Kiểm tra dữ liệu server
npm run clean-data             # Xóa toàn bộ dữ liệu server
```

### Flutter:
```bash
flutter clean           # Xóa cache
flutter pub get         # Cài đặt dependencies
flutter doctor          # Kiểm tra cài đặt
```

### Dữ liệu mẫu cá nhân:
- Dữ liệu cá nhân được tạo trong ứng dụng Flutter
- Vào tab "Cá Nhân" → nhấn "Tạo dữ liệu mẫu"
- Tự động tạo 75 task cá nhân (2-3 task/ngày trong 1 tháng)

## 🚨 Troubleshooting

### Lỗi kết nối MongoDB:
```bash
# Kiểm tra MongoDB đã chạy
mongod --version
# Hoặc sử dụng MongoDB Atlas (cloud)
```

### Lỗi Flutter:
```bash
flutter doctor --android-licenses  # Chấp nhận license
flutter clean && flutter pub get   # Reset dependencies
```

### Lỗi dữ liệu cá nhân:
- Dữ liệu cá nhân lưu cục bộ bằng Isar database
- Nếu không có dữ liệu: vào tab "Cá Nhân" → "Tạo dữ liệu mẫu"
- Nếu có lỗi hiển thị: thử "Xóa dữ liệu" → "Tạo dữ liệu mẫu"

## 📦 Cấu Trúc Dự Án

```
loopSource/
├── backend/                 # Node.js API (dữ liệu team, project)
│   ├── models/             # Database models
│   ├── controllers/        # API controllers
│   ├── routes/             # API routes
│   └── create_rich_sample_data.js
├── loop_application/        # Flutter app (dữ liệu cá nhân local)
│   ├── lib/
│   │   ├── views/          # UI screens
│   │   ├── models/         # Data models (Isar)
│   │   ├── controllers/    # App controllers
│   │   ├── services/       # Personal data service
│   │   └── widgets/        # Custom widgets
│   └── pubspec.yaml
└── README.md
```

## 🔗 Port Mặc Định

- **Backend**: http://localhost:3000
- **MongoDB**: mongodb://localhost:27017
- **Flutter**: Tự động phát hiện device

## 📞 Hỗ Trợ

- 📧 Email: support@loopapp.com
- 📱 Hotline: 0123-456-789
- 🌐 Website: https://loopapp.com

---

**Chúc bạn sử dụng Loop Application hiệu quả! 🎉**
