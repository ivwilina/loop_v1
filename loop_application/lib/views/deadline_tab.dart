// import 'package:flutter/material.dart';
// import 'package:loop_application/components/deadline_tab_item.dart';
// import 'package:loop_application/components/floating_add_button.dart';
// import 'package:loop_application/models/task.dart';
// import 'package:loop_application/controllers/task_model.dart';
// import 'package:loop_application/theme/theme.dart';
// import 'package:provider/provider.dart';
// // import 'package:loop_application/theme/theme.dart';

// class DeadlineTab extends StatefulWidget {
//   const DeadlineTab({super.key});

//   @override
//   State<DeadlineTab> createState() => _DeadlineTabState();
// }

// class _DeadlineTabState extends State<DeadlineTab> {
//   void fetchTasksWithDeadline() {
//     Provider.of<TaskModel>(context, listen: false).fetchTaskWithDeadline();
//   }

//   @override
//   void initState() {
//     // TODO: implement initState
//     super.initState();
//     fetchTasksWithDeadline();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final taskModel = context.watch<TaskModel>();

//     List<Task> tasks = taskModel.currentTaskHaveDeadline;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Nhiệm vụ có thời hạn"),
//         backgroundColor: Theme.of(context).colorScheme.primary,
//       ),

//       //TODO: notice
//       floatingActionButton: FloatingAddButton(
//         defaultNewTaskDate: DateTime.now(),
//       ),
//       body:
//           tasks.isEmpty
//               ? Container(
//                 width: MediaQuery.of(context).size.width,
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
//                 decoration: BoxDecoration(
//                   color: Theme.of(context).colorScheme.primary,
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   spacing: 10,
//                   children: [
//                     Text(
//                       "Không có nhiệm vụ nào có thời hạn",
//                       style: normalText,
//                     ),
//                   ],
//                 ),
//               )
//               : ListView(
//                 //TODO: Make this dynamic
//                 //TODO: Make a search bar
//                 children: [
//                   Column(
//                     children:
//                         tasks.map((task) {
//                           return DeadlineTabItem(task: task);
//                         }).toList(),
//                   ),
//                   SizedBox(height: 100),
//                 ],
//               ),
//     );
//   }
// }
