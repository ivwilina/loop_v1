# 📋 Script Sinh Dữ Liệu Mẫu Cá Nhân

## 🎯 Mục đích
Script này tạo dữ liệu mẫu cho user cá nhân với **2-3 nhiệm vụ mỗi ngày** trong vòng **1 tháng** (tháng 12/2024).

## 🚀 Cách sử dụng

### 1. Tạo dữ liệu mẫu cá nhân
```bash
npm run create-personal-data
```

### 2. Kiểm tra dữ liệu đã tạo
```bash
npm run check-personal-data
```

### 3. Thông tin đăng nhập
- **Email**: `test@example.com`
- **Password**: `123456`

## 📊 Dữ liệu được tạo

### Thống kê tổng quan:
- **Tổng số task**: ~73 task
- **Phân bố trạng thái**:
  - ✅ Completed: ~50%
  - 🔍 In Review: ~25%
  - 📋 Created: ~15%
  - ⏳ Pending: ~10%

### Phân bố độ ưu tiên:
- 🔴 Priority: ~30%
- 🟡 Medium: ~20%
- 🟢 Low: ~15%
- ⚪ None: ~20%
- 🔥 High: ~15%

## 🏗️ Cấu trúc dữ liệu

### Task được tạo:
- **2-3 task mỗi ngày** từ 1/12/2024 đến 30/12/2024
- **Tên task**: Từ template có sẵn + ngày tạo
- **Mô tả**: Chi tiết về nhiệm vụ
- **Deadline**: Ngẫu nhiên 1-10 ngày sau ngày tạo
- **Logs**: Ghi lại hành động tạo và hoàn thành

### Task đặc biệt:
1. **Dự án quan trọng - Giai đoạn 1** (Hoàn thành)
2. **Dự án quan trọng - Giai đoạn 2** (Đang review)
3. **Học tập và phát triển bản thân** (Mới tạo)

## 🔧 Template task

```javascript
const taskTemplates = [
  'Hoàn thành báo cáo hàng tuần',
  'Tham gia cuộc họp team',
  'Review code của đồng nghiệp',
  'Cập nhật tài liệu dự án',
  'Nghiên cứu công nghệ mới',
  'Sửa lỗi trong hệ thống',
  'Phát triển tính năng mới',
  'Kiểm tra và test ứng dụng',
  'Backup dữ liệu quan trọng',
  'Tối ưu hóa hiệu suất',
  // ... và 10 template khác
];
```

## 📈 Phân tích dữ liệu

### Xu hướng hoàn thành:
- Dữ liệu được phân bố đều qua 30 ngày
- Tỷ lệ hoàn thành khoảng 50%
- Mô phỏng công việc thực tế

### Lợi ích cho testing:
- ✅ Test tính năng thống kê cá nhân
- ✅ Test biểu đồ và chart
- ✅ Test filter và search
- ✅ Test performance với nhiều dữ liệu

## 🧹 Dọn dẹp dữ liệu

```bash
# Xóa toàn bộ dữ liệu
npm run clean-data

# Tạo lại dữ liệu mới
npm run create-personal-data
```

## 🔍 Debug

Nếu gặp lỗi, kiểm tra:
1. MongoDB đã chạy chưa
2. Database connection string
3. User model và Task model schema
4. Permissions

---

**Tạo bởi**: Loop Application Team  
**Cập nhật**: January 2025
