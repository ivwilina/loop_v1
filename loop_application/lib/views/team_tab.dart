import 'package:flutter/material.dart';
import 'package:loop_application/components/team_tab_item.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/login_tab.dart';
import 'package:provider/provider.dart';
import 'package:loop_application/apis/team_api.dart';

class TeamTab extends StatefulWidget {
  const TeamTab({super.key});

  @override
  State<TeamTab> createState() => _TeamTabState();
}

class _TeamTabState extends State<TeamTab> {
  int _selectedList = 0;
  List<dynamic> _teams = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserLoggedIn();
    fetchTeams();
  }

  void fetchUserLoggedIn() {
    Provider.of<UserController>(context, listen: false).getUser();
  }

  Future<void> fetchTeams() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<dynamic> teams = [];
      switch (_selectedList) {
        case 0:
          teams = await TeamApi.getAllTeamsUserParticipatedIn();
          break;
        case 1:
          teams = await TeamApi.getTeamsOwnedByUser();
          break;
        case 2:
          teams = await TeamApi.getTeamsUserJoined();

          break;
        default:
          teams = [];
      }

      setState(() {
        _teams = teams;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();
    List<User> users = userController.users;

    return Scaffold(
      appBar: AppBar(
        title: Text("Nhóm"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body:
          users.isEmpty
              ? Container(
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                ),
                child: Row(
                  spacing: 20,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginTab(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.primaryContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: Text("Đăng nhập", style: normalText),
                    ),
                    Text(
                      "Để sử dụng tính năng này",
                      style: TextStyle(fontSize: 16),
                      maxLines: 2,
                    ),
                  ],
                ),
              )
              : Column(
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      border: BorderDirectional(
                        bottom: BorderSide(
                          color: Theme.of(context).colorScheme.outline,
                          width: 1,
                        ),
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Column(
                      spacing: 10,
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedList = 0;
                            });
                            fetchTeams();
                          },
                          child: Text(
                            "Tất cả",
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  (_selectedList == 0)
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      : Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedList = 1;
                            });
                            fetchTeams();
                          },
                          child: Text(
                            "Nhóm của bạn",
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  (_selectedList == 1)
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      : Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedList = 2;
                            });
                            fetchTeams();
                          },
                          child: Text(
                            "Nhóm bạn tham gia",
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  (_selectedList == 2)
                                      ? Theme.of(
                                        context,
                                      ).colorScheme.primaryContainer
                                      : Theme.of(
                                        context,
                                      ).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            showModalBottomSheet(
                              context: context,
                              builder: (BuildContext context) {
                                return Container(
                                  width: MediaQuery.of(context).size.width,
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 20,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  child: Column(
                                    spacing: 10,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () async {
                                          await showDialog(
                                            context: context,
                                            builder: (BuildContext context) {
                                              var teamName = 'new team';
                                              return AlertDialog(
                                                backgroundColor:
                                                    Theme.of(
                                                      context,
                                                    ).colorScheme.primary,
                                                title: Text('Tạo nhóm mới'),
                                                content: TextField(
                                                  decoration: InputDecoration(
                                                    labelText: 'Tên nhóm',
                                                    focusedBorder:
                                                        UnderlineInputBorder(
                                                          borderSide: BorderSide(
                                                            color:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primaryContainer,
                                                          ),
                                                        ),
                                                    labelStyle: TextStyle(
                                                      color:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .inversePrimary,
                                                    ),
                                                  ),
                                                  onChanged: (value) {
                                                    // Update the team name whenever the text changes
                                                    teamName = value;
                                                  },
                                                  onSubmitted: (value) {
                                                    teamName = value;
                                                  },
                                                ),
                                                actions: [
                                                  TextButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                    ),
                                                    onPressed:
                                                        () =>
                                                            Navigator.of(
                                                              context,
                                                            ).pop(),
                                                    child: Text('Hủy'),
                                                  ),
                                                  ElevatedButton(
                                                    style: TextButton.styleFrom(
                                                      backgroundColor:
                                                          Theme.of(context)
                                                              .colorScheme
                                                              .primaryContainer,
                                                    ),
                                                    onPressed: () async {
                                                      Navigator.of(
                                                        context,
                                                      ).pop(); // Close dialog first

                                                      try {
                                                        // Show loading indicator
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Đang tạo nhóm...',
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primaryContainer,
                                                          ),
                                                        );

                                                        await TeamApi.createTeam(
                                                          teamName,
                                                        );

                                                        // Show success message
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Tạo nhóm thành công!',
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .primaryContainer,
                                                          ),
                                                        );

                                                        setState(() {
                                                          _selectedList = 1;
                                                        });
                                                        await fetchTeams();
                                                      } catch (e) {
                                                        print(
                                                          'Error creating team: $e',
                                                        );
                                                        // Show error message
                                                        ScaffoldMessenger.of(
                                                          context,
                                                        ).showSnackBar(
                                                          SnackBar(
                                                            content: Text(
                                                              'Lỗi: ${e.toString()}',
                                                              style: TextStyle(
                                                                color:
                                                                    Theme.of(
                                                                          context,
                                                                        )
                                                                        .colorScheme
                                                                        .primary,
                                                              ),
                                                            ),
                                                            backgroundColor:
                                                                Theme.of(
                                                                      context,
                                                                    )
                                                                    .colorScheme
                                                                    .error,
                                                            duration: Duration(
                                                              seconds: 5,
                                                            ),
                                                          ),
                                                        );
                                                      }
                                                    },
                                                    child: Text('Tạo'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          Navigator.of(context).pop();
                                        },
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Row(
                                            spacing: 20,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.add_box_outlined,
                                                size: 25,
                                              ),
                                              Text(
                                                'Tạo nhóm mới',
                                                style: normalText,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {},
                                        style: TextButton.styleFrom(
                                          backgroundColor:
                                              Theme.of(
                                                context,
                                              ).colorScheme.primaryContainer,
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 20,
                                          ),
                                          child: Row(
                                            spacing: 20,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Icon(
                                                Icons.input_outlined,
                                                size: 25,
                                              ),
                                              Text(
                                                'Tham gia nhóm',
                                                style: normalText,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(
                            "+ Nhóm mới",
                            style: TextStyle(
                              fontSize: 20,
                              color:
                                  Theme.of(context).colorScheme.inversePrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child:
                        _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : ListView(
                              children: [
                                for (var team in _teams)
                                  TeamTabItem(
                                    teamName: team['name'],
                                    memberCount: team['members'].length,
                                    teamId: team['_id'],
                                  ),
                              ],
                            ),
                  ),
                ],
              ),
    );
  }
}
