import 'package:flutter/material.dart';
import 'widgets/task_statistics_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Task Statistics',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: TestStatisticsPage(),
    );
  }
}

class TestStatisticsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Test Task Statistics'),
      ),
      body: TaskStatisticsWidget(
        projectId: 'test-project-id', // Thay bằng project ID thực tế
      ),
    );
  }
}
