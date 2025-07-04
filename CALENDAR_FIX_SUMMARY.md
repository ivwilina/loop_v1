# Sửa lỗi số đếm nhiệm vụ trên lịch biểu

## Vấn đề được xác định:
1. **Số đếm hiển thị sai khi xóa nhiệm vụ**: Logic `customEventList` không được cập nhật khi xóa task
2. **Số đếm hoạt động sai khi chỉnh sửa tab**: `TaskModel.currentTask` không được refresh sau khi có thay đổi
3. **Logic phức tạp và không hiệu quả**: Vòng lặp nested trong `getCustomEventList()` gây khó hiểu

## Giải pháp đã thực hiện:

### 1. Tối ưu hóa logic `getCustomEventList()`
- Đơn giản hóa thuật toán từ O(n²) xuống O(n)
- Loại bỏ vòng lặp nested không cần thiết
- Sử dụng Map để quản lý events hiệu quả hơn

### 2. Thêm listener để tự động cập nhật
```dart
// Trong home_tab.dart
void _refreshCustomEventList() {
  if (_taskModel != null) {
    getCustomEventList(_taskModel!);
    if (mounted) {
      setState(() {});
    }
  }
}
```

### 3. Cập nhật TaskModel methods
Thêm `await findAll()` vào tất cả các method thay đổi dữ liệu:
- `changeStatusLocal()` - Khi thay đổi trạng thái task
- `deleteTask()` - Khi xóa task
- `updateTaskTitle()` - Khi cập nhật tiêu đề
- `updateTaskNote()` - Khi cập nhật ghi chú
- `updateTaskCategory()` - Khi thay đổi category
- `updateTaskDeadline()` - Khi thay đổi deadline
- `deleteMultipleTasks()` - Khi xóa nhiều tasks
- `deleteSubtask()` - Khi xóa subtask

### 4. Cải thiện quản lý lifecycle
- Thêm `dispose()` để cleanup listeners
- Quản lý listener đúng cách trong `build()` method
- Đảm bảo không memory leak

## Cách hoạt động mới:
1. Khi có thay đổi dữ liệu → `TaskModel` gọi `findAll()` → `notifyListeners()`
2. `home_tab.dart` nhận notification → `_refreshCustomEventList()` được gọi
3. `customEventList` được cập nhật → `setState()` → UI refresh
4. Số đếm trên lịch luôn đúng với dữ liệu thực tế

## Lợi ích:
- ✅ Số đếm luôn chính xác khi xóa/sửa/thêm task
- ✅ Hiệu suất tốt hơn với thuật toán O(n)
- ✅ Code dễ hiểu và maintain
- ✅ Không có memory leak
- ✅ Tự động đồng bộ khi chuyển tab

## Test cases cần kiểm tra:
1. Tạo task mới → Kiểm tra số đếm trên lịch
2. Xóa task → Kiểm tra số đếm giảm đúng
3. Sửa deadline của task → Kiểm tra số đếm cập nhật đúng ngày
4. Thay đổi trạng thái task → Kiểm tra số đếm không thay đổi (vì task vẫn tồn tại)
5. Chuyển tab và quay lại → Kiểm tra số đếm vẫn chính xác
