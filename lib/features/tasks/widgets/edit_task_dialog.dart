import 'package:flutter/material.dart';

/// Диалог редактирования задачи.
/// Сделан StatefulWidget, потому что содержит TextEditingController,
/// который нужно корректно освобождать в dispose().
class EditTaskDialog extends StatefulWidget {
  final String initialTitle;

  const EditTaskDialog({super.key, required this.initialTitle});

  @override
  State<EditTaskDialog> createState() => _EditTaskDialogState();
}

class _EditTaskDialogState extends State<EditTaskDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    // Сразу подставляем текущее название задачи.
    _controller = TextEditingController(text: widget.initialTitle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Редактировать задачу'),
      content: TextField(
        controller: _controller,
        autofocus: true, // курсор сразу в поле
        decoration: const InputDecoration(hintText: 'Новое название'),
      ),
      actions: [
        TextButton(
          // Закрываем диалог, ничего не возвращая (значит, отмена).
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final text = _controller.text.trim();
            if (text.isNotEmpty) {
              // Возвращаем новое название в вызывающий код.
              // Именно его поймает showDialog<String>() на экране.
              Navigator.pop(context, text);
            }
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}