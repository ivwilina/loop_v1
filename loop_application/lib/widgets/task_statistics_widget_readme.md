# Task Statistics Widget

## Mô tả
Widget `TaskStatisticsWidget` hiển thị thống kê chi tiết về nhiệm vụ trong dự án, bao gồm:

1. **Tổng quan**: Tổng số nhiệm vụ, số nhiệm vụ đã hoàn thành, tỷ lệ hoàn thành và thời gian hoàn thành trung bình
2. **Biểu đồ trạng thái**: Phân bố nhiệm vụ theo trạng thái (tạo mới, đã gán, đang làm, đang duyệt, hoàn thành, đã đóng)
3. **Biểu đồ ưu tiên**: Phân bố nhiệm vụ theo mức độ ưu tiên (không có, thấp, trung bình, cao, ưu tiên)
4. **Biểu đồ hoàn thành**: Số lượng nhiệm vụ được tạo và hoàn thành theo ngày (7 ngày gần nhất)
5. **Biểu đồ thay đổi trạng thái**: Số lượng thay đổi trạng thái theo ngày (7 ngày gần nhất)
6. **Thống kê thành viên**: Hiển thị số lượng nhiệm vụ được gán và tỷ lệ hoàn thành của từng thành viên trong nhóm

## Cách sử dụng

```dart
TaskStatisticsWidget(
  projectId: 'your-project-id',
)
```

## Dữ liệu từ API

Widget này sử dụng API `TaskApi.getTaskStatistics()` để lấy dữ liệu thống kê. API trả về dữ liệu có cấu trúc:

```json
{
  "totalTasks": 50,
  "statusStats": {
    "created": 5,
    "assigned": 10,
    "pending": 15,
    "in_review": 8,
    "completed": 10,
    "closed": 2
  },
  "flagStats": {
    "none": 20,
    "low": 10,
    "medium": 12,
    "high": 6,
    "priority": 2
  },
  "completionStats": [
    {
      "date": "2025-06-28",
      "created": 3,
      "completed": 2
    }
  ],
  "statusChangeStats": [
    {
      "date": "2025-06-28",
      "changes": 5
    }
  ],
  "averageCompletionTime": 7,
  "completedTasksCount": 12,
  "memberStats": [
    {
      "fullName": "Nguyễn Văn A",
      "email": "a@example.com",
      "avatar": "https://...",
      "totalTasks": 8,
      "completedTasks": 6
    }
  ]
}
```

## Tính năng mới: Thống kê theo thành viên

- Hiển thị danh sách tất cả thành viên trong nhóm
- Hiển thị avatar, tên và email của thành viên
- Thống kê số lượng nhiệm vụ được gán cho mỗi thành viên
- Thống kê số lượng nhiệm vụ đã hoàn thành của mỗi thành viên
- Tính toán và hiển thị tỷ lệ hoàn thành với thanh progress bar
- Sử dụng mã màu để phân loại hiệu suất:
  - Xanh lá: ≥ 80%
  - Cam: ≥ 60%
  - Vàng: ≥ 40%
  - Đỏ: < 40%

## Cập nhật Backend

Để hỗ trợ thống kê theo thành viên, backend đã được cập nhật:

1. Thêm trường `memberStats` vào response của API `/task/statistics/:projectId`
2. Lấy thông tin thành viên từ project
3. Tính toán số lượng nhiệm vụ được gán và hoàn thành cho từng thành viên
4. Trả về thông tin chi tiết bao gồm tên, email, avatar của thành viên

## Ghi chú

- Widget hỗ trợ pull-to-refresh để cập nhật dữ liệu
- Xử lý các trường hợp không có dữ liệu hoặc lỗi kết nối
- Responsive design phù hợp với các kích thước màn hình khác nhau
- Sử dụng thư viện `fl_chart` để hiển thị biểu đồ
