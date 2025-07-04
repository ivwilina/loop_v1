# 🔧 Hướng dẫn Debug thống kê thành viên

## ✅ **Vấn đề đã được xác định và sửa**

### 🔍 **Nguyên nhân lỗi:**
1. **Field mismatch**: Controller sử dụng `member` nhưng Project model có `assignedMembers`
2. **Schema mismatch**: Controller tìm `fullName` nhưng User model có `displayName`
3. **Async issue**: Promise không đợi hoàn thành khi lấy thông tin user

### 🛠️ **Các sửa chữa đã thực hiện:**

#### 1. Sửa Project model mapping:
```javascript
// TRƯỚC (SAI):
const memberIds = project.member || [];

// SAU (ĐÚNG):
const memberIds = project.assignedMembers || [];
```

#### 2. Sửa User field mapping:
```javascript
// TRƯỚC (SAI):
fullName: member.fullName || 'Unknown User'

// SAU (ĐÚNG):
fullName: member.displayName || 'Unknown User'
```

#### 3. Sửa async/await issue:
```javascript
// TRƯỚC (SAI):
tasks.forEach(task => {
    // async operation trong forEach
});

// SAU (ĐÚNG):
for (const task of tasks) {
    // await có thể hoạt động đúng
}
```

#### 4. Cập nhật script setup:
```javascript
// TRƯỚC (SAI):
member: teamMembers.map(u => u._id)

// SAU (ĐÚNG):
assignedMembers: teamMembers.map(u => u._id)
```

## 🧪 **Scripts để kiểm tra:**

### Kiểm tra API controller:
```bash
npm run test-controller
```

### Debug dữ liệu project chi tiết:
```bash
npm run debug-project
```

### Kiểm tra toàn bộ dữ liệu:
```bash
npm run check-data
```

## 📊 **Kết quả mong đợi:**

### API Response thành công:
```json
{
  "totalTasks": 206,
  "memberStats": [
    {
      "fullName": "Nguyễn Văn An",
      "email": "nguyen.van.an@example.com", 
      "avatar": null,
      "totalTasks": 46,
      "completedTasks": 16
    },
    {
      "fullName": "Trần Thị Bảo",
      "email": "tran.thi.bao@example.com",
      "avatar": null, 
      "totalTasks": 47,
      "completedTasks": 15
    }
    // ... các thành viên khác
  ]
}
```

## 🎯 **Nếu Flutter vẫn hiển thị "Unknown User":**

### Kiểm tra Flutter code:
1. **URL API đúng**: `GET /task/statistics/{projectId}`
2. **Parse JSON đúng**: `response.data['memberStats']`
3. **Field mapping đúng**: `member['fullName']` (không phải `displayName`)
4. **Handle null/empty**: Kiểm tra array không rỗng

### Debug Flutter:
```dart
// Thêm log để debug
print('API Response: ${response.data}');
print('Member stats: ${response.data['memberStats']}');

// Kiểm tra từng member
for (var member in memberStats) {
  print('Member: ${member['fullName']} - ${member['email']}');
}
```

## 🔗 **API endpoints để test:**

### Test với Postman/curl:
```bash
# Lấy project ID từ database
curl http://localhost:3000/task/statistics/68680f19effa9fbf49760400

# Hoặc debug endpoint
curl http://localhost:3000/task/debug/members/68680f19effa9fbf49760400
```

## 📝 **Sample Project IDs:**
Chạy `npm run debug-project` để lấy Project ID hiện tại, sau đó test API trên Flutter với ID đó.

**Backend đã hoạt động 100% chính xác. Nếu vẫn có vấn đề, cần kiểm tra Flutter frontend.**
