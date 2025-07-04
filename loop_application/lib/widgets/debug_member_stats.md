# Debug Guide: Thống kê thành viên không hiển thị

## Vấn đề
Giao diện vẫn hiển thị "Chưa có thông tin thành viên" thay vì hiển thị thống kê thành viên.

## Các bước debug

### 1. Kiểm tra Console Log
Sau khi tôi đã thêm debug logs, hãy kiểm tra console/debug output để xem:

**Frontend (Flutter):**
- `Statistics data: ...` - Dữ liệu raw từ API
- `Member stats: ...` - Phần memberStats từ response
- `Building member statistics...` - Khi bắt đầu build widget
- `Processed member stats: ...` - Dữ liệu sau khi xử lý
- `Member stats length: ...` - Số lượng thành viên

**Backend (Node.js):**
- `Project members: ...` - Danh sách ID thành viên trong project
- `Total tasks: ...` - Tổng số nhiệm vụ
- `Task: ... Assignee: ... Status: ...` - Thông tin từng nhiệm vụ
- `Final member stats: ...` - Kết quả cuối cùng

### 2. Kiểm tra dữ liệu Project
Đảm bảo project có thành viên:
```javascript
// Trong database, project phải có trường member
{
  "_id": "project-id",
  "member": ["user-id-1", "user-id-2", ...],
  "task": [task-objects...]
}
```

### 3. Kiểm tra nhiệm vụ có assignee
Đảm bảo ít nhất một nhiệm vụ có assignee:
```javascript
// Trong database, task phải có assignee
{
  "_id": "task-id",
  "assignee": "user-id-1",
  "status": "assigned" // hoặc trạng thái khác
}
```

### 4. Test với dữ liệu demo
Trong widget, tôi đã thêm nút "Thử với dữ liệu demo". Nhấn nút này để test giao diện với dữ liệu giả.

### 5. Kiểm tra API trực tiếp
Sử dụng file `test_api.dart` hoặc Postman để test API:

```bash
GET /task/statistics/{projectId}
Headers: {
  "Authorization": "Bearer your-token",
  "Content-Type": "application/json"
}
```

Response mong đợi:
```json
{
  "totalTasks": 10,
  "memberStats": [
    {
      "fullName": "Nguyễn Văn A",
      "email": "a@example.com",
      "avatar": null,
      "totalTasks": 5,
      "completedTasks": 3
    }
  ]
}
```

### 6. Các nguyên nhân có thể

**Backend:**
- Project không có thành viên trong trường `member`
- Nhiệm vụ không có `assignee`
- Lỗi khi query User model
- Logic filter loại bỏ hết thành viên (chỉ giữ lại những người có nhiệm vụ)

**Frontend:**
- Dữ liệu từ API null hoặc undefined
- Lỗi khi parse JSON
- Logic kiểm tra `memberStats.isEmpty` sai

### 7. Giải pháp tạm thời

Nếu muốn test ngay, có thể tạm thời comment logic kiểm tra empty:

```dart
// Tạm thời comment để luôn hiển thị
// if (memberStats.isEmpty) {
//   return Container(...);
// }
```

Hoặc sử dụng dữ liệu fake:
```dart
final memberStats = statisticsData!['memberStats'] ?? [
  {
    'fullName': 'Test User',
    'email': 'test@example.com',
    'avatar': null,
    'totalTasks': 5,
    'completedTasks': 3
  }
];
```

## Checklist debug
- [ ] Kiểm tra console logs
- [ ] Kiểm tra project có thành viên
- [ ] Kiểm tra task có assignee
- [ ] Test API trực tiếp
- [ ] Test với dữ liệu demo
- [ ] Kiểm tra database data structure
