# 📱 Hướng Dẫn Dữ Liệu Cá Nhân - Isar Database

## 🎯 Tổng quan

Dữ liệu cá nhân trong Loop Application được lưu trữ **cục bộ** trên thiết bị bằng **Isar database**, không cần kết nối internet hay server.

## 🗂️ Cấu trúc dữ liệu

### Task Model (Isar)
```dart
@Collection()
class Task {
  Id id = Isar.autoIncrement;
  late int category;           // 1: Công việc, 2: Cá nhân, 3: Học tập, 4: Sức khỏe, 5: Giải trí
  late String title;
  late bool isTeamTask;        // false cho task cá nhân
  String? teamTaskId;
  late DateTime deadline;
  late int status;             // 1: pending, 2: completed, 3: review, 4: in_progress
  int? flag;                   // 0: none, 1: low, 2: normal, 3: high, 4: urgent
  String? description;
  String? note;
  List<String>? attachment;
}
```

## 🚀 Cách sử dụng

### 1. Tạo dữ liệu mẫu
1. Mở ứng dụng Flutter
2. Vào tab **"Cá Nhân"**
3. Tìm widget **"Dữ liệu mẫu cá nhân"**
4. Nhấn **"Tạo dữ liệu mẫu"**

### 2. Dữ liệu được tạo
- **75 task cá nhân** (2-3 task mỗi ngày trong 1 tháng)
- **Phân phối trạng thái**:
  - 50% Completed (hoàn thành)
  - 20% In Progress (đang làm)  
  - 20% Review (đang review)
  - 10% Pending (chờ xử lý)

### 3. Phân phối danh mục
- **Công việc**: Task liên quan đến work
- **Cá nhân**: Task cá nhân
- **Học tập**: Task học tập, research
- **Sức khỏe**: Task về health
- **Giải trí**: Task giải trí

### 4. Độ ưu tiên
- **Urgent**: Cần xử lý ngay
- **High**: Ưu tiên cao
- **Normal**: Bình thường
- **Low**: Ưu tiên thấp
- **None**: Không có ưu tiên

## 📊 Thống kê hiển thị

### Biểu đồ có sẵn:
1. **Pie Chart**: Tỷ lệ hoàn thành/chưa hoàn thành
2. **Performance Stats**: Hiệu suất tổng quan
3. **Timeline**: Xu hướng hoàn thành theo tuần
4. **Time Stats**: Thống kê theo thời gian
5. **Category Stats**: Thống kê theo danh mục
6. **Productivity Chart**: Biểu đồ năng suất
7. **Deadline Stats**: Thống kê theo thời hạn

## 🔧 Tính năng debug

### Widget Debug bao gồm:
- **Thống kê real-time**: Hiển thị số liệu hiện tại
- **Nút tạo dữ liệu**: Sinh 75 task mẫu
- **Nút xóa dữ liệu**: Xóa tất cả task cá nhân
- **Feedback**: Thông báo thành công/lỗi

### Cách debug:
1. Nếu không thấy dữ liệu → nhấn "Tạo dữ liệu mẫu"
2. Nếu hiển thị lỗi → nhấn "Xóa dữ liệu" → "Tạo dữ liệu mẫu"
3. Xem thống kê real-time để kiểm tra

## 🗄️ Lưu trữ dữ liệu

### Vị trí lưu trữ:
- **Android**: `/data/data/com.example.loop_application/databases/`
- **iOS**: Application Documents Directory
- **Desktop**: User Documents Directory

### Đặc điểm:
- ✅ **Offline**: Hoạt động không cần internet
- ✅ **Nhanh**: Truy vấn local database
- ✅ **Bảo mật**: Dữ liệu chỉ có trên thiết bị
- ✅ **Tự động**: Backup khi cài đặt lại app

## 🔄 Đồng bộ hóa

### Dữ liệu cá nhân (Isar):
- Lưu cục bộ trên thiết bị
- Không đồng bộ với server
- Phục vụ cho thống kê cá nhân

### Dữ liệu team (MongoDB):
- Lưu trên server
- Đồng bộ qua API
- Phục vụ cho collaboration

## 🚨 Troubleshooting

### Không thấy dữ liệu:
```
1. Vào tab "Cá Nhân"
2. Nhấn "Tạo dữ liệu mẫu"
3. Đợi thông báo thành công
4. Cuộn xuống xem các biểu đồ
```

### Lỗi khi tạo dữ liệu:
```
1. Restart ứng dụng
2. Nhấn "Xóa dữ liệu" trước
3. Nhấn "Tạo dữ liệu mẫu" lại
```

### Biểu đồ không hiển thị:
```
1. Kiểm tra có dữ liệu không (widget debug)
2. Scroll lại để refresh
3. Restart ứng dụng nếu cần
```

## 💻 Development

### Thêm dữ liệu mẫu:
```dart
// Sử dụng PersonalDataService
await PersonalDataService.createPersonalSampleData(isar);
```

### Kiểm tra thống kê:
```dart
// Lấy thống kê hiện tại
final stats = await PersonalDataService.getPersonalDataStats(isar);
```

### Xóa dữ liệu:
```dart
// Xóa tất cả dữ liệu cá nhân
await PersonalDataService.clearPersonalData(isar);
```

---

**Lưu ý**: Dữ liệu cá nhân hoàn toàn độc lập với server, phục vụ cho việc thống kê và phân tích cá nhân của người dùng.
