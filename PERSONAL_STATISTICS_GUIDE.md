# Hướng dẫn Sử dụng Thống kê Cá nhân

## Cách chạy và test tính năng thống kê mới

### 1. Chuẩn bị dữ liệu mẫu

```bash
# Tạo dữ liệu mẫu phong phú cho thống kê
cd backend
npm run create-rich-data
```

Dữ liệu được tạo:
- ✅ 1 user: `testuser` / `123456`
- ✅ 100 nhiệm vụ cá nhân (assignee = null)
- ✅ 20 nhiệm vụ nhóm (có assignee)
- ✅ Phân bố thực tế: 46% hoàn thành, 26% có attachments
- ✅ Đa dạng về trạng thái, ưu tiên, thời hạn

### 2. Chạy Backend

```bash
cd backend
npm run dev
```

Backend chạy tại: `http://localhost:3000`

### 3. Chạy Flutter App

```bash
cd loop_application
flutter run
```

### 4. Đăng nhập và xem thống kê

1. **Đăng nhập**:
   - Username: `testuser`
   - Password: `123456`

2. **Xem thống kê**:
   - Chuyển đến tab "Cá Nhân"
   - Cuộn xuống để xem tất cả widget thống kê

## Các Widget Thống kê Có sẵn

### 📊 Widget Cơ bản
1. **Biểu đồ Tổng quan** - Pie chart hoàn thành/chưa hoàn thành
2. **Theo Trạng thái** - Bar chart theo status
3. **Theo Ưu tiên** - Bar chart theo priority flag
4. **Hiệu suất** - Cards với metrics và đánh giá

### 📈 Widget Nâng cao
5. **Xu hướng 7 ngày** - Line chart hoàn thành theo thời gian
6. **Thống kê Thời gian** - Cards theo today/week/month/overdue
7. **Theo Danh mục** - Bar chart theo category (Flutter local)
8. **Theo Loại** - Phân loại task theo keywords

### 🎯 Widget Chuyên sâu
9. **Năng suất 24h** - Line chart theo giờ trong ngày
10. **Độ phức tạp** - Pie chart dựa trên description length + priority
11. **Thời hạn** - Bar chart theo deadline proximity
12. **Chi tiết** - Summary stats với insights

### 🏆 Widget Mục tiêu
13. **Mục tiêu Cá nhân** - Progress bars cho daily/weekly/monthly goals

## Troubleshooting

### Lỗi thường gặp

1. **Không có dữ liệu thống kê**:
   ```bash
   # Kiểm tra có tasks không
   npm run check-data
   
   # Tạo lại dữ liệu
   npm run create-rich-data
   ```

2. **Lỗi đăng nhập**:
   ```bash
   # Test API đăng nhập
   npm run test-login
   ```

3. **Backend không chạy**:
   ```bash
   # Kiểm tra dependencies
   npm run test-deps
   
   # Khởi động lại
   npm run dev
   ```

### Kiểm tra dữ liệu

```bash
# Xem tổng quan dữ liệu
npm run check-data

# Test member stats API
npm run test-member-stats

# Debug project data
npm run debug-project
```

## Data Schema Mapping

### Backend → Flutter

| Backend Field | Flutter Field | Note |
|---------------|---------------|------|
| `title` | `title` | ✅ |
| `description` | `description` | ✅ |
| `status` | `status` | String → int mapping |
| `flag` | `flag` | String → int mapping |
| `deadline` | `deadline` | ✅ |
| `createTime` | `createTime` | ✅ |
| `assignee: null` | `isTeamTask: false` | Mapping logic |
| `attachments` | `attachment` | Array → Array |

### Status Mapping

| Backend | Flutter | Description |
|---------|---------|-------------|
| `created` | `0` | Mới tạo |
| `assigned` | `1` | Đã giao |
| `completed` | `2` | Hoàn thành |
| `pending` | `3` | Đang làm |
| `in_review` | `4` | Xem xét |
| `closed` | `5` | Đóng |

### Priority Mapping

| Backend | Flutter | Description |
|---------|---------|-------------|
| `none` | `0` | Không có |
| `low` | `1` | Thấp |
| `medium` | `2` | Trung bình |
| `high` | `3` | Cao |
| `priority` | `4` | Ưu tiên |

## Tùy chỉnh và Mở rộng

### Thêm widget thống kê mới

1. **Tạo widget method**:
   ```dart
   Widget buildMyCustomStats(TaskModel taskModel) {
     // Logic thống kê
     return Card(/* UI */);
   }
   ```

2. **Thêm vào build method**:
   ```dart
   Column(
     children: [
       // ...existing widgets...
       buildMyCustomStats(taskModel),
     ],
   )
   ```

### Tùy chỉnh mục tiêu

Trong `buildPersonalGoals()`:
```dart
int dailyGoal = 3;    // Thay đổi mục tiêu ngày
int weeklyGoal = 15;  // Thay đổi mục tiêu tuần
int monthlyGoal = 50; // Thay đổi mục tiêu tháng
```

### Thêm loại thống kê mới

Trong `buildTaskTypeStats()`:
```dart
Map<String, int> typeStats = {
  'Phát triển': 0,
  'Kiểm thử': 0,
  'Thiết kế': 0,
  'Tài liệu': 0,
  'Loại mới': 0,  // Thêm loại mới
  'Khác': 0,
};
```

## Performance Tips

1. **Lazy loading**: Widget chỉ render khi có dữ liệu
2. **Efficient filtering**: Sử dụng `where()` thay vì loops
3. **Caching**: Provider caching để tránh rebuild không cần thiết
4. **Pagination**: Giới hạn số lượng hiển thị nếu có quá nhiều dữ liệu

## Future Enhancements

1. **Real-time updates**: WebSocket cho updates thời gian thực
2. **Export**: PDF/Excel export cho reports
3. **Comparison**: So sánh hiệu suất giữa các khoảng thời gian
4. **Notifications**: Thông báo khi không đạt mục tiêu
5. **Gamification**: Badges, achievements, leaderboards
6. **AI Insights**: Machine learning để đưa ra recommendations

## Support

Nếu gặp vấn đề:
1. Kiểm tra console logs
2. Verify dữ liệu với backend scripts
3. Check network connectivity
4. Ensure proper authentication
5. Validate data format compatibility

## Development Notes

- Frontend sử dụng Provider pattern cho state management
- Backend sử dụng MongoDB với Mongoose
- Charts sử dụng fl_chart package
- UI tuân theo Material Design
- Responsive design cho mobile và tablet
- Performance optimized với lazy loading
