import 'package:flutter/material.dart';
import '../../../models/task.dart';

/// Отдельный виджет для одной строки списка.
/// Вынесен отдельно, чтобы ListView.builder оставался чистым.
class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onToggle; // что делать при клике на чекбокс
  final VoidCallback onEdit;   // что делать при клике на карандаш
  final VoidCallback onDelete; // что делать при клике на корзину

  const TaskItem({
    super.key,
    required this.task,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final done = task.isDone;

    // AnimatedContainer плавно анимирует изменения своих свойств.
    // Здесь анимируется цвет фона при переключении isDone.
    // duration — сколько миллисекунд длится анимация.
    // curve — кривая анимации (easeInOut — плавное начало и конец).
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        // Цвет фона: светло-зелёный для выполненных, прозрачный для остальных.
        color: done ? Colors.green.shade50 : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        // Чекбокс для отметки выполнения.
        leading: Checkbox(
          value: done,
          onChanged: (_) => onToggle(),
        ),
        title: AnimatedDefaultTextStyle(
          // Текст тоже анимируется: зачёркивание и цвет меняются плавно.
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          style: TextStyle(
            fontSize: 16,
            decoration: done ? TextDecoration.lineThrough : TextDecoration.none,
            color: done ? Colors.grey : Colors.black87,
          ),
          child: Text(task.title),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Кнопка редактирования.
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: onEdit,
            ),
            // Кнопка удаления.
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}