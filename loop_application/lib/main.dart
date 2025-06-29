import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:isar/isar.dart';
import 'package:loop_application/controllers/user_controller.dart';
import 'package:loop_application/models/category.dart';
import 'package:loop_application/controllers/category_model.dart';
import 'package:loop_application/models/subtask.dart';
import 'package:loop_application/controllers/subtask_model.dart';
import 'package:loop_application/models/task.dart';
import 'package:loop_application/controllers/task_model.dart';
import 'package:loop_application/models/user.dart';
import 'package:loop_application/theme/theme_controller.dart';
import 'package:path_provider/path_provider.dart';
import './views/home_tab.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  //* init everything
  WidgetsFlutterBinding.ensureInitialized();
  final dir = await getApplicationDocumentsDirectory();
  final isar = await Isar.open([
    CategorySchema,
    TaskSchema,
    SubtaskSchema,
    UserSchema,
  ], directory: dir.path);
  await CategoryModel.initialize(isar);
  await TaskModel.initialize(isar);
  await SubtaskModel.initialize(isar);
  await UserController.initialize(isar);
  await initializeDateFormatting('vi_VN');
  runApp(
    //* Providers to control the app
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => ThemeController()),
        ChangeNotifierProvider(create: (context) => CategoryModel()),
        ChangeNotifierProvider(create: (context) => TaskModel()),
        ChangeNotifierProvider(create: (context) => UserController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeController>(context).themeData,
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('en'), // English
        Locale('es'), // Spanish
        Locale('vi'), // Vietnamese
      ],
      home: const HomeTab(),
    );
  }
}
