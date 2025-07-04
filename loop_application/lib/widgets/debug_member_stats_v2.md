# Debug Guide: Lỗi tải thành viên trong thống kê

## Vấn đề
Giao diện hiển thị "Chưa có thông tin thành viên" thay vì hiển thị thống kê thành viên.

## Các bước debug mới được thêm

### 1. Backend Debug
Tôi đã thêm:
- Console logs chi tiết trong controller
- Xử lý lỗi khi không tìm thấy thành viên
- Route debug `/task/debug/members/:projectId`
- Script debug `debug_member_stats.js`

### 2. Frontend Debug  
Tôi đã thêm:
- Kiểm tra null/undefined trước khi parse
- Method `_testApiConnection()` để test API
- Method `_buildEmptyMemberStats()` để hiển thị trạng thái empty
- Nút "Test API" để debug trực tiếp

### 3. API Debug
Tôi đã thêm:
- Method `debugMemberStats()` trong TaskApi
- Logs chi tiết trong response parsing

## Cách sử dụng debug tools

### 1. Frontend Debug
```dart
// Nhấn nút "Test API" trong giao diện
// Hoặc gọi trực tiếp:
await _testApiConnection();
```

### 2. Backend Debug (Node.js)
```bash
# Chạy script debug
cd backend
node debug_member_stats.js YOUR_PROJECT_ID
```

### 3. API Debug (HTTP)
```bash
# Test API debug trực tiếp
curl -X GET "http://localhost:3000/task/debug/members/YOUR_PROJECT_ID" \
  -H "Authorization: Bearer YOUR_TOKEN"
```

## Kiểm tra các trường hợp

### Trường hợp 1: Project không có thành viên
```json
{
  "project": {
    "memberCount": 0,
    "memberIds": []
  }
}
```
**Giải pháp**: Thêm thành viên vào project

### Trường hợp 2: Thành viên không tồn tại
```json
{
  "members": [
    {
      "id": "user-id",
      "found": false,
      "fullName": "Not found"
    }
  ]
}
```
**Giải pháp**: Kiểm tra database User collection

### Trường hợp 3: Nhiệm vụ không có assignee
```json
{
  "tasks": [
    {
      "title": "Task 1",
      "assignee": null,
      "hasAssignee": false
    }
  ]
}
```
**Giải pháp**: Gán nhiệm vụ cho thành viên

### Trường hợp 4: API không trả về memberStats
```json
{
  "totalTasks": 10,
  "statusStats": {...},
  // Thiếu memberStats
}
```
**Giải pháp**: Kiểm tra logic backend

## Các lỗi thường gặp

### 1. "Cannot read properties of undefined"
```javascript
// Lỗi: statisticsData['memberStats'] is undefined
// Sửa: Kiểm tra null trước khi truy cập
if (statisticsData && statisticsData['memberStats']) {
  // Process data
}
```

### 2. "findById is not a function"
```javascript
// Lỗi: User model không được import đúng
// Sửa: Kiểm tra import path
const User = require('../models/user.model');
```

### 3. "Project not found"
```javascript
// Lỗi: projectId không đúng hoặc project không tồn tại
// Sửa: Kiểm tra projectId trong database
```

## Checklist debug

### Backend
- [ ] Project tồn tại trong database
- [ ] Project có thành viên (member array)
- [ ] Thành viên tồn tại trong User collection
- [ ] Nhiệm vụ có assignee
- [ ] API trả về memberStats
- [ ] Console logs hiển thị đúng

### Frontend
- [ ] statisticsData không null
- [ ] statisticsData['memberStats'] tồn tại
- [ ] memberStats là array
- [ ] memberStats không empty
- [ ] Parsing không lỗi
- [ ] UI render đúng

### Database
- [ ] MongoDB đang chạy
- [ ] Collections tồn tại (Project, User, Task)
- [ ] Data relationships đúng
- [ ] ObjectId format đúng

## Log quan trọng cần xem

### Backend logs:
```
Project members: [...]
Total tasks: X
Task: ... Assignee: ... Status: ...
Final member stats: [...]
```

### Frontend logs:
```
Statistics data keys: [...]
Member stats raw: [...]
Processed member stats: [...]
Member stats length: X
```

## Giải pháp nhanh

### 1. Sử dụng dữ liệu demo
Nhấn nút "Dữ liệu demo" để test giao diện

### 2. Kiểm tra console
Mở Developer Tools → Console để xem logs

### 3. Test API trực tiếp
Nhấn nút "Test API" để kiểm tra kết nối

### 4. Reload dữ liệu
Nhấn nút "Tải lại" để refresh dữ liệu

Nếu vẫn gặp lỗi, hãy chạy debug tools và gửi kết quả logs để tôi có thể hỗ trợ thêm!
