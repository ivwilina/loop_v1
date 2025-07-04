# Cập nhật Task Model: Chỉ 2 trạng thái (Pending & Completed)

## Vấn đề ban đầu:
- Có 4 trạng thái: pending (1), completed (2), review (3), in_progress (4)
- Gây nhầm lẫn cho người dùng cá nhân
- Logic phức tạp không cần thiết
- Số đếm trên lịch biểu có thể bị sai

## Thay đổi đã thực hiện:

### 1. **Cập nhật Task Model**
```dart
// Trước: late int status; //* 1: pending  2:completed  3:review  4:in_progress
// Sau:  late int status; //* 1: pending  2:completed
```

### 2. **PersonalDataService**
- Bỏ status 3 (review) và 4 (in_progress)
- Chỉ tạo data với 2 trạng thái: pending (40%) và completed (60%)
- Cập nhật thống kê chỉ có 2 trạng thái
- Sửa special tasks để phù hợp

### 3. **PersonalTab - Widget thống kê**
```dart
// Trước: final inProgress = tasks.where((t) => t.status == 3 || t.status == 4).length;
// Sau:   final pending = tasks.where((t) => t.status == 1).length;
```
- Bỏ card "Chưa bắt đầu" 
- Chỉ hiển thị 3 cards: "Tổng nhiệm vụ", "Hoàn thành", "Đang làm"

### 4. **PersonalDataDebugWidget**
```dart
// Trước: 4 stats: Tổng, Hoàn thành, Đang làm, Chờ
// Sau:   3 stats: Tổng, Hoàn thành, Đang làm
```

### 5. **Xóa files không cần thiết**
- Xóa `lib/scripts/create_personal_sample_data.dart` (đã được thay thế bởi PersonalDataService)

### 6. **TaskModel logic**
- Logic `changeStatusLocal()` đã đúng: toggle giữa 1 (pending) ↔ 2 (completed)
- Không cần thay đổi gì

## Kết quả:
- ✅ **Đơn giản hóa**: Chỉ 2 trạng thái dễ hiểu
- ✅ **Logic rõ ràng**: Pending ↔ Completed
- ✅ **UI nhất quán**: Tất cả widget đều hiển thị đúng 2 trạng thái
- ✅ **Số đếm chính xác**: Lịch biểu hiển thị đúng số task
- ✅ **Hiệu suất tốt**: Bỏ logic phức tạp không cần thiết

## Trạng thái task:
- **Status 1 (Pending)**: 🔵 Nhiệm vụ chưa hoàn thành
- **Status 2 (Completed)**: 🟢 Nhiệm vụ đã hoàn thành

## Files đã cập nhật:
1. `lib/models/task.dart` - Cập nhật comment
2. `lib/services/personal_data_service.dart` - Chỉ tạo 2 trạng thái
3. `lib/views/personal_tab.dart` - Widget thống kê 2 trạng thái
4. `lib/widgets/personal_data_debug_widget.dart` - Debug widget 2 trạng thái
5. Xóa `lib/scripts/create_personal_sample_data.dart`

## Lưu ý:
- Cần chạy `dart run build_runner build --delete-conflicting-outputs` để rebuild model
- Dữ liệu cũ với status 3, 4 sẽ không hiển thị đúng (cần tạo lại data mẫu)
- Widget team task có thể vẫn dùng nhiều trạng thái (không ảnh hưởng tới cá nhân)
