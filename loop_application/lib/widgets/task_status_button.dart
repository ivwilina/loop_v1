import 'package:flutter/material.dart';

class TaskStatusButton extends StatefulWidget {
  final Map<String, dynamic> task;
  final Function(Map<String, dynamic>, String) onStatusChanged;
  final String userRole;
  final String? currentUserId;
  final bool isEnabled;

  const TaskStatusButton({
    Key? key,
    required this.task,
    required this.onStatusChanged,
    required this.userRole,
    this.currentUserId,
    this.isEnabled = true,
  }) : super(key: key);

  @override
  State<TaskStatusButton> createState() => _TaskStatusButtonState();
}

class _TaskStatusButtonState extends State<TaskStatusButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Convert int status to string status
  String get _currentStatus {
    // Use statusString if available, otherwise convert from int
    if (widget.task['statusString'] != null) {
      return widget.task['statusString'];
    }

    // Fallback to conversion from int
    switch (widget.task['status']) {
      case 0:
        return 'created';
      case 1:
        return 'assigned';
      case 2:
        return 'pending';
      case 3:
        return 'in_review';
      case 4:
        return 'completed';
      case 5:
        return 'closed';
      default:
        return 'pending';
    }
  }

  // Get possible next statuses based on current status and user role
  List<String> get _possibleNextStatuses {
    final allowedTransitions = {
      'member': {
        'assigned': ['pending'],
        'pending': ['in_review'],
      },
      'admin': {
        'created': ['assigned', 'pending', 'in_review', 'completed', 'closed'],
        'assigned': ['pending', 'in_review', 'completed', 'closed'],
        'pending': ['assigned', 'in_review', 'completed', 'closed'],
        'in_review': ['pending', 'completed', 'closed'],
        'completed': ['in_review', 'closed'],
        'closed': ['completed'],
      },
      'owner': {
        'created': ['assigned', 'pending', 'in_review', 'completed', 'closed'],
        'assigned': ['pending', 'in_review', 'completed', 'closed'],
        'pending': ['assigned', 'in_review', 'completed', 'closed'],
        'in_review': ['pending', 'completed', 'closed'],
        'completed': ['in_review', 'closed'],
        'closed': ['completed'],
      },
    };

    final roleTransitions =
        allowedTransitions[widget.userRole] ?? allowedTransitions['member']!;
    return roleTransitions[_currentStatus] ?? [];
  }

  // Check if user can update this task
  bool get _canUpdateTask {
    if (!widget.isEnabled) return false;

    // Admins and owners can update any task
    if (widget.userRole == 'admin' || widget.userRole == 'owner') {
      return true;
    }

    // Members can only update tasks assigned to them
    if (widget.userRole == 'member') {
      final assignee = widget.task['assignee'];
      if (assignee is Map<String, dynamic>) {
        return assignee['_id'] == widget.currentUserId;
      }
      return assignee?.toString() == widget.currentUserId;
    }

    return false;
  }

  Color _getStatusColor(String status) {
    switch (status) {
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
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'created':
        return Icons.add_circle_outline;
      case 'assigned':
        return Icons.person_outline;
      case 'pending':
        return Icons.hourglass_empty;
      case 'in_review':
        return Icons.rate_review_outlined;
      case 'completed':
        return Icons.check_circle;
      case 'closed':
        return Icons.close_outlined;
      default:
        return Icons.help_outline;
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

  @override
  Widget build(BuildContext context) {
    final currentStatusColor = _getStatusColor(_currentStatus);
    final currentStatusIcon = _getStatusIcon(_currentStatus);
    final currentStatusText = _getStatusText(_currentStatus);
    final canUpdate = _canUpdateTask;
    final nextStatuses = _possibleNextStatuses;

    // Debug logging
    print('TaskStatusButton build:');
    print('- Task: ${widget.task['title']}');
    print('- Current status (int): ${widget.task['status']}');
    print('- Current status (string): ${widget.task['statusString']}');
    print('- Computed current status: $_currentStatus');
    print('- User role: ${widget.userRole}');
    print('- Can update: $canUpdate');
    print('- Possible next statuses: $nextStatuses');

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              color: currentStatusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: currentStatusColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap:
                    canUpdate && !_isLoading && nextStatuses.isNotEmpty
                        ? _showStatusMenu
                        : null,
                onTapDown: (_) => _animationController.forward(),
                onTapUp: (_) => _animationController.reverse(),
                onTapCancel: () => _animationController.reverse(),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isLoading)
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              currentStatusColor,
                            ),
                          ),
                        )
                      else
                        Icon(
                          currentStatusIcon,
                          color: currentStatusColor,
                          size: 20,
                        ),
                      SizedBox(width: 8),
                      Text(
                        currentStatusText,
                        style: TextStyle(
                          color: currentStatusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      if (canUpdate && nextStatuses.isNotEmpty) ...[
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_drop_down,
                          color: currentStatusColor,
                          size: 16,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _showStatusMenu() async {
    if (!_canUpdateTask || _isLoading) return;

    final nextStatuses = _possibleNextStatuses;
    if (nextStatuses.isEmpty) return;

    final String? selectedStatus = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Chọn trạng thái mới',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhiệm vụ: ${widget.task['title'] ?? 'Không có tên'}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 16),
                ...nextStatuses
                    .map(
                      (status) => ListTile(
                        leading: Icon(
                          _getStatusIcon(status),
                          color: _getStatusColor(status),
                        ),
                        title: Text(
                          _getStatusText(status),
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.inversePrimary,
                          ),
                        ),
                        onTap: () => Navigator.of(context).pop(status),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  'Hủy',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
              ),
            ],
          ),
    );

    if (selectedStatus != null && selectedStatus != _currentStatus) {
      await _handleStatusChange(selectedStatus);
    } else if (selectedStatus == _currentStatus) {
      // Show info message that no change is needed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Trạng thái đã là "$selectedStatus" rồi'),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _handleStatusChange(String newStatus) async {
    if (!_canUpdateTask || _isLoading) return;

    // Show confirmation dialog for important status changes
    final bool shouldProceed = await _showConfirmationDialog(newStatus);
    if (!shouldProceed) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.onStatusChanged(widget.task, newStatus);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<bool> _showConfirmationDialog(String newStatus) async {
    final newStatusColor = _getStatusColor(newStatus);
    final newStatusText = _getStatusText(newStatus);

    return await showDialog<bool>(
          context: context,
          builder:
              (context) => AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: Text(
                  'Xác nhận thay đổi',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Bạn có chắc chắn muốn chuyển trạng thái thành "$newStatusText"?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),
                    ),
                    SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: newStatusColor.withOpacity(0.1),
                        border: Border.all(
                          color: newStatusColor.withOpacity(0.3),
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusIcon(newStatus),
                            color: newStatusColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Nhiệm vụ: ${widget.task['title'] ?? 'Không có tên'}',
                              style: TextStyle(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.inversePrimary,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text(
                      'Hủy',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: newStatusColor,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('Xác nhận'),
                  ),
                ],
              ),
        ) ??
        false;
  }
}
