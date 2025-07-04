# Tài liệu Thống kê Cá nhân - Personal Statistics

## Tổng quan
Trang thống kê cá nhân (`personal_tab.dart`) đã được bổ sung nhiều widget thống kê mới để cung cấp thông tin chi tiết về hiệu suất và thói quen làm việc của người dùng.

## Các Widget Thống kê Mới

### 1. Biểu đồ Thống kê Tổng quan (buildPersonalTaskPieChart)
- **Mô tả**: Biểu đồ tròn hiển thị tỷ lệ nhiệm vụ đã hoàn thành/chưa hoàn thành
- **Dữ liệu**: Chỉ hiển thị nhiệm vụ cá nhân (isTeamTask = false)
- **Màu sắc**: Xanh lá (hoàn thành), Đỏ (chưa hoàn thành)

### 2. Thống kê Theo Trạng thái (buildTaskStatusChart)
- **Mô tả**: Biểu đồ thanh ngang thể hiện phân bố nhiệm vụ theo trạng thái
- **Các trạng thái**:
  - Mới tạo (0) - Xám
  - Đã giao (1) - Xanh dương
  - Đang làm (3) - Cam
  - Xem xét (4) - Tím
  - Hoàn thành (2) - Xanh lá
  - Đóng (5) - Đỏ

### 3. Thống kê Theo Mức độ Ưu tiên (buildPriorityChart)
- **Mô tả**: Thống kê nhiệm vụ theo mức độ ưu tiên (flag)
- **Các mức ưu tiên**:
  - Không có (0) - Xám
  - Thấp (1) - Xanh dương
  - Trung bình (2) - Vàng
  - Cao (3) - Cam
  - Ưu tiên (4) - Đỏ

### 4. Hiệu suất Cá nhân (buildPerformanceStats)
- **Mô tả**: Tổng hợp các số liệu hiệu suất
- **Bao gồm**:
  - Tổng nhiệm vụ, Hoàn thành, Đang làm, Chưa bắt đầu
  - Tỷ lệ hoàn thành với đánh giá (Xuất sắc, Tốt, Trung bình, Cần cải thiện)

### 5. Xu hướng Hoàn thành (buildTaskTimeline)
- **Mô tả**: Biểu đồ cột thể hiện xu hướng hoàn thành nhiệm vụ trong 7 ngày qua
- **Dữ liệu**: Số lượng nhiệm vụ hoàn thành theo từng ngày

### 6. Thống kê Theo Thời gian (buildTimeStats)
- **Mô tả**: Thống kê nhiệm vụ theo khung thời gian
- **Bao gồm**:
  - Hôm nay - Xanh dương
  - Tuần này - Xanh lá
  - Tháng này - Tím
  - Quá hạn - Đỏ

### 7. Thống kê Theo Danh mục (buildProjectStats)
- **Mô tả**: Phân bố nhiệm vụ theo danh mục (category)
- **Các danh mục**:
  - Công việc (1)
  - Cá nhân (2)
  - Học tập (3)
  - Sức khỏe (4)
  - Giải trí (5)
  - Khác (default)

### 8. Thống kê Theo Loại Nhiệm vụ (buildTaskTypeStats)
- **Mô tả**: Phân loại nhiệm vụ dựa trên title/description
- **Các loại**:
  - Phát triển (dev, code, lập trình)
  - Kiểm thử (test, debug, bug)
  - Thiết kế (design, ui, giao diện)
  - Tài liệu (doc, document, hướng dẫn)
  - Khác

### 9. Biểu đồ Năng suất (buildProductivityChart)
- **Mô tả**: Biểu đồ đường thể hiện năng suất theo giờ trong ngày
- **Dữ liệu**: Phân bố hoạt động theo 24 giờ
- **Giờ làm việc**: Tập trung vào 8h-20h

### 10. Thống kê Độ phức tạp (buildTaskComplexityStats)
- **Mô tả**: Biểu đồ tròn thể hiện độ phức tạp nhiệm vụ
- **Tính toán**: Dựa trên độ dài description + flag
- **Phân loại**:
  - Đơn giản - Xanh lá
  - Trung bình - Xanh dương
  - Phức tạp - Cam
  - Rất phức tạp - Đỏ

### 11. Thống kê Theo Thời hạn (buildTaskDeadlineStats)
- **Mô tả**: Phân bố nhiệm vụ theo thời hạn còn lại
- **Khung thời gian**:
  - Hôm nay - Đỏ
  - Ngày mai - Cam
  - Tuần này - Vàng
  - Tháng này - Xanh dương
  - Sau tháng này - Xanh lá

### 12. Thống kê Chi tiết (buildTaskInsights)
- **Mô tả**: Tổng hợp các thông tin chi tiết
- **Bao gồm**:
  - Tổng nhiệm vụ, Đã hoàn thành, Ưu tiên cao
  - Có mô tả, Có tệp đính kèm
  - Trung bình/ngày, Trạng thái phổ biến, Mức ưu tiên phổ biến

### 13. Mục tiêu Cá nhân (buildPersonalGoals)
- **Mô tả**: Theo dõi tiến độ đạt mục tiêu cá nhân
- **Mục tiêu**:
  - Hàng ngày: 3 nhiệm vụ
  - Hàng tuần: 15 nhiệm vụ
  - Hàng tháng: 50 nhiệm vụ
- **Hiển thị**: Thanh tiến độ với % hoàn thành và icon tick khi đạt mục tiêu

## Tính năng Kỹ thuật

### Responsive Design
- Tất cả widget đều responsive với màn hình khác nhau
- Sử dụng SingleChildScrollView để cuộn dọc
- Card layout với margin/padding thống nhất

### Color Scheme
- Sử dụng Material Design color palette
- Màu sắc có ý nghĩa (đỏ = cảnh báo, xanh lá = tích cực, xanh dương = thông tin)
- Opacity và transparency cho visual hierarchy

### Performance
- Chỉ render widget khi có dữ liệu (SizedBox.shrink() cho empty state)
- Efficient filtering với where() và lazy evaluation
- Minimal rebuild với proper state management

### Data Handling
- Xử lý null safety với ?? operator
- Graceful fallback cho dữ liệu thiếu
- Type-safe operations với proper casting

## Cách sử dụng

1. **Đăng nhập**: Người dùng cần đăng nhập để xem thống kê
2. **Tạo nhiệm vụ**: Tạo nhiệm vụ cá nhân để có dữ liệu thống kê
3. **Cuộn để xem**: Cuộn xuống để xem các loại thống kê khác nhau
4. **Tương tác**: Tap vào biểu đồ để xem chi tiết (nếu có)

## Mở rộng trong tương lai

1. **Thời gian thực**: Cập nhật thống kê theo thời gian thực
2. **Xuất báo cáo**: Xuất thống kê ra PDF/Excel
3. **So sánh**: So sánh hiệu suất giữa các khoảng thời gian
4. **Thông báo**: Nhắc nhở khi không đạt mục tiêu
5. **Tùy chỉnh**: Cho phép người dùng tùy chỉnh mục tiêu
6. **Gamification**: Thêm hệ thống điểm và thành tích
7. **Dự đoán**: AI/ML để dự đoán xu hướng hiệu suất

## Cấu trúc Code

```dart
// Các widget chính
buildPersonalTaskPieChart()     // Biểu đồ tổng quan
buildTaskStatusChart()          // Theo trạng thái
buildPriorityChart()           // Theo ưu tiên
buildPerformanceStats()        // Hiệu suất
buildTaskTimeline()            // Xu hướng theo thời gian
buildTimeStats()               // Theo thời gian
buildProjectStats()            // Theo danh mục
buildTaskTypeStats()           // Theo loại nhiệm vụ
buildProductivityChart()       // Năng suất
buildTaskComplexityStats()     // Độ phức tạp
buildTaskDeadlineStats()       // Theo thời hạn
buildTaskInsights()            // Chi tiết
buildPersonalGoals()           // Mục tiêu

// Các helper methods
_buildStatCard()               // Card thống kê nhỏ
_buildTimeStatCard()           // Card thống kê thời gian
_buildInsightRow()             // Row thông tin chi tiết
_buildGoalProgress()           // Thanh tiến độ mục tiêu
_getCategoryName()             // Tên danh mục
_getMostCommonStatus()         // Trạng thái phổ biến
_getMostCommonPriority()       // Ưu tiên phổ biến
```

## Dependencies

- `fl_chart`: Cho các biểu đồ (PieChart, BarChart, LineChart)
- `provider`: State management
- `flutter/material.dart`: Material Design widgets

## Cấu hình

Để sử dụng đầy đủ tính năng, cần:
1. Đảm bảo TaskModel có dữ liệu
2. UserController đã load thông tin người dùng
3. Nhiệm vụ cá nhân (isTeamTask = false) có sẵn
4. Các trường bắt buộc: title, status, flag, deadline
