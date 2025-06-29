import 'package:flutter/material.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/theme/theme_controller.dart';
import 'package:loop_application/views/home_tab.dart';
import 'package:provider/provider.dart';
// import 'package:loop_application/theme/theme.dart';

class SettingTab extends StatefulWidget {
  const SettingTab({super.key});

  @override
  State<SettingTab> createState() => _SettingTabState();
}

class _SettingTabState extends State<SettingTab> {
  void fetchUserLoggedIn() {
    Provider.of<UserController>(context, listen: false).getUser();
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchUserLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    final userController = context.watch<UserController>();

    List<User> users = userController.users;

    return Scaffold(
      appBar: AppBar(
        title: Text("Cài đặt"),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        width: MediaQuery.sizeOf(context).width,
        color: Theme.of(context).colorScheme.surface,
        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary,
            borderRadius: BorderRadius.all(Radius.circular(15)),
          ),
          padding: EdgeInsets.symmetric(horizontal: 25, vertical: 15),
          child: Column(
            spacing: 20,
            children: [
              themeSetting(context),
              if (users.isNotEmpty) logout(context),
            ],
          ),
        ),
      ),
    );
  }

  GestureDetector logout(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<UserController>(context, listen: false).deleteAllUsers();
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => HomeTab()),
          (route) => false,
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Đăng xuất', style: normalText),
            Icon(Icons.logout_outlined, size: 25),
          ],
        ),
      ),
    );
  }

  //* Change theme option
  GestureDetector themeSetting(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Provider.of<ThemeController>(context, listen: false).changeTheme();
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              width: 1,
              color: Theme.of(context).colorScheme.surface,
            ),
          ),
        ),
        padding: EdgeInsets.only(bottom: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (Theme.of(context).brightness == Brightness.light)
              Text('Giao diện sáng', style: normalText)
            else
              Text('Giao diện tối', style: normalText),
            if (Theme.of(context).brightness == Brightness.light)
              Icon(Icons.light_mode_outlined, size: 25)
            else
              Icon(Icons.dark_mode_outlined, size: 25),
          ],
        ),
      ),
    );
  }
}
