import 'package:flutter/material.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/apis/task_api.dart';
import 'package:loop_application/apis/team_api.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/views/assign_task_dialog.dart';
import 'package:loop_application/widgets/task_status_button.dart';
import 'package:loop_application/widgets/task_statistics_widget.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';

class ProjectDetailView extends StatefulWidget {
  final String projectId;
  final String projectName;
  final String teamId;

  const ProjectDetailView({
    super.key,
    required this.projectId,
    required this.projectName,
    required this.teamId,
  });

  @override
  State<ProjectDetailView> createState() => _ProjectDetailViewState();
}

class _ProjectDetailViewState extends State<ProjectDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Calendar and task variables (similar to home_tab.dart)
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime dayToViewTask = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  // Task data from API
  List<Map<String, dynamic>> projectTasks = [];
  Map<DateTime, List<String>> customEventList = {};
  bool isLoading = true;

  // Task status filter
  String _taskStatusFilter =
      'all'; // 'all', 'created', 'assigned', 'pending', 'in_review', 'completed', 'closed'
  bool _filterBySelectedDate = false; // Flag to enable/disable date filtering

  // Filter tasks based on status and optionally by selected date
  List<Map<String, dynamic>> get _filteredTasks {
    List<Map<String, dynamic>> tasks = projectTasks;

    // Filter by status using statusString for consistency with backend
    if (_taskStatusFilter != 'all') {
      tasks =
          tasks
              .where((task) => task['statusString'] == _taskStatusFilter)
              .toList();
    }

    // Filter by selected date if enabled
    if (_filterBySelectedDate && _selectedDay != null) {
      tasks =
          tasks.where((task) {
            if (task['deadline'] == null) return false;
            try {
              DateTime taskDate = DateTime.parse(task['deadline']);
              DateTime selectedDate = convertToDefaultDate(_selectedDay!);
              return taskDate.year == selectedDate.year &&
                  taskDate.day == selectedDate.day;
            } catch (e) {
              return false;
            }
          }).toList();
    }

    // Sort tasks by flag priority (highest priority first), then by creation date
    tasks.sort((a, b) {
      // First sort by flag priority
      String flagA = a['flag'] ?? 'none';
      String flagB = b['flag'] ?? 'none';
      int priorityComparison = _getFlagPriority(
        flagB,
      ).compareTo(_getFlagPriority(flagA));

      if (priorityComparison != 0) {
        return priorityComparison;
      }

      // If same priority, sort by creation date (newest first)
      String dateA = a['createdAt'] ?? a['_id'] ?? '';
      String dateB = b['createdAt'] ?? b['_id'] ?? '';
      return dateB.compareTo(dateA);
    });

    return tasks;
  }

  // Team info and user permissions
  String? currentUserId;
  String currentUserRole = 'member';
  Map<String, dynamic>? teamInfo;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _selectedDay = _focusedDay;
    dayToViewTask = convertToDefaultDate(_focusedDay);
    _initCurrentUser(); // Initialize current user info
    _loadProjectTasks();
  }

  // Initialize current user ID and role
  Future<void> _initCurrentUser() async {
    try {
      final userController = UserController();
      await userController.getUser();
      currentUserId = await userController.getUserIdServer();

      // Get team info to determine user role
      teamInfo = await TeamApi.getTeamById(widget.teamId);
      if (teamInfo != null &&
          teamInfo!['members'] != null &&
          currentUserId != null) {
        for (var member in teamInfo!['members']) {
          final memberId = _getMemberId(member);
          if (memberId == currentUserId) {
            currentUserRole = _getMemberRole(member).toLowerCase();
            break;
          }
        }
      }
      setState(() {}); // Update UI after getting user info
    } catch (e) {
      print('Error getting current user info: $e');
    }
  }

  // Helper methods to extract member information
  String _getMemberId(Map<String, dynamic> member) {
    if (member['member'] is Map<String, dynamic>) {
      final memberData = member['member'] as Map<String, dynamic>;
      return memberData['_id'] ?? '';
    }
    return member['member']?.toString() ?? '';
  }

  String _getMemberRole(Map<String, dynamic> member) {
    return member['role'] ?? 'member';
  }

  // Check if current user can manage tasks (admin/owner only)
  bool _canManageTasks() {
    return currentUserRole == 'admin' || currentUserRole == 'owner';
  }

  // Load project tasks from API
  Future<void> _loadProjectTasks() async {
    try {
      setState(() {
        isLoading = true;
      });

      final tasks = await TaskApi.getTasksOfProject(widget.projectId);

      setState(() {
        projectTasks =
            tasks
                .where((task) => task != null && task['_id'] != null)
                .map(
                  (task) => {
                    'id':
                        task['_id']?.toString() ??
                        '', // Đảm bảo chuyển đổi chuỗi
                    'title': task['title']?.toString() ?? 'Untitled Task',
                    'description': task['description']?.toString() ?? '',
                    'deadline': task['deadline'],
                    'status': _convertStatusToInt(
                      task['status'],
                    ), // Chuyển đổi trạng thái chuỗi thành số nguyên để tương thích UI
                    'statusString':
                        task['status']?.toString() ??
                        'pending', // Giữ trạng thái chuỗi gốc
                    'flag':
                        task['flag']?.toString() ?? 'none', // Thêm cờ ưu tiên
                    'subtasks': task['subtasks'] ?? [],
                    'assignee': task['assignee'],
                    'createdBy': task['createdBy'],
                    'createdAt': task['createdAt'],
                    'updatedAt': task['updatedAt'],
                  },
                )
                .toList();
        isLoading = false;
        // Update calendar markers after loading tasks
        getCustomEventList();
      });
    } catch (e) {
      print('Error loading project tasks: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Convert string status from backend to integer for UI
  int _convertStatusToInt(String? status) {
    switch (status?.toLowerCase()) {
      case 'created':
        return 0;
      case 'assigned':
        return 1;
      case 'pending':
        return 2;
      case 'in_review':
        return 3;
      case 'completed':
        return 4;
      case 'closed':
        return 5;
      default:
        return 2; // Default to pending
    }
  }

  // Lấy màu sắc cho cờ ưu tiên
  Color _getFlagColor(String flag) {
    switch (flag.toLowerCase()) {
      case 'low':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      case 'high':
        return Colors.red;
      case 'priority':
        return Colors.purple;
      case 'none':
      default:
        return Colors.grey.shade400;
    }
  }

  // Lấy biểu tượng cho cờ ưu tiên
  IconData _getFlagIcon(String flag) {
    switch (flag.toLowerCase()) {
      case 'low':
        return Icons.flag;
      case 'medium':
        return Icons.flag;
      case 'high':
        return Icons.flag;
      case 'priority':
        return Icons.priority_high;
      case 'none':
      default:
        return Icons.flag_outlined;
    }
  }

  // Lấy tên hiển thị cho cờ ưu tiên
  String _getFlagDisplayName(String flag) {
    switch (flag.toLowerCase()) {
      case 'low':
        return 'Thấp';
      case 'medium':
        return 'Trung bình';
      case 'high':
        return 'Cao';
      case 'priority':
        return 'Ưu tiên';
      case 'none':
      default:
        return 'Không có';
    }
  }

  // Lấy tên tiếng Việt cho flag
  String _getVietnameseFlag(String flag) {
    return _getFlagDisplayName(flag);
  }

  // Lấy màu sắc cho trạng thái
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return Theme.of(context).colorScheme.outline;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'in_review':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  // Lấy tên tiếng Việt cho trạng thái
  String _getVietnameseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'created':
        return 'Đã tạo';
      case 'assigned':
        return 'Đã giao';
      case 'pending':
        return 'Đang thực hiện';
      case 'in_review':
        return 'Đang xem xét';
      case 'completed':
        return 'Hoàn thành';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Không xác định';
    }
  }

  // Danh sách các cờ ưu tiên có sẵn

  Widget _buildTaskStatusFilter() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Status filter row
          Row(
            children: [
              Text(
                'Lọc theo trạng thái:',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('all', 'Tất cả', Icons.list),
                      SizedBox(width: 8),
                      _buildFilterChip('created', 'Được tạo', Icons.fiber_new),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'assigned',
                        'Đã gán',
                        Icons.assignment_ind,
                      ),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'pending',
                        'Đang thực hiện',
                        Icons.pending,
                      ),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'in_review',
                        'Chờ duyệt',
                        Icons.rate_review,
                      ),
                      SizedBox(width: 8),
                      _buildFilterChip(
                        'completed',
                        'Hoàn thành',
                        Icons.check_circle,
                      ),
                      SizedBox(width: 8),
                      _buildFilterChip('closed', 'Đã đóng', Icons.lock),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Date filter toggle
          SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.calendar_today,
                size: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              SizedBox(width: 8),
              Text(
                'Chỉ hiển thị nhiệm vụ của ngày được chọn',
                style: TextStyle(
                  fontSize: 14,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),
              Spacer(),
              Switch(
                value: _filterBySelectedDate,
                onChanged: (value) {
                  setState(() {
                    _filterBySelectedDate = value;
                    // No need to update calendar markers - they should always show all tasks
                  });
                },
                activeColor: Theme.of(context).colorScheme.primaryContainer,
              ),
            ],
          ),

          // Show selected date if filtering is enabled
          if (_filterBySelectedDate && _selectedDay != null) ...[
            SizedBox(height: 4),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.date_range,
                    size: 14,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                  SizedBox(width: 4),
                  Text(
                    'Ngày đã chọn: ${DateFormat('dd/MM/yyyy').format(_selectedDay!)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.primaryContainer,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFilterChip(String value, String label, IconData icon) {
    bool isSelected = _taskStatusFilter == value;
    Color chipColor = _getFilterColor(value);

    return FilterChip(
      selected: isSelected,
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: isSelected ? Colors.white : chipColor),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : chipColor,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            ),
          ),
        ],
      ),
      onSelected: (bool selected) {
        setState(() {
          _taskStatusFilter = selected ? value : 'all';
          // No need to update calendar markers - they should always show all tasks
        });
      },
      selectedColor: chipColor,
      backgroundColor: chipColor.withOpacity(0.1),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected ? chipColor : chipColor.withOpacity(0.3),
        width: 1,
      ),
    );
  }

  Color _getFilterColor(String filterValue) {
    switch (filterValue) {
      case 'created':
        return Colors.grey;
      case 'assigned':
        return Colors.blue;
      case 'pending':
        return Colors.orange;
      case 'in_review':
        return Colors.purple;
      case 'completed':
        return Colors.green;
      case 'closed':
        return Colors.red;
      case 'all':
      default:
        return Theme.of(context).colorScheme.primaryContainer;
    }
  }

  // Create new task for this project
  Future<void> _createTask() async {
    await _showTaskDialog();
  }

  // Show task creation/editing dialog
  Future<void> _showTaskDialog({Map<String, dynamic>? task}) async {
    String title = task?['title'] ?? 'Nhiệm vụ mới';
    String description = task?['description'] ?? '';
    DateTime selectedDate = dayToViewTask;
    if (task != null && task['deadline'] != null) {
      try {
        selectedDate = DateTime.parse(task['deadline']);
      } catch (e) {
        print('Error parsing deadline: ${e.toString()}');
        selectedDate = dayToViewTask;
      }
    }
    String selectedFlag =
        task?['flag'] ??
        'none'; // Lấy flag từ task hiện tại hoặc mặc định là 'none'
    Map<int, String> subtasks = {};
    int tempSubtaskCount = 0;

    // Load existing subtasks if editing
    if (task != null && task['subtasks'] != null && task['subtasks'] is List) {
      try {
        final existingSubtasks = task['subtasks'] as List;
        for (int i = 0; i < existingSubtasks.length; i++) {
          final subtask = existingSubtasks[i];
          if (subtask != null) {
            subtasks[i] =
                (subtask is Map<String, dynamic>
                    ? subtask['title']?.toString()
                    : subtask.toString()) ??
                'Subtask ${i + 1}';
            tempSubtaskCount = i + 1;
          }
        }
      } catch (e) {
        print('Error parsing existing subtasks: $e');
      }
    }

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Dialog(
              child: Container(
                width:
                    MediaQuery.of(context).size.width *
                    0.9, // 90% chiều rộng màn hình
                height:
                    MediaQuery.of(context).size.height *
                    0.85, // 85% chiều cao màn hình
                constraints: BoxConstraints(
                  maxWidth: 600, // Giới hạn tối đa cho màn hình lớn
                  maxHeight: 800,
                  minWidth: 400, // Đảm bảo kích thước tối thiểu
                  minHeight: 600,
                ),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 20,
                ), // Giảm padding thêm
                child: Column(
                  spacing: 12, // Giảm khoảng cách chính từ 16 xuống 12
                  children: [
                    // Dialog header
                    Container(
                      padding: EdgeInsets.only(
                        bottom: 10,
                      ), // Giảm từ 12 xuống 10
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            task == null ? Icons.add_task : Icons.edit_note,
                            color: Theme.of(context).colorScheme.onPrimary,
                            size: 16, // Giảm từ 18 xuống 16
                          ),
                          SizedBox(width: 6), // Giảm từ 8 xuống 6
                          Expanded(
                            child: Text(
                              task == null
                                  ? 'Tạo nhiệm vụ mới'
                                  : 'Chỉnh sửa nhiệm vụ',
                              style: TextStyle(
                                fontSize: 14, // Giảm từ 16 xuống 14
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                              overflow:
                                  TextOverflow
                                      .ellipsis, // Thêm để tránh overflow
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(
                              Icons.close,
                              color: Theme.of(context).colorScheme.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Task title input
                    Container(
                      margin: EdgeInsets.only(top: 2), // Giảm từ 4 xuống 2
                      child: TextFormField(
                        style: TextStyle(fontSize: 13), // Giảm từ 14 xuống 13
                        initialValue: title,
                        textInputAction: TextInputAction.done,
                        maxLines: null,
                        onChanged: (value) => title = value,
                        decoration: InputDecoration(
                          label: Text(
                            'Tiêu đề',
                            style: TextStyle(fontSize: 13),
                          ), // Giảm từ 14 xuống 13
                          alignLabelWithHint: true,
                          floatingLabelStyle: TextStyle(
                            fontSize: 13, // Giảm từ 14 xuống 13
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Description input
                    Container(
                      margin: EdgeInsets.only(top: 2), // Giảm từ 4 xuống 2
                      child: TextFormField(
                        style: TextStyle(fontSize: 13), // Giảm từ 14 xuống 13
                        initialValue: description,
                        textInputAction: TextInputAction.newline,
                        maxLines: 3,
                        onChanged: (value) => description = value,
                        decoration: InputDecoration(
                          label: Text(
                            'Mô tả',
                            style: TextStyle(fontSize: 13),
                          ), // Giảm từ 14 xuống 13
                          alignLabelWithHint: true,
                          floatingLabelStyle: TextStyle(
                            fontSize: 13, // Giảm từ 14 xuống 13
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.outline,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Deadline option
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 2,
                      ), // Giảm từ 4 xuống 2
                      padding: EdgeInsets.all(10), // Giảm từ 12 xuống 10
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Giảm từ 10 xuống 8
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.schedule,
                            color: Theme.of(context).colorScheme.primary,
                            size: 14, // Giảm từ 16 xuống 14
                          ),
                          SizedBox(width: 6), // Giảm từ 8 xuống 6
                          Flexible(
                            child: Text(
                              'Thời hạn:',
                              style: TextStyle(
                                fontSize: 12, // Giảm từ 13 xuống 12
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Spacer(),
                          GestureDetector(
                            onTap: () async {
                              DateTime? pickedDate =
                                  await _customDateTimePicker(context: context);
                              if (pickedDate != null) {
                                setDialogState(() {
                                  selectedDate = pickedDate;
                                });
                              }
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 6, // Giảm từ 8 xuống 6
                                vertical: 3, // Giảm từ 4 xuống 3
                              ),
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                borderRadius: BorderRadius.circular(
                                  12,
                                ), // Giảm từ 16 xuống 12
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit_calendar,
                                    size: 10, // Giảm từ 12 xuống 10
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 2), // Giảm từ 3 xuống 2
                                  Flexible(
                                    child: Text(
                                      DateFormat(
                                        'dd/MM/yyyy HH:mm',
                                      ).format(selectedDate),
                                      style: TextStyle(
                                        color:
                                            Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 10, // Giảm từ 11 xuống 10
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Flag selection - Chọn mức độ ưu tiên
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 2,
                      ), // Giảm từ 4 xuống 2
                      padding: EdgeInsets.all(10), // Giảm từ 12 xuống 10
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.surface.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(
                          8,
                        ), // Giảm từ 10 xuống 8
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.flag_outlined,
                            color: Theme.of(context).colorScheme.primary,
                            size: 14, // Giảm từ 16 xuống 14
                          ),
                          SizedBox(width: 6), // Giảm từ 8 xuống 6
                          Flexible(
                            child: Text(
                              'Mức độ ưu tiên:',
                              style: TextStyle(
                                fontSize: 12, // Giảm từ 13 xuống 12
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 6), // Giảm từ 8 xuống 6
                          Expanded(
                            child: Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 3,
                                vertical: 1,
                              ), // Giảm padding thêm nữa
                              decoration: BoxDecoration(
                                color:
                                    selectedFlag != 'none'
                                        ? _getFlagColor(
                                          selectedFlag,
                                        ).withOpacity(0.15)
                                        : Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.3),
                                borderRadius: BorderRadius.circular(
                                  6,
                                ), // Giảm từ 8 xuống 6
                                border: Border.all(
                                  color:
                                      selectedFlag != 'none'
                                          ? _getFlagColor(
                                            selectedFlag,
                                          ).withOpacity(0.4)
                                          : Theme.of(
                                            context,
                                          ).colorScheme.primaryContainer,
                                  width: 1,
                                ),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedFlag,
                                  isExpanded: true, // Để tránh overflow
                                  isDense: true, // Thêm để giảm kích thước
                                  style: TextStyle(
                                    color:
                                        selectedFlag != 'none'
                                            ? _getFlagColor(selectedFlag)
                                            : Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                    fontSize: 9, // Giảm từ 10 xuống 9
                                    fontWeight: FontWeight.w500,
                                  ),
                                  dropdownColor:
                                      Theme.of(context).colorScheme.surface,
                                  items:
                                      [
                                        {'value': 'none', 'label': 'Không có'},
                                        {'value': 'low', 'label': 'Thấp'},
                                        {'value': 'medium', 'label': 'TB'},
                                        {'value': 'high', 'label': 'Cao'},
                                        {
                                          'value': 'priority',
                                          'label': 'Ưu tiên',
                                        },
                                      ].map((flag) {
                                        return DropdownMenuItem<String>(
                                          value: flag['value'],
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 2,
                                              vertical: 1,
                                            ), // Giảm padding thêm nữa
                                            decoration: BoxDecoration(
                                              color:
                                                  flag['value'] != 'none'
                                                      ? _getFlagColor(
                                                        flag['value']!,
                                                      ).withOpacity(0.1)
                                                      : Colors.grey.withOpacity(
                                                        0.1,
                                                      ),
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    3,
                                                  ), // Giảm từ 4 xuống 3
                                              border: Border.all(
                                                color:
                                                    flag['value'] != 'none'
                                                        ? _getFlagColor(
                                                          flag['value']!,
                                                        ).withOpacity(0.3)
                                                        : Colors.grey
                                                            .withOpacity(0.3),
                                                width: 1,
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getFlagIcon(flag['value']!),
                                                  color:
                                                      flag['value'] != 'none'
                                                          ? _getFlagColor(
                                                            flag['value']!,
                                                          )
                                                          : Colors.grey,
                                                  size: 8, // Giảm từ 10 xuống 8
                                                ),
                                                SizedBox(
                                                  width: 1,
                                                ), // Giảm từ 2 xuống 1
                                                Flexible(
                                                  child: Text(
                                                    flag['label']!,
                                                    style: TextStyle(
                                                      color:
                                                          flag['value'] !=
                                                                  'none'
                                                              ? _getFlagColor(
                                                                flag['value']!,
                                                              )
                                                              : Theme.of(
                                                                    context,
                                                                  )
                                                                  .colorScheme
                                                                  .inversePrimary,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize:
                                                          8, // Giảm từ 9 xuống 8
                                                    ),
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setDialogState(() {
                                        selectedFlag = newValue;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Subtask option
                    Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 2,
                      ), // Giảm từ 4 xuống 2
                      padding: EdgeInsets.all(8), // Giảm từ 10 xuống 8
                      decoration: BoxDecoration(
                        color: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(
                          6,
                        ), // Giảm từ 8 xuống 6
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          width: 1,
                        ),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setDialogState(() {
                            subtasks[tempSubtaskCount] = 'Nhiệm vụ con mới';
                            tempSubtaskCount++;
                          });
                        },
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_circle_outline,
                              color: Theme.of(context).colorScheme.primary,
                              size: 14, // Giảm từ 16 xuống 14
                            ),
                            SizedBox(width: 6), // Giảm từ 8 xuống 6
                            Flexible(
                              child: Text(
                                "Thêm nhiệm vụ con",
                                style: TextStyle(
                                  fontSize: 12, // Giảm từ 13 xuống 12
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Spacer(),
                            if (subtasks.isNotEmpty)
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 4,
                                  vertical: 1,
                                ), // Giảm padding thêm
                                decoration: BoxDecoration(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(
                                    6,
                                  ), // Giảm từ 8 xuống 6
                                ),
                                child: Text(
                                  '${subtasks.length}',
                                  style: TextStyle(
                                    fontSize: 9, // Giảm từ 10 xuống 9
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),

                    // Subtask list
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(
                            context,
                          ).colorScheme.surface.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(
                            8,
                          ), // Giảm từ 10 xuống 8
                          border: Border.all(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child:
                            subtasks.isEmpty
                                ? Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(
                                      20,
                                    ), // Giảm từ 24 xuống 20
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.task_alt_outlined,
                                          size: 28, // Giảm từ 32 xuống 28
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.outline,
                                        ),
                                        SizedBox(
                                          height: 6,
                                        ), // Giảm từ 8 xuống 6
                                        Text(
                                          'Chưa có nhiệm vụ con nào',
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.outline,
                                            fontSize: 11, // Giảm từ 12 xuống 11
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                                : ListView.separated(
                                  padding: EdgeInsets.all(
                                    10,
                                  ), // Giảm từ 12 xuống 10
                                  itemCount: subtasks.length,
                                  separatorBuilder:
                                      (context, index) => SizedBox(
                                        height: 10,
                                      ), // Giảm từ 12 xuống 10
                                  itemBuilder: (context, index) {
                                    final entry = subtasks.entries.elementAt(
                                      index,
                                    );
                                    return Container(
                                      margin: EdgeInsets.symmetric(
                                        horizontal: 2,
                                      ), // Giảm từ 4 xuống 2
                                      padding: EdgeInsets.all(
                                        8,
                                      ), // Giảm từ 10 xuống 8
                                      decoration: BoxDecoration(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primaryContainer
                                            .withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(
                                          6,
                                        ), // Giảm từ 8 xuống 6
                                        border: Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primaryContainer
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          // Icon số thứ tự
                                          Container(
                                            width: 18, // Giảm từ 20 xuống 18
                                            height: 18, // Giảm từ 20 xuống 18
                                            decoration: BoxDecoration(
                                              color:
                                                  Theme.of(
                                                    context,
                                                  ).colorScheme.primary,
                                              borderRadius:
                                                  BorderRadius.circular(
                                                    9,
                                                  ), // Giảm từ 10 xuống 9
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.onPrimary,
                                                  fontSize:
                                                      9, // Giảm từ 10 xuống 9
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ), // Giảm từ 10 xuống 8
                                          // Text field
                                          Expanded(
                                            child: TextFormField(
                                              key: Key(entry.key.toString()),
                                              initialValue: entry.value,
                                              style: TextStyle(
                                                fontSize: 11,
                                              ), // Giảm từ 12 xuống 11
                                              onChanged: (inputSubtask) {
                                                subtasks.update(
                                                  entry.key,
                                                  (value) => inputSubtask,
                                                );
                                              },
                                              decoration: InputDecoration(
                                                hintText: 'Nhiệm vụ con...',
                                                hintStyle: TextStyle(
                                                  color:
                                                      Theme.of(
                                                        context,
                                                      ).colorScheme.outline,
                                                  fontSize:
                                                      11, // Giảm từ 12 xuống 11
                                                ),
                                                border: InputBorder.none,
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                      horizontal:
                                                          6, // Giảm từ 8 xuống 6
                                                      vertical:
                                                          3, // Giảm từ 4 xuống 3
                                                    ),
                                                fillColor: Theme.of(context)
                                                    .colorScheme
                                                    .surface
                                                    .withOpacity(0.7),
                                                filled: true,
                                                enabledBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ), // Giảm từ 6 xuống 4
                                                      borderSide: BorderSide(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .outline
                                                            .withOpacity(0.3),
                                                        width: 1,
                                                      ),
                                                    ),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            4,
                                                          ), // Giảm từ 6 xuống 4
                                                      borderSide: BorderSide(
                                                        color:
                                                            Theme.of(context)
                                                                .colorScheme
                                                                .primary,
                                                        width: 2,
                                                      ),
                                                    ),
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            width: 8,
                                          ), // Giảm từ 10 xuống 8
                                          // Delete button
                                          GestureDetector(
                                            onTap: () {
                                              setDialogState(() {
                                                subtasks.remove(entry.key);
                                              });
                                            },
                                            child: Container(
                                              width: 24, // Giảm từ 28 xuống 24
                                              height: 24, // Giảm từ 28 xuống 24
                                              decoration: BoxDecoration(
                                                color: Colors.red.withOpacity(
                                                  0.1,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      4,
                                                    ), // Giảm từ 6 xuống 4
                                                border: Border.all(
                                                  color: Colors.red.withOpacity(
                                                    0.3,
                                                  ),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Icon(
                                                Icons.delete_outline,
                                                color: Colors.red,
                                                size: 14, // Giảm từ 16 xuống 14
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                      ),
                    ),

                    // Action buttons
                    Container(
                      margin: EdgeInsets.only(top: 12), // Giảm từ 16 xuống 12
                      padding: EdgeInsets.only(top: 10), // Giảm từ 12 xuống 10
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.outline.withOpacity(0.2),
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        spacing: 10, // Giảm từ 12 xuống 10
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.surface,
                                foregroundColor:
                                    Theme.of(context).colorScheme.onSurface,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ), // Giảm từ 14 xuống 12
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Giảm từ 10 xuống 8
                                  side: BorderSide(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.outline.withOpacity(0.5),
                                    width: 1,
                                  ),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                'Hủy',
                                style: TextStyle(
                                  fontSize: 14, // Thêm font size nhỏ hơn
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () async {
                                await _saveTask(
                                  taskId: task?['id'],
                                  title: title,
                                  description: description,
                                  deadline: selectedDate,
                                  subtasks: subtasks,
                                  flag: selectedFlag, // Thêm flag vào tham số
                                );
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                                foregroundColor:
                                    Theme.of(
                                      context,
                                    ).colorScheme.onPrimaryContainer,
                                padding: EdgeInsets.symmetric(
                                  vertical: 12,
                                ), // Giảm từ 14 xuống 12
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                    8,
                                  ), // Giảm từ 10 xuống 8
                                ),
                                elevation: 2,
                              ),
                              child: Text(
                                task == null ? 'Tạo nhiệm vụ' : 'Cập nhật',
                                style: TextStyle(
                                  fontSize: 14, // Thêm font size nhỏ hơn
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Save task (create or update)
  Future<void> _saveTask({
    String? taskId,
    required String title,
    required String description,
    required DateTime deadline,
    required Map<int, String> subtasks,
    String flag = 'none', // Thêm tham số flag với giá trị mặc định
  }) async {
    try {
      // Convert subtasks to backend format
      List<Map<String, dynamic>> subtaskList =
          subtasks.entries
              .map(
                (e) => {
                  'title': e.value,
                  'status': 'pending', // Backend expects string status
                },
              )
              .toList();

      if (taskId == null) {
        // Create new task
        await TaskApi.createTask(
          projectId: widget.projectId,
          title: title,
          description: description,
          deadline: deadline,
          subtasks: subtaskList,
          flag: flag, // Thêm flag vào createTask
        );
      } else {
        // Update existing task
        await TaskApi.updateTask(
          taskId: taskId,
          title: title,
          description: description,
          deadline: deadline,
          subtasks: subtaskList,
          flag: flag, // Thêm flag vào updateTask
        );
      }

      // Reload tasks
      await _loadProjectTasks();
    } catch (e) {
      print('Error saving task: $e');
      // Show error dialog
      _showErrorDialog('Lỗi khi lưu nhiệm vụ: $e');
    }
  }

  // Delete task
  Future<void> _deleteTask(String taskId) async {
    try {
      await TaskApi.deleteTask(taskId);
      await _loadProjectTasks();
    } catch (e) {
      print('Error deleting task: $e');
      _showErrorDialog('Lỗi khi xóa nhiệm vụ: $e');
    }
  }

  String _formatTaskDate(String? dateString) {
    if (dateString == null || dateString.isEmpty || dateString == 'null') {
      return 'Không có thời hạn';
    }
    try {
      DateTime date = DateTime.parse(dateString);
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      print('Error parsing date: $dateString, error: $e');
      return 'Định dạng ngày không hợp lệ';
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Lỗi',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Text(
              message,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Đóng'),
              ),
            ],
          ),
    );
  }

  // Show assign task dialog
  void _showAssignTaskDialog(Map<String, dynamic> task) {
    if (teamInfo == null || teamInfo!['members'] == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không có thông tin thành viên nhóm'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Extract member data for the dialog
    List<Map<String, dynamic>> membersList = [];
    for (var member in teamInfo!['members']) {
      if (member != null && member['member'] is Map<String, dynamic>) {
        final memberData = member['member'] as Map<String, dynamic>;
        membersList.add({
          '_id': memberData['_id'],
          'name':
              memberData['displayName'] ??
              memberData['username'] ??
              'Unknown User',
          'email': memberData['email'] ?? '',
        });
      }
    }

    if (membersList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Không tìm thấy thành viên nhóm hợp lệ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AssignTaskDialog(
            task: task,
            teamMembers: membersList,
            onAssignmentChanged: () {
              // Refresh tasks list to show updated assignment
              _loadProjectTasks();
            },
          ),
    );
  }

  // Show update flag dialog - Hiển thị dialog cập nhật mức độ ưu tiên
  void _showUpdateFlagDialog(Map<String, dynamic> task) {
    String currentFlag = task['flag'] ?? 'none';
    String selectedFlag = currentFlag;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surface,
              title: Text(
                'Cập nhật mức độ ưu tiên',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Chọn mức độ ưu tiên cho nhiệm vụ: ${task['title']}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    width: double.maxFinite,
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color:
                          selectedFlag != 'none'
                              ? _getFlagColor(selectedFlag).withOpacity(0.15)
                              : Theme.of(
                                context,
                              ).colorScheme.primaryContainer.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            selectedFlag != 'none'
                                ? _getFlagColor(selectedFlag).withOpacity(0.4)
                                : Theme.of(
                                  context,
                                ).colorScheme.primaryContainer,
                        width: 1,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedFlag,
                        isExpanded: true,
                        style: TextStyle(
                          color:
                              selectedFlag != 'none'
                                  ? _getFlagColor(selectedFlag)
                                  : Theme.of(context).colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                        dropdownColor: Theme.of(context).colorScheme.surface,
                        items:
                            [
                              {'value': 'none', 'label': 'Không có'},
                              {'value': 'low', 'label': 'Thấp'},
                              {'value': 'medium', 'label': 'Trung bình'},
                              {'value': 'high', 'label': 'Cao'},
                              {'value': 'priority', 'label': 'Ưu tiên'},
                            ].map((flag) {
                              return DropdownMenuItem<String>(
                                value: flag['value'],
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        flag['value'] != 'none'
                                            ? _getFlagColor(
                                              flag['value']!,
                                            ).withOpacity(0.1)
                                            : Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color:
                                          flag['value'] != 'none'
                                              ? _getFlagColor(
                                                flag['value']!,
                                              ).withOpacity(0.3)
                                              : Colors.grey.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getFlagIcon(flag['value']!),
                                        color:
                                            flag['value'] != 'none'
                                                ? _getFlagColor(flag['value']!)
                                                : Colors.grey,
                                        size: 20,
                                      ),
                                      SizedBox(width: 12),
                                      Text(
                                        flag['label']!,
                                        style: TextStyle(
                                          color:
                                              flag['value'] != 'none'
                                                  ? _getFlagColor(
                                                    flag['value']!,
                                                  )
                                                  : Theme.of(
                                                    context,
                                                  ).colorScheme.inversePrimary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setDialogState(() {
                              selectedFlag = newValue;
                            });
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _updateTaskFlag(task['id'], selectedFlag);
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Text(
                    'Cập nhật',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Update task flag - Cập nhật mức độ ưu tiên nhiệm vụ
  Future<void> _updateTaskFlag(String taskId, String flag) async {
    try {
      await TaskApi.updateTaskFlag(taskId: taskId, flag: flag);
      await _loadProjectTasks(); // Reload tasks to show updated flag
    } catch (e) {
      print('Error updating task flag: $e');
      _showErrorDialog('Lỗi khi cập nhật mức độ ưu tiên: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(widget.projectName, style: titleText),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showProjectSettings,
          ),
        ],
        bottom: TabBar(
          labelColor: Theme.of(context).colorScheme.primaryContainer,
          unselectedLabelColor: Theme.of(context).colorScheme.outline,
          indicatorColor: Theme.of(context).colorScheme.primaryContainer,
          indicator: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).colorScheme.primaryContainer,
                width: 3.0,
              ),
            ),
          ),
          labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.task), text: 'Nhiệm vụ'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Tổng quan'),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [_buildTasksView(), _buildOverviewView()],
        ),
      ),
      floatingActionButton:
          _canManageTasks()
              ? FloatingActionButton(
                onPressed: _createTask,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Colors.white,
                child: Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildTasksView() {
    if (isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
      );
    }

    // Update custom event list to show task counts on calendar
    getCustomEventList();

    return RefreshIndicator(
      onRefresh: _refreshTasks,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Calendar widget (similar to home_tab.dart)
          TableCalendar(
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            firstDay: DateTime(2024),
            lastDay: DateTime(2500),
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: ('vi_VN'),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  dayToViewTask = convertToDefaultDate(selectedDay);
                  readTasksOnSpecificDate(dayToViewTask);
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },
            onHeaderTapped: (focusedDay) {
              setState(() {
                focusedDay = DateTime.now();
                dayToViewTask = convertToDefaultDate(focusedDay);
                readTasksOnSpecificDate(dayToViewTask);
                _selectedDay = focusedDay;
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: normalText,
            ),
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              rowDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              weekendTextStyle: TextStyle(color: const Color(0xFFFF2626)),
            ),
            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              weekendStyle: TextStyle(color: const Color(0xFFFF2626)),
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            daysOfWeekHeight: 20,
            rowHeight: 70,
            eventLoader: (day) => _getEventForDay(day),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return SizedBox();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfe8430),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        events.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          // Task status filter
          _buildTaskStatusFilter(),

          // All tasks section (not date-dependent)
          Expanded(
            child:
                _filteredTasks.isEmpty
                    ? _buildEmptyTasksView()
                    : ListView.builder(
                      padding: EdgeInsets.only(bottom: 80),
                      itemCount: _filteredTasks.length,
                      itemBuilder: (context, index) {
                        final task = _filteredTasks[index];
                        return _buildTaskItem(task);
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTasksView() {
    String message;
    String subMessage;
    IconData icon;

    if (_filterBySelectedDate && _selectedDay != null) {
      // Messages when filtering by date
      String dateStr = DateFormat('dd/MM/yyyy').format(_selectedDay!);
      switch (_taskStatusFilter) {
        case 'created':
          message = 'Không có nhiệm vụ được tạo';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.fiber_new;
          break;
        case 'assigned':
          message = 'Không có nhiệm vụ đã gán';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.assignment_ind;
          break;
        case 'pending':
          message = 'Không có nhiệm vụ đang thực hiện';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.pending_actions;
          break;
        case 'in_review':
          message = 'Không có nhiệm vụ chờ duyệt';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.rate_review;
          break;
        case 'completed':
          message = 'Không có nhiệm vụ đã hoàn thành';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.check_circle_outline;
          break;
        case 'closed':
          message = 'Không có nhiệm vụ đã đóng';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.lock;
          break;
        default:
          message = 'Không có nhiệm vụ nào';
          subMessage = 'trong ngày $dateStr';
          icon = Icons.calendar_today;
          break;
      }
    } else {
      // Messages when not filtering by date
      switch (_taskStatusFilter) {
        case 'created':
          message = 'Không có nhiệm vụ được tạo';
          subMessage = 'Tạo nhiệm vụ mới để bắt đầu';
          icon = Icons.fiber_new;
          break;
        case 'assigned':
          message = 'Không có nhiệm vụ đã gán';
          subMessage = 'Gán nhiệm vụ cho thành viên';
          icon = Icons.assignment_ind;
          break;
        case 'pending':
          message = 'Không có nhiệm vụ đang thực hiện';
          subMessage = 'Bắt đầu thực hiện một số nhiệm vụ';
          icon = Icons.pending_actions;
          break;
        case 'in_review':
          message = 'Không có nhiệm vụ chờ duyệt';
          subMessage = 'Chưa có nhiệm vụ nào đang chờ duyệt';
          icon = Icons.rate_review;
          break;
        case 'completed':
          message = 'Không có nhiệm vụ đã hoàn thành';
          subMessage = 'Hoàn thành một số nhiệm vụ để xem ở đây';
          icon = Icons.check_circle_outline;
          break;
        case 'closed':
          message = 'Không có nhiệm vụ đã đóng';
          subMessage = 'Chưa có nhiệm vụ nào được đóng';
          icon = Icons.lock;
          break;
        default:
          message = 'Chưa có nhiệm vụ nào';
          subMessage = 'Tạo nhiệm vụ mới để bắt đầu';
          icon = Icons.task_outlined;
          break;
      }
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: Theme.of(context).colorScheme.outline),
          SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).colorScheme.outline,
            ),
            textAlign: TextAlign.center,
          ),
          if (_canManageTasks()) ...[
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _createTask,
              icon: Icon(Icons.add),
              label: Text('Tạo nhiệm vụ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildOverviewView() {
    return TaskStatisticsWidget(projectId: widget.projectId);
  }

  Widget _buildTaskItem(Map<String, dynamic> task) {
    bool isCompleted = task['status'] == 2;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Theme.of(context).colorScheme.surface,
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task title and basic info
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                        isCompleted
                            ? Colors.green
                            : Theme.of(context).colorScheme.primaryContainer,
                  ),
                  child: Icon(
                    isCompleted ? Icons.check : Icons.task,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              task['title'] ?? 'Untitled Task',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 16,
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                decoration:
                                    isCompleted
                                        ? TextDecoration.lineThrough
                                        : null,
                              ),
                            ),
                          ),
                          // Hiển thị chip flag nhỏ bên cạnh tiêu đề
                          if (task['flag'] != null && task['flag'] != 'none')
                            Container(
                              margin: EdgeInsets.only(left: 8),
                              padding: EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getFlagColor(
                                  task['flag'],
                                ).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: _getFlagColor(
                                    task['flag'],
                                  ).withOpacity(0.4),
                                  width: 0.5,
                                ),
                              ),
                              child: Icon(
                                _getFlagIcon(task['flag']),
                                size: 12,
                                color: _getFlagColor(task['flag']),
                              ),
                            ),
                        ],
                      ),
                      if (task['description'] != null &&
                          task['description'].isNotEmpty) ...[
                        SizedBox(height: 4),
                        Text(
                          task['description'],
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.outline,
                            fontSize: 14,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (task['deadline'] != null) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.schedule,
                              size: 14,
                              color: Theme.of(context).colorScheme.outline,
                            ),
                            SizedBox(width: 4),
                            Text(
                              _formatTaskDate(task['deadline']),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.outline,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (task['assignee'] != null &&
                          task['assignee'] is Map) ...[
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 14,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Được gán cho: ${task['assignee']['displayName'] ?? task['assignee']['username'] ?? 'Unknown'}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                      // Hiển thị flag (mức độ ưu tiên) dưới dạng chip
                      if (task['flag'] != null && task['flag'] != 'none') ...[
                        SizedBox(height: 6),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getFlagColor(
                              task['flag'],
                            ).withOpacity(0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: _getFlagColor(
                                task['flag'],
                              ).withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getFlagIcon(task['flag']),
                                size: 12,
                                color: _getFlagColor(task['flag']),
                              ),
                              SizedBox(width: 4),
                              Text(
                                _getFlagDisplayName(task['flag']),
                                style: TextStyle(
                                  color: _getFlagColor(task['flag']),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (_canManageTasks())
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        _editTask(task);
                      } else if (value == 'delete') {
                        _deleteTask(task['id']);
                      } else if (value == 'assign') {
                        _showAssignTaskDialog(task);
                      } else if (value == 'flag') {
                        _showUpdateFlagDialog(task);
                      }
                    },
                    itemBuilder:
                        (context) => [
                          PopupMenuItem(
                            value: 'assign',
                            child: Row(
                              children: [
                                Icon(Icons.assignment_ind, color: Colors.green),
                                SizedBox(width: 8),
                                Text('Gán thành viên'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'flag',
                            child: Row(
                              children: [
                                Icon(Icons.flag, color: Colors.orange),
                                SizedBox(width: 8),
                                Text('Cập nhật ưu tiên'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit, color: Colors.blue),
                                SizedBox(width: 8),
                                Text('Chỉnh sửa'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete, color: Colors.red),
                                SizedBox(width: 8),
                                Text('Xóa'),
                              ],
                            ),
                          ),
                        ],
                  ),
              ],
            ),
            SizedBox(height: 12),

            // Status button and actions row - made responsive
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row: Status button and Take Task button
                Row(
                  children: [
                    Expanded(
                      child: TaskStatusButton(
                        task: task,
                        onStatusChanged: _updateTaskStatus,
                        userRole: currentUserRole,
                        currentUserId: currentUserId,
                        isEnabled: true,
                      ),
                    ),
                    // Show "Take Task" button for unassigned tasks if user is a member
                    if (task['assignee'] == null &&
                        task['statusString'] ==
                            'created' && // Use statusString instead of status
                        currentUserRole == 'member') ...[
                      SizedBox(width: 8),
                      Flexible(
                        child: ElevatedButton.icon(
                          onPressed: () => _takeTask(task),
                          icon: Icon(Icons.person_add, size: 16),
                          label: Text('Nhận', style: TextStyle(fontSize: 12)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 8),
                // Second row: View details button
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: () => _viewTaskDetails(task),
                      icon: Icon(
                        Icons.visibility,
                        size: 16,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      label: Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          fontSize: 12,
                          fontWeight: FontWeight.w600, // Đậm hơn để dễ nhìn
                        ),
                      ),
                      style: TextButton.styleFrom(
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.primaryContainer.withOpacity(0.1),
                        padding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Task action methods
  Future<void> _editTask(Map<String, dynamic> task) async {
    await _showTaskDialog(task: task);
  }

  Future<void> _updateTaskStatus(
    Map<String, dynamic> task,
    String newStatus,
  ) async {
    try {
      // Debug: Print task data
      print('Update task status for: ${task['title']}');
      print('Task ID: ${task['id']}');
      print('Current status: ${task['status']}');
      print('New status: $newStatus');

      // Validate task ID
      final taskId = task['id']?.toString();
      if (taskId == null || taskId.isEmpty) {
        throw Exception('Task ID is null or empty');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang cập nhật trạng thái...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Call the new update status API
      final result = await TaskApi.updateTaskStatus(
        taskId: taskId,
        newStatus: newStatus,
        projectId: widget.projectId,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Debug: Print API response
      print('Update API response: $result');

      // Validate API response
      if (result['task'] == null) {
        throw Exception('Invalid API response: missing task data');
      }

      // Update local task data
      setState(() {
        task['status'] = _convertStatusToInt(
          result['task']['status']?.toString(),
        );
        task['statusString'] =
            result['task']['status']?.toString() ?? newStatus;
        if (result['task']['closeTime'] != null) {
          task['closeTime'] = result['task']['closeTime'];
        } else {
          task.remove('closeTime');
        }
        // Update calendar markers since task status might affect visibility
        getCustomEventList();
      });

      // Show success message
      String statusText = _getStatusText(newStatus);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text('Trạng thái đã được cập nhật thành "$statusText"'),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Error updating task status: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Lỗi cập nhật trạng thái: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'created':
        return 'Được tạo';
      case 'assigned':
        return 'Đã gán';
      case 'pending':
        return 'Đang thực hiện';
      case 'in_review':
        return 'Chờ duyệt';
      case 'completed':
        return 'Hoàn thành';
      case 'closed':
        return 'Đã đóng';
      default:
        return 'Không xác định';
    }
  }

  Future<void> _takeTask(Map<String, dynamic> task) async {
    try {
      // Debug: Print task data
      print('Take task: ${task['title']}');
      print('Task ID: ${task['id']}');

      // Validate task ID
      final taskId = task['id']?.toString();
      if (taskId == null || taskId.isEmpty) {
        throw Exception('Task ID is null or empty');
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (context) => Center(
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Đang nhận nhiệm vụ...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Call the take task API
      final result = await TaskApi.takeTask(
        taskId: taskId,
        projectId: widget.projectId,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      // Update local task data
      setState(() {
        task['assignee'] = result['task']['assignee'];
        task['status'] = _convertStatusToInt(
          result['task']['status']?.toString(),
        );
        task['statusString'] =
            result['task']['status']?.toString() ?? 'assigned';
        // Update calendar markers
        getCustomEventList();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Đã nhận nhiệm vụ thành công')),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      print('Error taking task: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(child: Text('Lỗi nhận nhiệm vụ: ${e.toString()}')),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  void _viewTaskDetails(Map<String, dynamic> task) async {
    try {
      // Lấy chi tiết task kèm logs từ API
      final taskId = task['_id']?.toString() ?? task['id']?.toString();
      if (taskId == null || taskId.isEmpty) {
        throw Exception('Task ID not found');
      }

      final taskDetails = await TaskApi.getTaskDetailsWithLogs(taskId);

      if (!mounted) return;

      showDialog(
        context: context,
        builder:
            (context) => Dialog(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.8,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    // Header với tiêu đề và nút đóng
                    Container(
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.task_alt, color: Colors.white, size: 24),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              taskDetails['title']?.toString() ??
                                  'Chi tiết nhiệm vụ',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: Icon(Icons.close, color: Colors.white),
                          ),
                        ],
                      ),
                    ),

                    // Nội dung chi tiết
                    Expanded(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Thông tin cơ bản
                            _buildInfoSection(
                              context,
                              title: 'Thông tin cơ bản',
                              children: [
                                // ID nhiệm vụ
                                _buildInfoRow(
                                  context,
                                  label: 'ID nhiệm vụ',
                                  value: taskId,
                                  icon: Icons.fingerprint,
                                ),

                                // Mô tả
                                if (taskDetails['description'] != null &&
                                    taskDetails['description']
                                        .toString()
                                        .isNotEmpty)
                                  _buildInfoRow(
                                    context,
                                    label: 'Mô tả',
                                    value:
                                        taskDetails['description'].toString(),
                                    icon: Icons.description,
                                    isMultiLine: true,
                                  ),

                                // Ngày tạo
                                if (taskDetails['createdAt'] != null)
                                  _buildInfoRow(
                                    context,
                                    label: 'Ngày tạo',
                                    value: _formatTaskDate(
                                      taskDetails['createdAt'].toString(),
                                    ),
                                    icon: Icons.access_time,
                                  ),

                                // Người tạo
                                if (taskDetails['createdBy'] != null)
                                  _buildInfoRow(
                                    context,
                                    label: 'Người tạo',
                                    value: _getCreatorName(
                                      taskDetails['createdBy'],
                                    ),
                                    icon: Icons.person_add,
                                  ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Trạng thái và Ưu tiên
                            _buildInfoSection(
                              context,
                              title: 'Trạng thái & Ưu tiên',
                              children: [
                                // Trạng thái hiện tại - Highlighted
                                _buildHighlightedInfo(
                                  context,
                                  label: 'Trạng thái',
                                  value: _getVietnameseStatus(
                                    taskDetails['status']?.toString() ??
                                        'created',
                                  ),
                                  color: _getStatusColor(
                                    taskDetails['status']?.toString() ??
                                        'created',
                                  ),
                                  icon: Icons.flag_circle,
                                ),

                                // Mức độ ưu tiên - Chip style
                                if (taskDetails['flag'] != null &&
                                    taskDetails['flag'].toString() != 'none' &&
                                    taskDetails['flag'].toString().isNotEmpty)
                                  _buildHighlightedInfo(
                                    context,
                                    label: 'Mức độ ưu tiên',
                                    value: _getVietnameseFlag(
                                      taskDetails['flag'].toString(),
                                    ),
                                    color: _getFlagColor(
                                      taskDetails['flag'].toString(),
                                    ),
                                    icon: _getFlagIcon(
                                      taskDetails['flag'].toString(),
                                    ),
                                  ),
                              ],
                            ),

                            SizedBox(height: 20),

                            // Thời hạn - Highlighted
                            if (taskDetails['deadline'] != null)
                              _buildInfoSection(
                                context,
                                title: 'Thời hạn',
                                children: [
                                  _buildDeadlineInfo(
                                    context,
                                    deadline:
                                        taskDetails['deadline'].toString(),
                                  ),
                                ],
                              ),

                            SizedBox(height: 20),

                            // Phân công
                            if (taskDetails['assignee'] != null)
                              _buildInfoSection(
                                context,
                                title: 'Phân công',
                                children: [
                                  _buildInfoRow(
                                    context,
                                    label: 'Được giao cho',
                                    value: _getAssigneeName(
                                      taskDetails['assignee'],
                                    ),
                                    icon: Icons.assignment_ind,
                                  ),
                                ],
                              ),

                            SizedBox(height: 20),

                            // Nhiệm vụ con
                            if (taskDetails['subtasks'] != null &&
                                taskDetails['subtasks'] is List &&
                                (taskDetails['subtasks'] as List).isNotEmpty)
                              _buildInfoSection(
                                context,
                                title:
                                    'Nhiệm vụ con (${(taskDetails['subtasks'] as List).length})',
                                children: [
                                  _buildSubtasksList(
                                    context,
                                    taskDetails['subtasks'] as List,
                                  ),
                                ],
                              ),

                            SizedBox(height: 20),

                            // Lịch sử thay đổi
                            _buildInfoSection(
                              context,
                              title: 'Lịch sử thay đổi',
                              children: [
                                _buildLogsList(context, taskDetails['logs']),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );
    } catch (e) {
      if (!mounted) return;

      print('Error in _viewTaskDetails: $e');

      // Hiển thị dialog lỗi
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: Text(
                'Lỗi',
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              content: Text('Không thể tải chi tiết nhiệm vụ: ${e.toString()}'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Đóng'),
                ),
              ],
            ),
      );
    }
  }

  // Helper methods similar to home_tab.dart
  DateTime convertToDefaultDate(DateTime dayToConvert) {
    DateTime tempReturnDate = DateTime(
      dayToConvert.year,
      dayToConvert.month,
      dayToConvert.day,
    );
    String tempConvert = tempReturnDate.toString();
    tempConvert += 'Z';
    DateTime returnDate = DateTime.parse(tempConvert);
    return returnDate;
  }

  void getCustomEventList() {
    List<DateTime> datesContainTask = [];
    // Always use projectTasks (all tasks) for calendar markers, not filtered tasks
    for (var task in projectTasks) {
      if (task['deadline'] != null) {
        try {
          DateTime checkDate = convertToDefaultDate(
            DateTime.parse(task['deadline']),
          );
          if (!datesContainTask.contains(checkDate)) {
            datesContainTask.add(checkDate);
          }
        } catch (e) {
          print(
            'Error parsing deadline in getCustomEventList: ${e.toString()}',
          );
        }
      }
    }

    Map<DateTime, List<String>> tempMap = {};
    for (var date in datesContainTask) {
      List<String> taskHolder = [];
      for (var task in projectTasks) {
        if (task['deadline'] != null) {
          try {
            DateTime taskDate = DateTime.parse(task['deadline']);
            if (date.year == taskDate.year &&
                date.month == taskDate.month &&
                date.day == taskDate.day) {
              final taskIdStr = task['id']?.toString();
              if (taskIdStr != null && !taskHolder.contains(taskIdStr)) {
                taskHolder.add(taskIdStr);
              }
            }
          } catch (e) {
            print('Error parsing task deadline: ${e.toString()}');
          }
        }
      }
      final event = <DateTime, List<String>>{date: taskHolder};
      tempMap.addEntries(event.entries);
    }
    customEventList = tempMap;
  }

  List<String> _getEventForDay(DateTime day) {
    return customEventList[day] ?? [];
  }

  void readTasksOnSpecificDate(DateTime inputDate) {
    setState(() {
      _filterBySelectedDate = true;
      // No need to update calendar markers - they should always show all tasks
    });
  }

  // Placeholder methods for future functionality
  void _showProjectSettings() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Cài đặt dự án - Sắp ra mắt'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _refreshTasks() async {
    // TODO: Implement task refresh
    _loadProjectTasks(); // Reload project tasks
    await Future.delayed(Duration(seconds: 1));
  }

  // Custom DateTimePicker (similar to floating_add_button.dart)
  Future<DateTime?> _customDateTimePicker({
    required BuildContext context,
    DateTime? initialDate,
    DateTime? firstDate,
    DateTime? lastDate,
  }) async {
    initialDate ??= DateTime.now();
    firstDate ??= initialDate.subtract(const Duration(days: 365 * 100));
    lastDate ??= firstDate.add(const Duration(days: 365 * 200));

    final DateTime? selectedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: Locale('vi'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff007AFF),
              onPrimary: Color(0xFFFFFFFF),
              onSurface: Color(0xff000000),
            ),
          ),
          child: child!,
        );
      },
    );

    if (selectedDate == null) return null;
    if (!context.mounted) return selectedDate;

    final TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initialDate),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xff007AFF),
              onPrimary: Color(0xFFFFFFFF),
              onSurface: Color(0xff000000),
              secondary: Color(0xff007AFF),
              onSecondary: Color(0xFFFFFFFF),
            ),
          ),
          child: child!,
        );
      },
    );

    return selectedTime == null
        ? selectedDate
        : DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        );
  }

  // Helper function to get flag priority order for sorting - Sắp xếp theo mức độ ưu tiên
  int _getFlagPriority(String flag) {
    switch (flag.toLowerCase()) {
      case 'priority':
        return 5; // Ưu tiên cao nhất
      case 'high':
        return 4;
      case 'medium':
        return 3;
      case 'low':
        return 2;
      case 'none':
      default:
        return 1; // Ưu tiên thấp nhất
    }
  }

  // Helper methods for building task details UI
  Widget _buildInfoSection(
    BuildContext context, {
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                size: 20,
                color: Theme.of(context).colorScheme.onSurface,
              ),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    bool isMultiLine = false,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            isMultiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 2),
                isMultiLine
                    ? Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    )
                    : Text(
                      value,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedInfo(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                SizedBox(height: 4),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(icon, size: 14, color: Colors.white),
                      SizedBox(width: 6),
                      Text(
                        value,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeadlineInfo(BuildContext context, {required String deadline}) {
    final DateTime deadlineDate;
    final bool isOverdue;
    final bool isToday;
    final bool isTomorrow;

    try {
      deadlineDate = DateTime.parse(deadline);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));
      final deadlineDay = DateTime(
        deadlineDate.year,
        deadlineDate.month,
        deadlineDate.day,
      );

      isOverdue = deadlineDay.isBefore(today);
      isToday = deadlineDay.isAtSameMomentAs(today);
      isTomorrow = deadlineDay.isAtSameMomentAs(tomorrow);
    } catch (e) {
      return _buildInfoRow(
        context,
        label: 'Thời hạn',
        value: 'Định dạng ngày không hợp lệ',
        icon: Icons.error,
      );
    }

    Color deadlineColor = Theme.of(context).colorScheme.primary;
    String deadlineLabel = 'Thời hạn';
    IconData deadlineIcon = Icons.schedule;

    if (isOverdue) {
      deadlineColor = Colors.red;
      deadlineLabel = 'Quá hạn';
      deadlineIcon = Icons.warning;
    } else if (isToday) {
      deadlineColor = Colors.orange;
      deadlineLabel = 'Hết hạn hôm nay';
      deadlineIcon = Icons.today;
    } else if (isTomorrow) {
      deadlineColor = Colors.amber;
      deadlineLabel = 'Hết hạn ngày mai';
      deadlineIcon = Icons.event;
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: deadlineColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: deadlineColor.withOpacity(0.3), width: 2),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: deadlineColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(deadlineIcon, color: Colors.white, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deadlineLabel,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: deadlineColor,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  _formatTaskDate(deadline),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtasksList(BuildContext context, List subtasks) {
    return Column(
      children:
          subtasks
              .where((subtask) => subtask != null)
              .map(
                (subtask) => Container(
                  margin: EdgeInsets.only(bottom: 8),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.subdirectory_arrow_right,
                        size: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          (subtask is Map<String, dynamic>
                                  ? subtask['title']?.toString()
                                  : subtask?.toString()) ??
                              'Nhiệm vụ con',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
    );
  }

  Widget _buildLogsList(BuildContext context, dynamic logs) {
    if (logs == null || (logs is List && logs.isEmpty)) {
      return Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(
              Icons.history,
              color: Theme.of(context).colorScheme.outline,
              size: 20,
            ),
            SizedBox(width: 8),
            Text(
              'Chưa có lịch sử thay đổi',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      );
    }

    if (logs is! List) return Container();

    final validLogs =
        logs
            .where((log) => log != null && log is Map<String, dynamic>)
            .cast<Map<String, dynamic>>()
            .toList()
            .reversed
            .toList();

    return Container(
      constraints: BoxConstraints(maxHeight: 250),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.all(8),
        child: Column(
          children:
              validLogs
                  .map((log) => _buildDetailedLogItem(context, log))
                  .toList(),
        ),
      ),
    );
  }

  Widget _buildDetailedLogItem(BuildContext context, Map<String, dynamic> log) {
    DateTime timestamp;
    try {
      final timestampValue = log['timestamp'];
      if (timestampValue is int) {
        timestamp = DateTime.fromMillisecondsSinceEpoch(timestampValue);
      } else if (timestampValue is String) {
        timestamp = DateTime.parse(timestampValue);
      } else {
        timestamp = DateTime.now();
      }
    } catch (e) {
      timestamp = DateTime.now();
    }

    final String action = log['action']?.toString() ?? '';
    final String details = log['details']?.toString() ?? '';
    final Color actionColor =
        action.isNotEmpty ? _getStatusColor(action) : Colors.grey;

    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: actionColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: actionColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getActionIcon(action), size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      action.isNotEmpty
                          ? _getVietnameseStatus(action)
                          : 'Không xác định',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(),
              Text(
                DateFormat('dd/MM HH:mm').format(timestamp),
                style: TextStyle(
                  fontSize: 11,
                  color: Theme.of(context).colorScheme.outline,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          if (details.isNotEmpty) ...[
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                details,
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  IconData _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'created':
        return Icons.add_circle;
      case 'assigned':
        return Icons.assignment_ind;
      case 'pending':
        return Icons.play_arrow;
      case 'in_review':
        return Icons.rate_review;
      case 'completed':
        return Icons.check_circle;
      case 'closed':
        return Icons.lock;
      default:
        return Icons.circle;
    }
  }

  String _getCreatorName(dynamic creator) {
    if (creator == null) return 'Không xác định';

    if (creator is String) return creator;

    if (creator is Map<String, dynamic>) {
      return creator['displayName']?.toString() ??
          creator['username']?.toString() ??
          creator['name']?.toString() ??
          'Không xác định';
    }

    return creator.toString();
  }

  String _getAssigneeName(dynamic assignee) {
    if (assignee == null) return 'Chưa phân công';

    if (assignee is String) return assignee;

    if (assignee is Map<String, dynamic>) {
      return assignee['displayName']?.toString() ??
          assignee['username']?.toString() ??
          assignee['name']?.toString() ??
          'Không xác định';
    }

    return assignee.toString();
  }
}
