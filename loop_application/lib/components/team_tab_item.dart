import 'package:flutter/material.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:loop_application/views/team_view.dart';

class TeamTabItem extends StatelessWidget {
  final String teamId;
  final String teamName;
  final int memberCount;
  const TeamTabItem({
    super.key,
    required this.teamName,
    required this.memberCount,
    required this.teamId,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (BuildContext context) {
              return TeamView(
                teamId: teamId,
              ); // Replace with actual team members
            },
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(teamName, style: normalText),
                Text(
                  '${memberCount.toString()} thành viên',
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primaryContainer,
                  ),
                ),
              ],
            ),
            Icon(Icons.more_vert_outlined, size: 30),
          ],
        ),
      ),
    );
  }
}
