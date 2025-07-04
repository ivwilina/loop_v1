# Sửa lỗi số đếm sai khi chọn ngày khác

## Vấn đề:
- Xóa task → Số đếm đúng ✅
- Chọn ngày khác → Số đếm sai ❌

## Nguyên nhân:
1. **customEventList không được refresh khi chọn ngày khác**
2. **findByDate() chỉ cập nhật taskOnSpecificDay, không cập nhật currentTask**
3. **currentTask có thể không sync với database thực tế**
4. **Sort được gọi trong vòng lặp (hiệu suất kém)**

## Giải pháp đã thực hiện:

### 1. **Force refresh customEventList khi chọn ngày**
```dart
onDaySelected: (selectedDay, focusedDay) {
  // ... existing code ...
  // Force refresh customEventList khi chọn ngày khác
  if (_taskModel != null) {
    getCustomEventList(_taskModel!);
  }
}
```

### 2. **Refresh customEventList khi chuyển trang lịch**
```dart
onPageChanged: (focusedDay) {
  _focusedDay = focusedDay;
  // Refresh customEventList khi chuyển trang lịch
  if (_taskModel != null) {
    getCustomEventList(_taskModel!);
  }
}
```

### 3. **Cải thiện findByDate() logic**
```dart
Future<void> findByDate(DateTime dayToSearch, {bool notify = true}) async {
  // Luôn fetch fresh data từ database
  List<Task> fetchedTasks = await isar.tasks.where().findAll();
  
  // Cập nhật currentTask để đảm bảo sync
  currentTask.clear();
  currentTask.addAll(fetchedTasks);
  
  // Filter tasks cho ngày cụ thể
  taskOnSpecificDay.clear();
  for (var n in fetchedTasks) {
    if (dayToSearch.year == n.deadline.year &&
        dayToSearch.month == n.deadline.month &&
        dayToSearch.day == n.deadline.day) {
      if (!taskOnSpecificDay.contains(n)) {
        taskOnSpecificDay.add(n);
      }
    }
  }
  
  // Sort sau khi hoàn thành vòng lặp (không sort trong vòng lặp)
  taskOnSpecificDay.sort((a, b) => a.deadline.compareTo(b.deadline));
  
  if (notify) notifyListeners();
}
```

### 4. **Đảm bảo data sync**
- `findByDate()` giờ tự động cập nhật cả `currentTask` và `taskOnSpecificDay`
- Fresh data luôn được fetch từ database
- `customEventList` được refresh khi cần thiết

## Workflow mới:
1. User chọn ngày khác
2. `onDaySelected` được trigger
3. `readTasksOnSpecificDate()` gọi `findByDate()`
4. `findByDate()` fetch fresh data từ database
5. `currentTask` và `taskOnSpecificDay` được cập nhật
6. `getCustomEventList()` được gọi để refresh calendar markers
7. `notifyListeners()` trigger UI update
8. Số đếm hiển thị đúng

## Kết quả:
- ✅ Xóa task → Số đếm đúng
- ✅ Chọn ngày khác → Số đếm đúng
- ✅ Chuyển trang lịch → Số đếm đúng
- ✅ Hiệu suất tốt hơn (không sort trong vòng lặp)

## Test cases:
1. Tạo task vào ngày A
2. Chọn ngày B (không có task) → Số đếm = 0
3. Chọn lại ngày A → Số đếm = 1
4. Xóa task ở ngày A → Số đếm = 0
5. Chuyển trang lịch qua tuần khác → Số đếm đúng
6. Chuyển tab rồi quay lại → Số đếm vẫn đúng

## Lưu ý:
- `findByDate()` giờ đảm bảo data sync hoàn toàn
- `customEventList` được refresh khi cần thiết
- Performance tốt hơn với sort logic được tối ưu
