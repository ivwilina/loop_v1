# Debug: Số đếm lỗi khi xóa task

## Vấn đề:
Khi xóa task, số đếm trên lịch biểu (calendar) không được cập nhật ngay lập tức.

## Nguyên nhân có thể:
1. **Multiple notifyListeners()**: Gọi `notifyListeners()` nhiều lần trong cùng một operation
2. **Async timing**: Listener được trigger trước khi data thực sự được cập nhật
3. **Data không đồng bộ**: `currentTask` vs `taskOnSpecificDay` vs `customEventList`

## Giải pháp đã thử:

### 1. **Tối ưu hóa deleteTask()**
```dart
Future<void> deleteTask(Task task) async {
  // Xóa task khỏi database
  await isar.writeTxn(() => isar.tasks.delete(task.id));
  
  // Refresh data một cách hiệu quả
  await findAll(); // Cập nhật currentTask và notify listeners
  await findByCategory(oldCategory, notify: false); // Không duplicate notify
  await findByDate(taskDeadline, notify: false); // Không duplicate notify
}
```

### 2. **Thêm debug logs**
- Log khi xóa task
- Log số lượng tasks sau khi xóa
- Log khi `customEventList` được cập nhật

### 3. **Cải thiện refresh logic**
```dart
void _refreshCustomEventList() {
  if (_taskModel != null) {
    _taskModel!.findAll().then((_) {
      getCustomEventList(_taskModel!);
      if (mounted) {
        setState(() {});
      }
    });
  }
}
```

### 4. **Thêm optional notify parameter**
```dart
Future<void> findByCategory(int categoryId, {bool notify = true}) async {
  // ... logic ...
  if (notify) notifyListeners();
}
```

## Cách test:
1. Mở app, xem lịch biểu
2. Tạo task mới → Kiểm tra số đếm tăng
3. Xóa task → Kiểm tra số đếm giảm ngay lập tức
4. Xem console logs để debug

## Debug logs sẽ hiển thị:
- `🗑️ Deleting task: [id] - [title]`
- `✅ Task deleted, currentTask now has [X] tasks`
- `📊 getCustomEventList: [X] tasks`
- `📅 customEventList updated: [X] dates`

## Nếu vẫn lỗi:
1. Kiểm tra xem `currentTask` có thực sự giảm không
2. Kiểm tra xem `customEventList` có được cập nhật không
3. Kiểm tra xem UI có re-render không

## Test case:
1. Tạo task vào ngày hôm nay
2. Xem số đếm trên lịch (phải có số)
3. Xóa task
4. Số đếm phải biến mất ngay lập tức

## Possible fix nếu vẫn lỗi:
- Force rebuild calendar widget
- Sử dụng `ValueNotifier` thay vì `ChangeNotifier`
- Tạo method riêng để refresh calendar
