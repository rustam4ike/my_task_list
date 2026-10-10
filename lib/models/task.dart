/// Модель одной задачи.
/// Это обычный Dart-класс, не виджет. Отвечает только за данные.
class Task {
  final int? id;      // null, пока задача не сохранена в БД
  String title;       // название задачи
  bool isDone;        // выполнена или нет

  Task({
    this.id,
    required this.title,
    this.isDone = false,
  });

  /// Преобразует объект в Map для записи в SQLite.
  /// SQLite не умеет хранить bool — храним как 0/1.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'isDone': isDone ? 1 : 0,
    };
  }

  /// Обратное преобразование: из строки БД в объект Task.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] as int?,
      title: map['title'] as String,
      isDone: (map['isDone'] as int) == 1,
    );
  }

  /// Создаёт копию объекта с изменёнными полями.
  /// Удобно, когда нужно поменять только isDone или только title.
  Task copyWith({int? id, String? title, bool? isDone}) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      isDone: isDone ?? this.isDone,
    );
  }
}