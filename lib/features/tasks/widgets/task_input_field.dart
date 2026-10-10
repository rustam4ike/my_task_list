import 'package:flutter/material.dart';

/// Верхняя панель с полем ввода и кнопкой "плюс".
/// Отдельный виджет — чтобы экран не разрастался.
class TaskInputField extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSubmit; // вызывается при нажатии кнопки или Enter

  const TaskInputField({
    super.key,
    required this.controller,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        children: [
          // Поле ввода растягивается на всё свободное место.
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: 'Введите задачу...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 14,
                ),
              ),
              // Enter тоже добавляет задачу — удобно на десктопе.
              onSubmitted: (_) => onSubmit(),
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(
            onPressed: onSubmit,
            style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
            ),
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}