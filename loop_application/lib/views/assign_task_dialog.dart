import 'package:flutter/material.dart';
import 'package:loop_application/apis/task_api.dart';

class AssignTaskDialog extends StatefulWidget {
  final Map<String, dynamic> task;
  final List<Map<String, dynamic>> teamMembers;
  final VoidCallback onAssignmentChanged;

  const AssignTaskDialog({
    Key? key,
    required this.task,
    required this.teamMembers,
    required this.onAssignmentChanged,
  }) : super(key: key);

  @override
  State<AssignTaskDialog> createState() => _AssignTaskDialogState();
}

class _AssignTaskDialogState extends State<AssignTaskDialog> {
  String? selectedMemberId;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If task already has an assignee, select them
    if (widget.task['assignee'] != null && widget.task['assignee'] is Map) {
      selectedMemberId = widget.task['assignee']['_id'];
    }
  }

  Future<void> _assignTask() async {
    if (selectedMemberId == null) return;

    setState(() {
      isLoading = true;
    });

    try {
      await TaskApi.assignTaskToMember(widget.task['id'], selectedMemberId!);
      widget.onAssignmentChanged();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nhiệm vụ đã được gán thành công'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi gán nhiệm vụ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _unassignTask() async {
    setState(() {
      isLoading = true;
    });

    try {
      await TaskApi.unassignTask(widget.task['id']);
      widget.onAssignmentChanged();

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã hủy gán nhiệm vụ'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi hủy gán nhiệm vụ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Gán nhiệm vụ',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      content: Container(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Nhiệm vụ: ${widget.task['title']}',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Chọn thành viên:',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: 200,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: widget.teamMembers.length,
                itemBuilder: (context, index) {
                  final member = widget.teamMembers[index];
                  final isSelected = selectedMemberId == member['_id'];

                  return ListTile(
                    leading: CircleAvatar(
                      child: Text(
                        member['name'][0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      member['name'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    subtitle: Text(
                      member['email'],
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.outline,
                        fontSize: 12,
                      ),
                    ),
                    trailing: Radio<String>(
                      value: member['_id'],
                      groupValue: selectedMemberId,
                      onChanged: (value) {
                        setState(() {
                          selectedMemberId = value;
                        });
                      },
                    ),
                    tileColor:
                        isSelected
                            ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.3)
                            : null,
                    onTap: () {
                      setState(() {
                        selectedMemberId = member['_id'];
                      });
                    },
                  );
                },
              ),
            ),
            SizedBox(height: 16),
            // Show current assignee if any
            if (widget.task['assignee'] != null &&
                widget.task['assignee'] is Map)
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person,
                      size: 16,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Hiện tại: ${widget.task['assignee']['displayName'] ?? widget.task['assignee']['username'] ?? 'Unknown'}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      actions: [
        // Unassign button (only show if task is currently assigned)
        if (widget.task['assignee'] != null)
          TextButton(
            onPressed: isLoading ? null : _unassignTask,
            child: Text('Hủy gán', style: TextStyle(color: Colors.orange)),
          ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            'Hủy',
            style: TextStyle(color: Theme.of(context).colorScheme.outline),
          ),
        ),
        ElevatedButton(
          onPressed:
              (isLoading || selectedMemberId == null) ? null : _assignTask,
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          child:
              isLoading
                  ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                  : Text('Gán nhiệm vụ'),
        ),
      ],
    );
  }
}
