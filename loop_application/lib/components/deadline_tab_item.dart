// import 'package:flutter/material.dart';
// import 'package:flutter_slidable/flutter_slidable.dart';
// import 'package:loop_application/models/task.dart';
// import 'package:loop_application/controllers/task_model.dart';
// import 'package:loop_application/theme/theme.dart';
// import 'package:loop_application/views/task_view.dart';
// import 'package:provider/provider.dart';

// class DeadlineTabItem extends StatefulWidget {
//   final Task task;

//   const DeadlineTabItem({super.key, required this.task});

//   @override
//   State<DeadlineTabItem> createState() => _DeadlineTabItemState();
// }

// class _DeadlineTabItemState extends State<DeadlineTabItem> {
//   @override
//   Widget build(BuildContext context) {
//     String deadlineBannerText;

//     DateTime? tempDeadline = widget.task.deadline;
//     if (widget.task.isCompleted) {
//       deadlineBannerText = "Đã hoàn thành";
//     } else if (tempDeadline!.isBefore(DateTime.now())) {
//       final daysLeft = tempDeadline.difference(DateTime.now());
//       final formattedDaysLeft =
//           '${daysLeft.inDays} ngày ${daysLeft.inHours % 24} giờ ${daysLeft.inMinutes % 60} phút';
//       deadlineBannerText = "Quá hạn $formattedDaysLeft";
//     } else {
//       final daysLeft = tempDeadline.difference(DateTime.now());
//       final formattedDaysLeft =
//           '${daysLeft.inDays} ngày ${daysLeft.inHours % 24} giờ ${daysLeft.inMinutes % 60} phút';
//       deadlineBannerText = "Còn $formattedDaysLeft";
//     }

//     return Slidable(
//       child: GestureDetector(
//         onTap: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//               builder: (context) {
//                 return TaskView(taskId: widget.task.id);
//               },
//             ),
//           );
//         },
//         child: Container(
//           decoration: BoxDecoration(
//             color: Theme.of(context).colorScheme.primary,
//           ),
//           child: Column(
//             children: [
//               Container(
//                 decoration: BoxDecoration(
//                   color:
//                       widget.task.isCompleted
//                           ? Theme.of(context).colorScheme.primaryContainer
//                           : Colors.red,
//                 ),
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   spacing: 10,
//                   children: [
//                     if(widget.task.isCompleted) Icon(
//                       Icons.done_all_outlined,
//                       color: const Color(0xFFFFFFFF),
//                     )
//                     else
//                       Icon(
//                         Icons.timelapse_outlined,
//                         color: const Color(0xFFFFFFFF),
//                       ),
//                     Text(
//                       deadlineBannerText,
//                       style: TextStyle(
//                         fontSize: 16,
//                         color: const Color(0xFFFFFFFF),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.start,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   spacing: 10,
//                   children: [
//                     if (widget.task.isCompleted)
//                       GestureDetector(
//                         onTap: () {
//                           Provider.of<TaskModel>(
//                             context,
//                             listen: false,
//                           ).checkCompletedTask(widget.task);
//                         },
//                         child: Icon(
//                           Icons.task_alt_outlined,
//                           color: Theme.of(context).colorScheme.primaryContainer,
//                         ),
//                       )
//                     else
//                       GestureDetector(
//                         onTap: () {
//                           Provider.of<TaskModel>(
//                             context,
//                             listen: false,
//                           ).checkCompletedTask(widget.task);
//                         },
//                         child: Icon(Icons.circle_outlined),
//                       ),
//                     Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           width: MediaQuery.of(context).size.width - 100,
//                           child: Text(
//                             widget.task.title,
//                             style: normalText,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                           ),
//                         ),
//                         Text(
//                           "${widget.task.subtasks.length.toString()} subtasks",
//                           style: TextStyle(
//                             fontSize: 16,
//                             color:
//                                 Theme.of(context).colorScheme.primaryContainer,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
