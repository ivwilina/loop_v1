import 'package:flutter/material.dart';
// import 'package:loop_application/views/deadline_tab.dart';
import 'package:loop_application/views/personal_tab.dart';
import 'package:loop_application/views/task_tab.dart';
import 'package:loop_application/views/team_tab.dart';

class NavBar extends StatefulWidget {
  const NavBar({super.key});

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.only(top: 10, right: 25, bottom: 20, left: 25),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          border: BorderDirectional(
            bottom: BorderSide(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TaskTab()),
                );
              },
              child: Icon(Icons.task_alt_outlined, size: 25),
            ),
            // GestureDetector(
            //   onTap: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(builder: (context) => DeadlineTab()),
            //     );
            //   },
            //   child: Icon(Icons.timelapse_outlined, size: 25),
            // ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamTab()),
                );
              },
              child: Icon(Icons.group_outlined, size: 25),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PersonalTab()),
                );
              },
              child: Icon(Icons.person_outline, size: 25),
            ),
          ],
        ),
      ),
    );
  }
}
