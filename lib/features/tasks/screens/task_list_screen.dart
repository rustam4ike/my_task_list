import 'package:flutter/material.dart';
import '../../../models/task.dart';
import '../../../services/task_repository.dart';
import '../widgets/task_input_field.dart';
import '../widgets/task_item.dart';
import '../widgets/edit_task_dialog.dart';

/// Главный экран приложения.
/// Держит состояние (список задач), общается с репозиторием,
/// а виджеты только отображают данные.
class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  final TaskRepository _repository = TaskRepository();
  final TextEditingController _controller = TextEditingController();
  List<Task> _tasks = [];
  bool _isLoading = true; // пока идёт загрузка из БД — показываем крутилку

  @override
  void initState() {
    super.initState();
    _loadTasks(); // загружаем задачи при первом открытии экрана
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Читает все задачи из БД и обновляет UI.
  /// Вызывается после каждого изменения (add/update/delete).
  Future<void> _loadTasks() async {
    final tasks = await _repository.getAll();
    setState(() {
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _addTask() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return; // пустые задачи не добавляем
    await _repository.add(text);
    _controller.clear();
    await _loadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    // copyWith создаёт новый объект с противоположным isDone.
    final updated = task.copyWith(isDone: !task.isDone);
    await _repository.update(updated);
    await _loadTasks();
  }

  Future<void> _editTask(Task task) async {
    // showDialog<String> вернёт то, что мы передадим в Navigator.pop.
    final newTitle = await showDialog<String>(
      context: context,
      builder: (_) => EditTaskDialog(initialTitle: task.title),
    );

    if (newTitle != null && newTitle.isNotEmpty) {
      final updated = task.copyWith(title: newTitle);
      await _repository.update(updated);
      await _loadTasks();
    }
  }

  // DELETE — удаление задачи с подтверждением.
  Future<void> _deleteTask(Task task) async {
    // Показываем диалог и ждём ответа пользователя.
    // showDialog<bool> вернёт true, если нажали "Удалить", и false/null, если отменили.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Удалить задачу?'),
        // Показываем название задачи, чтобы пользователь понимал, что удаляет.
        content: Text('«${task.title}» будет удалена безвозвратно.'),
        actions: [
          // Кнопка отмены — возвращаем false.
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          // Кнопка удаления — возвращаем true.
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    // Если пользователь закрыл диалог или нажал "Отмена" — ничего не делаем.
    if (confirmed != true) return;

    // Пользователь подтвердил — удаляем задачу из базы.
    await _repository.delete(task.id!);
    await _loadTasks();

    // Проверяем, что виджет ещё существует, прежде чем показывать SnackBar.
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Задача удалена'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои задачи'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          // Поле ввода всегда сверху.
          TaskInputField(controller: _controller, onSubmit: _addTask),

          // Список занимает всё оставшееся место.
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(
                        child: Text(
                          'Пока нет задач.\nДобавьте первую!',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return TaskItem(
                            task: task,
                            onToggle: () => _toggleTask(task),
                            onEdit: () => _editTask(task),
                            onDelete: () => _deleteTask(task),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}