import 'package:flutter/material.dart';
import 'package:loop_application/apis/team_api.dart';
import 'package:loop_application/apis/project_api.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/project_detail_view.dart';
import 'package:loop_application/controllers/user_controller.dart';

class TeamView extends StatefulWidget {
  final String teamId;

  const TeamView({super.key, required this.teamId});

  @override
  State<TeamView> createState() => _TeamViewState();
}

class _TeamViewState extends State<TeamView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  Map<String, dynamic>? teamInfo;
  List<dynamic> projects = [];
  String? currentUserId;
  ValueNotifier<int> _membersUpdateNotifier = ValueNotifier<int>(
    0,
  ); // Notifier for members update

  @override
  void dispose() {
    _tabController.dispose();
    _membersUpdateNotifier.dispose();
    super.dispose();
  }

  // Get current user's role in the team
  String _getCurrentUserRole() {
    if (teamInfo?['members'] == null || currentUserId == null) return 'member';

    for (var member in teamInfo!['members']) {
      final memberId = _getMemberId(member);
      if (memberId.isNotEmpty && memberId == currentUserId) {
        final role = _getMemberRole(member);
        return role.isNotEmpty ? role : 'member';
      }
    }
    return 'member';
  }

  // Get current user's ID
  String _getCurrentUserId() {
    return currentUserId ?? '';
  }

  // Initialize current user ID
  Future<void> _initCurrentUser() async {
    try {
      final userController = UserController();
      await userController.getUser();
      currentUserId = await userController.getUserIdServer();
    } catch (e) {
      print('Error getting current user: $e');
    }
  }

  void _showTeamInfo() {
    showDialog(
      context: context,
      builder:
          (context) => ValueListenableBuilder<int>(
            valueListenable: _membersUpdateNotifier,
            builder: (context, value, child) {
              return AlertDialog(
                backgroundColor: Theme.of(context).colorScheme.primary,
                title: Text(
                  teamInfo?['name'] ?? 'Thông tin nhóm',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                content: SizedBox(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thành viên:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      // Add Member Button (only for admin and owner)
                      if (_getCurrentUserRole().toLowerCase() == 'admin' ||
                          _getCurrentUserRole().toLowerCase() == 'owner')
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _addMemberToTeam,
                            icon: Icon(Icons.person_add, size: 18),
                            label: Text('Thêm thành viên'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 8),
                            ),
                          ),
                        ),
                      if (_getCurrentUserRole().toLowerCase() == 'admin' ||
                          _getCurrentUserRole().toLowerCase() == 'owner')
                        const SizedBox(height: 10),
                      Flexible(
                        child:
                            teamInfo?['members'] != null
                                ? ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: teamInfo!['members'].length,
                                  itemBuilder: (context, index) {
                                    final member = teamInfo!['members'][index];
                                    return Card(
                                      margin: EdgeInsets.symmetric(vertical: 2),
                                      color:
                                          Theme.of(context).colorScheme.surface,
                                      child: ListTile(
                                        leading: CircleAvatar(
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                          child: Text(
                                            _getMemberName(
                                              member,
                                            )[0].toUpperCase(),
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        title: Text(
                                          _getMemberName(member),
                                          style: TextStyle(
                                            color:
                                                Theme.of(
                                                  context,
                                                ).colorScheme.inversePrimary,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        subtitle: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  padding: EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: _getRoleColor(
                                                      _getMemberRole(
                                                        member,
                                                      ).toLowerCase(),
                                                    ),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          8,
                                                        ),
                                                  ),
                                                  child: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Icon(
                                                        _getRoleIcon(
                                                          _getMemberRole(
                                                            member,
                                                          ).toLowerCase(),
                                                        ),
                                                        size: 12,
                                                        color: Colors.white,
                                                      ),
                                                      SizedBox(width: 4),
                                                      Text(
                                                        _getMemberRole(member),
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 10,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                            if (_getMemberEmail(
                                              member,
                                            ).isNotEmpty)
                                              Padding(
                                                padding: EdgeInsets.only(
                                                  top: 4,
                                                ),
                                                child: Text(
                                                  _getMemberEmail(member),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color:
                                                        Theme.of(
                                                          context,
                                                        ).colorScheme.outline,
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                        trailing: _buildMemberActions(member),
                                      ),
                                    );
                                  },
                                )
                                : Text(
                                  'Không tìm thấy thành viên',
                                  style: TextStyle(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.inversePrimary,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Member count info
                      Text(
                        '${teamInfo?['members']?.length ?? 0} thành viên',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 14,
                        ),
                      ),
                      // Close button
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
    );
  }

  Widget _buildMemberActions(Map<String, dynamic> member) {
    final memberRole = _getMemberRole(member).toLowerCase();
    final memberId = _getMemberId(member);
    final currentUserRole = _getCurrentUserRole().toLowerCase();
    final currentUserId = _getCurrentUserId();

    // Don't show menu for members if current user is also a member
    if (currentUserRole == 'member') {
      return SizedBox.shrink(); // Members cannot perform actions on other members
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'remove') {
          _removeMember(memberId);
        } else if (value == 'promote_admin') {
          _changeMemberRole(memberId, 'admin');
        } else if (value == 'promote_owner') {
          _changeMemberRole(memberId, 'owner');
        } else if (value == 'demote_admin') {
          _changeMemberRole(memberId, 'admin');
        } else if (value == 'demote_member') {
          _changeMemberRole(memberId, 'member');
        } else if (value == 'view_profile') {
          _viewMemberProfile(member);
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // View Profile option (always available)
        items.add(
          PopupMenuItem(
            value: 'view_profile',
            child: Row(
              children: [
                Icon(Icons.person, color: Colors.blue),
                SizedBox(width: 8),
                Text('Xem hồ sơ'),
              ],
            ),
          ),
        );

        // Don't show role management options if it's the current user
        if (memberId == currentUserId) {
          return items;
        }

        items.add(PopupMenuDivider());

        // Role management options based on current user's role and target member's role
        if (currentUserRole == 'admin') {
          // Admin can only manage members, not owners or other admins
          if (memberRole == 'member') {
            items.add(
              PopupMenuItem(
                value: 'promote_admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Thăng chức thành Quản trị viên'),
                  ],
                ),
              ),
            );
            // Admin cannot promote to owner
          }
          // Admin cannot demote admins or owners
        } else if (currentUserRole == 'owner') {
          // Owner can manage anyone except other owners (unless demoting themselves)
          if (memberRole == 'member') {
            items.addAll([
              PopupMenuItem(
                value: 'promote_admin',
                child: Row(
                  children: [
                    Icon(Icons.admin_panel_settings, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Thăng chức thành Quản trị viên'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'promote_owner',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Thăng chức thành Chủ sở hữu'),
                  ],
                ),
              ),
            ]);
          } else if (memberRole == 'admin') {
            items.addAll([
              PopupMenuItem(
                value: 'promote_owner',
                child: Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Thăng chức thành Chủ sở hữu'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'demote_member',
                child: Row(
                  children: [
                    Icon(Icons.remove_moderator, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Hạ chức thành Thành viên'),
                  ],
                ),
              ),
            ]);
          } else if (memberRole == 'owner') {
            // Owner can only demote other owners
            items.add(
              PopupMenuItem(
                value: 'demote_admin',
                child: Row(
                  children: [
                    Icon(Icons.remove_moderator, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Hạ chức thành Quản trị viên'),
                  ],
                ),
              ),
            );
            items.add(
              PopupMenuItem(
                value: 'demote_member',
                child: Row(
                  children: [
                    Icon(Icons.remove_moderator, color: Colors.orange),
                    SizedBox(width: 8),
                    Text('Hạ chức thành Thành viên'),
                  ],
                ),
              ),
            );
          }
        }

        // Remove option - based on permissions
        bool canRemove = false;
        if (currentUserRole == 'admin') {
          // Admin can remove members only
          canRemove = (memberRole == 'member');
        } else if (currentUserRole == 'owner') {
          // Owner can remove members and admins, not other owners
          canRemove = (memberRole == 'member' || memberRole == 'admin');
        }

        if (canRemove) {
          items.add(PopupMenuDivider());
          items.add(
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.person_remove, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Xóa thành viên'),
                ],
              ),
            ),
          );
        }

        return items;
      },
    );
  }

  Future<void> _removeMember(String memberId) async {
    try {
      // Update UI immediately
      _removeMemberLocally(memberId);

      // Call API
      await TeamApi.removeUserFromTeam(widget.teamId, memberId);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Xóa thành viên thành công'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    } catch (e) {
      // Revert local changes if API failed
      await getTeamInfo();

      print('Error removing member: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Lỗi khi xóa thành viên: ${e.toString().replaceAll('Exception: ', '')}',
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  Future<void> _changeMemberRole(String memberId, String newRole) async {
    // Confirmation dialog
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Thay đổi vai trò thành viên',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Bạn có chắc chắn muốn thay đổi vai trò của thành viên này thành ${newRole.toUpperCase()}?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                ),
                SizedBox(height: 12),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getRoleColor(newRole).withOpacity(0.1),
                    border: Border.all(
                      color: _getRoleColor(newRole).withOpacity(0.3),
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(newRole),
                        color: _getRoleColor(newRole),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Vai trò mới: ${newRole.toUpperCase()}',
                        style: TextStyle(
                          color: _getRoleColor(newRole),
                          fontWeight: FontWeight.bold,
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
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getRoleColor(newRole),
                  foregroundColor: Colors.white,
                ),
                child: Text('Thay đổi vai trò'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        // Show loading
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
                        'Đang thay đổi vai trò thành viên...',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        );

        // Update UI immediately
        _updateMemberRoleLocally(memberId, newRole);

        // Call API
        await TeamApi.changeMemberRole(widget.teamId, memberId, newRole);

        // Close loading dialog
        Navigator.of(context).pop();

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Thay đổi vai trò thành viên thành ${newRole.toUpperCase()} thành công!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      } catch (e) {
        // Close loading dialog
        Navigator.of(context).pop();

        // Revert local changes if API failed
        await getTeamInfo();

        print('Error changing member role: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.error, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Không thể thay đổi vai trò thành viên: ${e.toString().replaceAll('Exception: ', '')}',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _viewMemberProfile(Map<String, dynamic> member) {
    final memberData = member['member'];
    final role = _getMemberRole(member);
    final joinedDate = member['joined_date'];

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Hồ sơ thành viên',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar and basic info
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Text(
                        _getMemberName(member)[0].toUpperCase(),
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getMemberName(member),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                          SizedBox(height: 4),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getRoleColor(role.toLowerCase()),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getRoleIcon(role.toLowerCase()),
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  role,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
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
                SizedBox(height: 20),

                // Member details
                if (memberData is Map<String, dynamic>) ...[
                  _buildProfileRow(
                    'Tên đăng nhập',
                    memberData['username'] ?? 'N/A',
                  ),
                  _buildProfileRow(
                    'Tên hiển thị',
                    memberData['displayName'] ?? 'N/A',
                  ),
                  _buildProfileRow('Email', memberData['email'] ?? 'N/A'),
                ],
                _buildProfileRow('Vai trò', role),
                if (joinedDate != null)
                  _buildProfileRow(
                    'Ngày tham gia',
                    _formatDate(joinedDate.toString()),
                  ),
              ],
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

  Widget _buildProfileRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Không xác định';
    }
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
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

  Future<void> getTeamInfo() async {
    try {
      await _initCurrentUser(); // Initialize current user info first
      teamInfo = await TeamApi.getTeamById(widget.teamId);
      print('Team info loaded: ${teamInfo?['name']}');
      print('Members count: ${teamInfo?['members']?.length}');
      print('Current user ID: $currentUserId');
      print('Current user role: ${_getCurrentUserRole()}');
      if (teamInfo?['members'] != null) {
        for (var member in teamInfo!['members']) {
          print('Member data: ${member.toString()}');
        }
      }
      await getProjects(); // Fetch projects as well
      setState(() {}); // Update the UI after fetching team info
    } catch (e) {
      print('Error fetching team info: $e');
      // Handle error (e.g., show a snackbar or dialog)
    }
  }

  Future<void> getProjects() async {
    try {
      projects = await ProjectApi.getProjectsOfTeam(widget.teamId);
      setState(() {});
    } catch (e) {
      print('Error fetching projects: $e');
      // Handle error
    }
  }

  @override
  void initState() {
    super.initState();
    _initCurrentUser(); // Initialize current user ID
    getTeamInfo();
    _tabController = TabController(length: 2, vsync: this);
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
        title: Text(teamInfo?['name'] ?? 'Đang tải...', style: titleText),
        actionsPadding: EdgeInsets.only(right: 20),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: _showTeamInfo,
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
            Tab(icon: Icon(Icons.folder), text: 'Dự án'),
            Tab(icon: Icon(Icons.bar_chart), text: 'Thống kê'),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).colorScheme.primary,
        child: TabBarView(
          controller: _tabController,
          children: [_buildProjectsView(), _buildStatisticsView()],
        ),
      ),
      floatingActionButton:
          (_getCurrentUserRole().toLowerCase() == 'owner')
              ? FloatingActionButton(
                onPressed: _createProject,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Colors.white,
                child: Icon(Icons.add),
              )
              : null,
    );
  }

  Widget _buildProjectsView() {
    return RefreshIndicator(
      onRefresh: getProjects,
      color: Theme.of(context).colorScheme.primaryContainer,
      child:
          projects.isEmpty
              ? SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.outline,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Chưa có dự án nào',
                          style: TextStyle(
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tạo dự án đầu tiên để bắt đầu',
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                        ),
                        SizedBox(height: 20),
                        if (_getCurrentUserRole().toLowerCase() == 'owner')
                          ElevatedButton.icon(
                            onPressed: _createProject,
                            icon: Icon(Icons.add),
                            label: Text('Tạo dự án'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Theme.of(
                                    context,
                                  ).colorScheme.primaryContainer,
                              foregroundColor: Colors.white,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              )
              : ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: projects.length,
                itemBuilder: (context, index) {
                  final project = projects[index];
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    elevation: 2,
                    color: Theme.of(context).colorScheme.surface,
                    child: ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.folder, color: Colors.white),
                      ),
                      title: Text(
                        project['name'] ?? 'Dự án không xác định',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Project ID: ${project['_id'] ?? 'Unknown'}',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.outline,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      trailing: _buildProjectActions(project),
                      onTap: () {
                        // Navigate to project details
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder:
                                (context) => ProjectDetailView(
                                  projectId: project['_id'] ?? '',
                                  projectName:
                                      project['name'] ?? 'Dự án không xác định',
                                  teamId: widget.teamId,
                                ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
    );
  }

  Widget _buildStatisticsView() {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Theme.of(context).colorScheme.surface,
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thống kê nhóm',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),
                  ),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Dự án',
                        '${projects.length}',
                        Icons.folder,
                      ),
                      _buildStatCard(
                        'Thành viên',
                        '${teamInfo?['members']?.length ?? 0}',
                        Icons.people,
                      ),
                      _buildStatCard('Nhiệm vụ', '0', Icons.task),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 16),
          // Card(
          //   color: Theme.of(context).colorScheme.surface,
          //   child: Padding(
          //     padding: EdgeInsets.all(16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         Text(
          //           'Hoạt động gần đây',
          //           style: TextStyle(
          //             fontSize: 18,
          //             fontWeight: FontWeight.bold,
          //             color: Theme.of(context).colorScheme.inversePrimary,
          //           ),
          //         ),
          //         SizedBox(height: 16),
          //         Text(
          //           'Không có hoạt động gần đây',
          //           style: TextStyle(
          //             color: Theme.of(context).colorScheme.outline,
          //           ),
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: Theme.of(context).colorScheme.primaryContainer,
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primaryContainer,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }

  Future<void> _createProject() async {
    final TextEditingController nameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Tạo dự án mới',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: nameController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Tên dự án',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => Center(
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              ),
                            ),
                      );

                      await ProjectApi.createProject(
                        widget.teamId,
                        nameController.text.trim(),
                      );

                      // Close loading and create dialogs
                      Navigator.of(context).pop(); // Loading
                      Navigator.of(context).pop(); // Create dialog

                      // Add project temporarily to UI
                      _addProjectTemporarily(nameController.text.trim());

                      // Refresh projects list after a short delay to get complete project data
                      Future.delayed(Duration(milliseconds: 500), () async {
                        await getProjects();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Dự án "${nameController.text.trim()}" đã được tạo thành công',
                          ),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } catch (e) {
                      // Close loading dialog only
                      Navigator.of(context).pop();

                      // Revert local changes if API failed
                      await getProjects();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi tạo dự án: $e'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text('Tạo'),
              ),
            ],
          ),
    );
  }

  Future<void> _updateProject(Map<String, dynamic> project) async {
    final TextEditingController nameController = TextEditingController();
    nameController.text = project['name'] ?? '';

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Cập nhật dự án',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: TextField(
              controller: nameController,
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              decoration: InputDecoration(
                labelText: 'Tên dự án',
                labelStyle: TextStyle(
                  color: Theme.of(context).colorScheme.outline,
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                ),
                child: Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  if (nameController.text.trim().isNotEmpty) {
                    try {
                      // Show loading
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder:
                            (context) => Center(
                              child: CircularProgressIndicator(
                                color:
                                    Theme.of(
                                      context,
                                    ).colorScheme.primaryContainer,
                              ),
                            ),
                      );

                      await ProjectApi.updateProject(
                        project['_id'],
                        nameController.text.trim(),
                        widget.teamId,
                      );

                      // Close loading and update dialogs
                      Navigator.of(context).pop(); // Loading
                      Navigator.of(context).pop(); // Update dialog

                      // Update project locally
                      _updateProjectLocally(
                        project['_id'],
                        nameController.text.trim(),
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Dự án đã được cập nhật thành công'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 3),
                        ),
                      );
                    } catch (e) {
                      // Close loading dialog only
                      Navigator.of(context).pop();

                      // Revert local changes if API failed
                      await getProjects();

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Lỗi khi cập nhật dự án: $e'),
                          backgroundColor: Colors.red,
                          duration: Duration(seconds: 5),
                        ),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                ),
                child: Text('Cập nhật'),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteProject(Map<String, dynamic> project) async {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Xóa dự án',
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
                  'Bạn có chắc chắn muốn xóa dự án này?',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Dự án: ${project['name']}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Hành động này không thể hoàn tác!',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                ),
                child: Text('Hủy'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  try {
                    // Show loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder:
                          (context) => Center(
                            child: CircularProgressIndicator(color: Colors.red),
                          ),
                    );

                    await ProjectApi.deleteProject(project['_id'], widget.teamId);

                    // Close loading and delete dialogs
                    Navigator.of(context).pop(); // Loading
                    Navigator.of(context).pop(); // Delete dialog

                    // Remove project locally
                    _removeProjectLocally(project['_id']);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Dự án "${project['name']}" đã được xóa thành công',
                        ),
                        backgroundColor: Colors.orange,
                        duration: Duration(seconds: 3),
                      ),
                    );
                  } catch (e) {
                    // Close loading dialog only
                    Navigator.of(context).pop();

                    // Revert local changes if API failed
                    await getProjects();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Lỗi khi xóa dự án: $e'),
                        backgroundColor: Colors.red,
                        duration: Duration(seconds: 5),
                      ),
                    );
                  }
                },
                child: Text('Xóa'),
              ),
            ],
          ),
    );
  }

  Widget _buildProjectActions(Map<String, dynamic> project) {
    final currentUserRole = _getCurrentUserRole().toLowerCase();

    // Only show project management actions for owner
    if (currentUserRole != 'owner') {
      return SizedBox.shrink();
    }

    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'edit') {
          _updateProject(project);
        } else if (value == 'delete') {
          _deleteProject(project);
        }
      },
      itemBuilder: (context) {
        List<PopupMenuEntry<String>> items = [];

        // Edit and delete (owner only)
        items.addAll([
          PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit, color: Colors.blue),
                SizedBox(width: 8),
                Text('Sửa'),
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
        ]);

        return items;
      },
    );
  }

  // Helper methods to extract member information
  String _getMemberName(Map<String, dynamic> member) {
    // If member['member'] is a populated User object
    if (member['member'] is Map<String, dynamic>) {
      final memberData = member['member'] as Map<String, dynamic>;
      // Prefer displayName, then username
      return memberData['displayName'] ??
          memberData['username'] ??
          'Người dùng không xác định';
    }
    // If member['member'] is just a string/ID (fallback)
    return member['member']?.toString() ?? 'Người dùng không xác định';
  }

  String _getMemberId(Map<String, dynamic> member) {
    // If member['member'] is a populated User object
    if (member['member'] is Map<String, dynamic>) {
      final memberData = member['member'] as Map<String, dynamic>;
      return memberData['_id'] ?? '';
    }
    // If member['member'] is just an ID string
    return member['member']?.toString() ?? '';
  }

  String _getMemberEmail(Map<String, dynamic> member) {
    // If member['member'] is a populated User object
    if (member['member'] is Map<String, dynamic>) {
      final memberData = member['member'] as Map<String, dynamic>;
      return memberData['email'] ?? '';
    }
    return '';
  }

  String _getMemberRole(Map<String, dynamic> member) {
    final role = member['role'] ?? 'member';
    // Ensure role is not empty before accessing first character
    if (role.isEmpty) {
      return 'Member';
    }
    // Convert to sentence case (first letter uppercase, rest lowercase)
    return role[0].toUpperCase() + role.substring(1).toLowerCase();
  }

  // Add member to team functionality
  Future<void> _addMemberToTeam() async {
    final TextEditingController usernameController = TextEditingController();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            title: Text(
              'Thêm thành viên vào nhóm',
              style: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Nhập tên đăng nhập của người bạn muốn thêm vào nhóm này:',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontSize: 14,
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: usernameController,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Tên đăng nhập',
                    hintText: 'Nhập tên đăng nhập...',
                    prefixIcon: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    hintStyle: TextStyle(
                      color: Theme.of(
                        context,
                      ).colorScheme.outline.withOpacity(0.7),
                    ),
                    border: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.outline.withOpacity(0.5),
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      _performAddMember(
                        usernameController.text.trim(),
                        context,
                      );
                    }
                  },
                ),
                SizedBox(height: 12),
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
                        Icons.info_outline,
                        size: 16,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Người dùng phải đã có tài khoản trong hệ thống.',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
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
                onPressed: () => Navigator.of(context).pop(),
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.outline,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text('Hủy'),
              ),
              ElevatedButton(
                onPressed: () {
                  final username = usernameController.text.trim();
                  if (username.isNotEmpty) {
                    if (username.length < 3) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Tên đăng nhập phải có ít nhất 3 ký tự',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    // Check if user is already a member
                    if (_isUserAlreadyMember(username)) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Người dùng này đã là thành viên của nhóm',
                          ),
                          backgroundColor: Colors.orange,
                        ),
                      );
                      return;
                    }

                    _performAddMember(username, context);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Vui lòng nhập tên đăng nhập'),
                        backgroundColor: Colors.orange,
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      Theme.of(context).colorScheme.primaryContainer,
                  foregroundColor: Colors.white,
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                child: Text('Thêm thành viên'),
              ),
            ],
          ),
    );
  }

  Future<void> _performAddMember(
    String username,
    BuildContext dialogContext,
  ) async {
    try {
      // Show loading dialog
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
                      'Đang thêm thành viên...',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.inversePrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
      );

      // Call API to add user to team
      await TeamApi.addUserToTeam(widget.teamId, username);

      // Close loading dialog
      Navigator.of(context).pop();

      // Close add member dialog
      Navigator.of(dialogContext).pop();

      // Add member temporarily to UI (optimistic update)
      _addMemberTemporarily(username);

      // Refresh team info after a short delay to get complete member data
      Future.delayed(Duration(milliseconds: 500), () async {
        await getTeamInfo();
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Đã thêm thành công "$username" vào nhóm!',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 4),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    } catch (e) {
      // Close loading dialog
      Navigator.of(context).pop();

      // Revert local changes if API failed
      await getTeamInfo();

      print('Error adding member: $e');

      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Không thể thêm thành viên: ${e.toString().replaceAll('Exception: ', '')}',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 6),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          action: SnackBarAction(
            label: 'Thử lại',
            textColor: Colors.white,
            onPressed: () {
              _addMemberToTeam();
            },
          ),
        ),
      );
    }
  }

  // Check if user is already a member of the team
  bool _isUserAlreadyMember(String username) {
    if (teamInfo?['members'] == null) return false;

    for (var member in teamInfo!['members']) {
      final memberData = member['member'];

      // Check against both username and displayName
      if (memberData is Map<String, dynamic>) {
        final existingUsername =
            memberData['username']?.toString().toLowerCase();
        final existingDisplayName =
            memberData['displayName']?.toString().toLowerCase();

        if ((existingUsername != null &&
                existingUsername == username.toLowerCase()) ||
            (existingDisplayName != null &&
                existingDisplayName == username.toLowerCase())) {
          return true;
        }
      }
    }
    return false;
  }

  // Helper function to refresh team info dialog if it's currently open
  void _refreshTeamInfoDialogIfOpen() {
    // Increment the notifier value to trigger rebuild of ValueListenableBuilder
    _membersUpdateNotifier.value++;
  }

  // Update member role locally without API call
  void _updateMemberRoleLocally(String memberId, String newRole) {
    if (teamInfo != null && teamInfo!['members'] != null) {
      setState(() {
        for (var member in teamInfo!['members']) {
          final memberIdFromData = _getMemberId(member);
          if (memberIdFromData.isNotEmpty && memberIdFromData == memberId) {
            member['role'] = newRole.toLowerCase();
            break;
          }
        }
      });

      // If team info dialog is open, close and reopen it to refresh
      _refreshTeamInfoDialogIfOpen();
    }
  }

  // Remove member locally without API call
  void _removeMemberLocally(String memberId) {
    if (teamInfo != null && teamInfo!['members'] != null) {
      setState(() {
        teamInfo!['members'].removeWhere((member) {
          final memberIdFromData = _getMemberId(member);
          return memberIdFromData.isNotEmpty && memberIdFromData == memberId;
        });
      });

      // If team info dialog is open, close and reopen it to refresh
      _refreshTeamInfoDialogIfOpen();
    }
  }

  // Add member temporarily to UI with placeholder data
  void _addMemberTemporarily(String username) {
    if (teamInfo != null && teamInfo!['members'] != null) {
      setState(() {
        teamInfo!['members'].add({
          'member': {
            '_id':
                'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
            'username': username,
            'displayName': username,
            'email': '',
          },
          'role': 'member',
          'joined_date': DateTime.now().toIso8601String(),
        });
      });
    }
  }

  // Add project temporarily to UI with placeholder data
  void _addProjectTemporarily(String projectName) {
    setState(() {
      projects.add({
        '_id': 'temp_${DateTime.now().millisecondsSinceEpoch}', // Temporary ID
        'name': projectName,
        'createdAt': DateTime.now().toIso8601String(),
      });
    });
  }

  // Update project locally without API call
  void _updateProjectLocally(String projectId, String newName) {
    setState(() {
      for (var project in projects) {
        if (project['_id'] == projectId) {
          project['name'] = newName;
          break;
        }
      }
    });
  }

  // Remove project locally without API call
  void _removeProjectLocally(String projectId) {
    setState(() {
      projects.removeWhere((project) => project['_id'] == projectId);
    });
  }
}
