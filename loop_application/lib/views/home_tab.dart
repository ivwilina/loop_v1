import 'dart:math';

import 'package:flutter/material.dart';
import 'package:loop_application/components/floating_add_button.dart';
import 'package:loop_application/components/home_task_item.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../components/navigation_bar.dart';

class HomeTab extends StatefulWidget {
  const HomeTab({super.key});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {
  String localeFormat = 'vi_VN';
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime dayToViewTask = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.week;

  Map<DateTime, List<String>> customEventList = {};

  void readTasks() {
    Provider.of<TaskModel>(context, listen: false).findAll();
  }

  void readTasksOnSpecificDate(DateTime inputDate) {
    Provider.of<TaskModel>(
      context,
      listen: false,
    ).findByDate(inputDate);
  }

  //* Get tasks then convert to customEventList
  void getCustomEventList(TaskModel taskModel) {
    List<Task> tempList = taskModel.currentTask;
    List<DateTime> datesContainTask = [];
    for (var e in tempList) {
      DateTime checkDate = convertToDefaultDate(e.deadline);
      if (!datesContainTask.contains(checkDate)) {
        datesContainTask.add(checkDate);
      }
    }
    Map<DateTime, List<String>> tempMap = {};
    for (var e in datesContainTask) {
      List<String> taskHolder = [];
      for (var n in tempList) {
          if (e.year == n.deadline.year &&
              e.month == n.deadline.month &&
              e.day == n.deadline.day) {
            if (!taskHolder.contains(n.id.toString())) {
              taskHolder.add(n.id.toString());
            }
          } 
      }
      final event = <DateTime, List<String>>{e: taskHolder};
      tempMap.addEntries(event.entries);
    }
    customEventList = tempMap;
  }

  //* Convert to custom String list then pass it to Table Calendar to view event mark
  List<String> _getEventForDay(DateTime day) {
    return customEventList[day] ?? [];
  }

  DateTime convertToDefaultDate(DateTime dayToConvert) {
    DateTime tempReturnDate = DateTime(
      dayToConvert.year,
      dayToConvert.month,
      dayToConvert.day,
    );
    String tempConvert = tempReturnDate.toString();
    tempConvert += 'Z';
    DateTime returnDate = DateTime.parse(tempConvert);
    return returnDate;
  }

  @override
  void initState() {
    _selectedDay = _focusedDay;
    dayToViewTask = convertToDefaultDate(_focusedDay);
    readTasks();
    readTasksOnSpecificDate(dayToViewTask);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;

    // readTasks();

    // readTasksOnSpecificDate(dayToViewTask);

    final taskModel = context.watch<TaskModel>();

    List<Task> selectedDateTasks = taskModel.taskOnSpecificDay;

    List<Task> pendingTask = [];
    for (var e in selectedDateTasks) {
      if (e.status == 1) {
        pendingTask.add(e);
      }
    }

    List<Task> completedTask = [];
    for (var e in selectedDateTasks) {
      if (e.status == 2) {
        completedTask.add(e);
      }
    }
    // List<Task> currentTasks = taskModel.currentTask;

    getCustomEventList(taskModel);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        flexibleSpace: NavBar(),
      ),
      floatingActionButton: FloatingAddButton(defaultNewTaskDate: _focusedDay),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          //TODO: Make date selectable and show tasks on the choosen date
          TableCalendar(
            focusedDay: _focusedDay,
            currentDay: DateTime.now(),
            firstDay: DateTime(2024),
            lastDay: DateTime(2500),
            startingDayOfWeek: StartingDayOfWeek.monday,
            locale: ('vi_VN'),
            calendarFormat: _calendarFormat,
            onFormatChanged: (format) {
              setState(() {
                _calendarFormat = format;
              });
            },
            selectedDayPredicate: (day) {
              return isSameDay(_selectedDay, day);
            },
            onDaySelected: (selectedDay, focusedDay) {
              if (!isSameDay(_selectedDay, selectedDay)) {
                setState(() {
                  _selectedDay = selectedDay;
                  dayToViewTask = convertToDefaultDate(selectedDay);
                  readTasksOnSpecificDate(dayToViewTask);
                  _focusedDay = focusedDay;
                });
              }
            },
            onPageChanged: (focusedDay) {
              _focusedDay = focusedDay;
            },

            onHeaderTapped: (focusedDay) {
              setState(() {
                focusedDay = DateTime.now();
                dayToViewTask = convertToDefaultDate(focusedDay);
                readTasksOnSpecificDate(dayToViewTask);
                _selectedDay = focusedDay;
                _focusedDay = focusedDay;
              });
            },

            headerStyle: HeaderStyle(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: normalText,
            ),

            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primary,
                border: Border.all(
                  width: 1,
                  color: Theme.of(context).colorScheme.primaryContainer,
                ),
              ),
              todayTextStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              rowDecoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              selectedDecoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              weekendTextStyle: TextStyle(color: const Color(0xFFFF2626)),
            ),

            daysOfWeekStyle: DaysOfWeekStyle(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              weekendStyle: TextStyle(color: const Color(0xFFFF2626)),
              weekdayStyle: TextStyle(
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),

            daysOfWeekHeight: 20,

            rowHeight: 70,

            eventLoader: (day) => _getEventForDay(day),

            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, day, events) {
                if (events.isEmpty) return SizedBox();
                return Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: const Color(0xFFfe8430),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        events.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Expanded(
            child: ListView(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: BorderDirectional(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    'Chưa hoàn thành (${pendingTask.length})',
                    style: normalText,
                  ),
                ),
                Column(
                  children:
                      pendingTask.map((e) {
                        return HomeTaskItem(task: e);
                      }).toList(),
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    border: BorderDirectional(
                      top: BorderSide(
                        color: Theme.of(context).colorScheme.outline,
                        width: 1,
                      ),
                    ),
                  ),
                  width: screenWidth,
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                  child: Text(
                    'Đã hoàn thành (${completedTask.length})',
                    style: normalText,
                  ),
                ),
                Column(
                  children:
                      completedTask.map((e) {
                        return HomeTaskItem(task: e);
                      }).toList(),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
