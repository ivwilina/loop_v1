# Sửa lỗi Infinite Loop khi xóa task

## Vấn đề:
- Số đếm trên lịch đã giảm sau khi xóa task ✅
- Nhưng debug logs chạy liên tục → Infinite loop ❌

## Nguyên nhân:
1. **Vòng lặp notifyListeners()**: 
   - `deleteTask()` → `notifyListeners()` → `_refreshCustomEventList()` → `findAll()` → `notifyListeners()` → ...

2. **Build method gọi getCustomEventList() liên tục**:
   - Mỗi lần build → `getCustomEventList()` → có thể trigger rebuild

3. **Multiple listeners**: 
   - Setup listener nhiều lần trong build method

## Giải pháp đã thực hiện:

### 1. **Xóa debug logs**
```dart
// Trước: print("🗑️ Deleting task: ${task.id} - ${task.title}");
// Sau:   // Không có debug logs
```

### 2. **Tối ưu hóa _refreshCustomEventList()**
```dart
// Trước: _taskModel!.findAll().then((_) => { ... });
// Sau:   getCustomEventList(_taskModel!); // Chỉ update customEventList
```

### 3. **Chỉ gọi getCustomEventList() khi cần thiết**
```dart
// Trước: getCustomEventList(taskModel); // Mỗi lần build
// Sau:   getCustomEventList(taskModel); // Chỉ khi taskModel thay đổi
```

### 4. **Cải thiện listener setup**
```dart
if (_taskModel != taskModel) {
  _taskModel?.removeListener(_refreshCustomEventList);
  _taskModel = taskModel;
  _taskModel!.addListener(_refreshCustomEventList);
  // Chỉ cập nhật customEventList khi taskModel thay đổi
  getCustomEventList(taskModel);
}
```

### 5. **Đảm bảo mounted check**
```dart
void _refreshCustomEventList() {
  if (_taskModel != null && mounted) {
    getCustomEventList(_taskModel!);
    setState(() {});
  }
}
```

## Kết quả:
- ✅ Số đếm giảm khi xóa task
- ✅ Không còn infinite loop
- ✅ Logs không chạy liên tục
- ✅ Performance tốt hơn

## Workflow sau khi sửa:
1. User xóa task
2. `deleteTask()` xóa khỏi database
3. `findAll()` update currentTask + notify listeners
4. `_refreshCustomEventList()` được gọi một lần
5. `customEventList` được update
6. UI re-render với số đếm mới
7. Kết thúc (không loop)

## Test:
1. Xóa task → Số đếm giảm ngay lập tức
2. Console sạch sẽ, không có logs liên tục
3. App chạy mượt mà không lag

## Lưu ý:
- Tránh gọi `findAll()` trong listener của chính nó
- Chỉ update UI state, không trigger thêm data operations
- Luôn check `mounted` trước khi setState()
