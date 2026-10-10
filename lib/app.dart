import 'package:flutter/material.dart';
import 'features/tasks/screens/task_list_screen.dart';

/// Корневой виджет приложения: тема, заголовок, домашний экран.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список задач',
      debugShowCheckedModeBanner: false, // убираем красную ленту отладки
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}