import 'package:flutter/material.dart';
import 'package:loop_application/apis/project_api.dart';

class AssignMembersDialog extends StatefulWidget {
  final Map<String, dynamic> project;
  final List<dynamic> teamMembers;
  final String teamId;
  final VoidCallback onAssignComplete;

  const AssignMembersDialog({
    Key? key,
    required this.project,
    required this.teamMembers,
    required this.teamId,
    required this.onAssignComplete,
  }) : super(key: key);

  @override
  State<AssignMembersDialog> createState() => _AssignMembersDialogState();
}

class _AssignMembersDialogState extends State<AssignMembersDialog> {
  List<String> selectedMemberIds = [];
  List<String> currentlyAssignedIds = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeAssignedMembers();
  }

  void _initializeAssignedMembers() {
    // Initialize currently assigned members
    if (widget.project['assignedMembers'] != null) {
      currentlyAssignedIds =
          (widget.project['assignedMembers'] as List)
              .map((member) => _getMemberId(member))
              .where((id) => id.isNotEmpty)
              .toList();
    }
    selectedMemberIds = List.from(currentlyAssignedIds);
  }

  String _getMemberId(dynamic member) {
    if (member is Map<String, dynamic>) {
      return member['_id'] ?? '';
    }
    return member?.toString() ?? '';
  }

  String _getTeamMemberId(Map<String, dynamic> teamMember) {
    if (teamMember['member'] is Map<String, dynamic>) {
      final memberData = teamMember['member'] as Map<String, dynamic>;
      return memberData['_id'] ?? '';
    }
    return teamMember['member']?.toString() ?? '';
  }

  String _getTeamMemberName(Map<String, dynamic> teamMember) {
    if (teamMember['member'] is Map<String, dynamic>) {
      final memberData = teamMember['member'] as Map<String, dynamic>;
      return memberData['displayName'] ??
          memberData['username'] ??
          'Unknown User';
    }
    return teamMember['member']?.toString() ?? 'Người dùng không xác định';
  }

  String _getTeamMemberRole(Map<String, dynamic> teamMember) {
    final role = teamMember['role'] ?? 'member';
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Colors.amber;
      case 'admin':
        return Colors.blue;
      case 'member':
      default:
        return Colors.green;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'owner':
        return Icons.star;
      case 'admin':
        return Icons.admin_panel_settings;
      case 'member':
      default:
        return Icons.person;
    }
  }

  Future<void> _saveAssignments() async {
    setState(() {
      isLoading = true;
    });

    try {
      // Determine members to add and remove
      final membersToAdd =
          selectedMemberIds
              .where((id) => !currentlyAssignedIds.contains(id))
              .toList();
      final membersToRemove =
          currentlyAssignedIds
              .where((id) => !selectedMemberIds.contains(id))
              .toList();

      // Add new members
      if (membersToAdd.isNotEmpty) {
        await ProjectApi.assignMembersToProject(
          widget.project['_id'],
          membersToAdd,
          widget.teamId,
        );
      }

      // Remove members
      if (membersToRemove.isNotEmpty) {
        await ProjectApi.removeMembersFromProject(
          widget.project['_id'],
          membersToRemove,
          widget.teamId,
        );
      }

      Navigator.of(context).pop();
      widget.onAssignComplete();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Đã cập nhật thành viên dự án thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lỗi khi cập nhật thành viên dự án: ${e.toString().replaceAll('Exception: ', '')}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Assign Members to Project',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project info
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.primaryContainer.withOpacity(0.1),
                border: Border.all(
                  color: Theme.of(
                    context,
                  ).colorScheme.primaryContainer.withOpacity(0.3),
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.folder,
                    color: Theme.of(context).colorScheme.primaryContainer,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Project: ${widget.project['name'] ?? 'Unknown'}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),

            // Members list title
            Text(
              'Select members to assign:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
            SizedBox(height: 8),

            // Members list
            Expanded(
              child: ListView.builder(
                itemCount: widget.teamMembers.length,
                itemBuilder: (context, index) {
                  final teamMember = widget.teamMembers[index];
                  final memberId = _getTeamMemberId(teamMember);
                  final memberName = _getTeamMemberName(teamMember);
                  final memberRole = _getTeamMemberRole(teamMember);
                  final isSelected = selectedMemberIds.contains(memberId);

                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 2),
                    color:
                        isSelected
                            ? Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withOpacity(0.1)
                            : Theme.of(context).colorScheme.surface,
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedMemberIds.contains(memberId)) {
                              selectedMemberIds.add(memberId);
                            }
                          } else {
                            selectedMemberIds.remove(memberId);
                          }
                        });
                      },
                      secondary: CircleAvatar(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        child: Text(
                          memberName[0].toUpperCase(),
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        memberName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      subtitle: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _getRoleColor(memberRole.toLowerCase()),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getRoleIcon(memberRole.toLowerCase()),
                              size: 12,
                              color: Colors.white,
                            ),
                            SizedBox(width: 4),
                            Text(
                              memberRole,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      activeColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      checkColor: Colors.white,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${selectedMemberIds.length} selected',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontSize: 14,
              ),
            ),
            Row(
              children: [
                TextButton(
                  onPressed:
                      isLoading ? null : () => Navigator.of(context).pop(),
                  child: Text('Hủy'),
                ),
                SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isLoading ? null : _saveAssignments,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    foregroundColor: Colors.white,
                  ),
                  child:
                      isLoading
                          ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : Text('Lưu'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
