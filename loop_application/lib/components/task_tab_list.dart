import 'package:flutter/material.dart';
// import 'package:loop_application/components/task_tab_task_item.dart';
import 'package:loop_application/theme/theme.dart';

class TaskTabList extends StatelessWidget {
  const TaskTabList({super.key});

  @override
  Widget build(BuildContext context) {
    // var screenWidth = MediaQuery.sizeOf(context).width;

    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Yêu thích", style: normalText),
                Row(
                  spacing: 25,
                  children: [
                    Icon(Icons.grid_view_outlined),
                    Icon(Icons.more_vert_outlined),
                  ],
                ),
              ],
            ),
          ),
          Expanded(child: ListView(children: [])),
        ],
      ),
    );
  }
}
