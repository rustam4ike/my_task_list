import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/task.dart';

/// Репозиторий — прослойка между приложением и базой данных.
/// UI не знает, как именно хранятся данные, он просто вызывает эти методы.
class TaskRepository {
  // Статическое поле — база создаётся один раз на всё приложение.
  static Database? _db;

  /// Ленивая инициализация: если база ещё не открыта — открываем.
  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDb();
    return _db!;
  }

  /// Создаёт (или открывает) файл базы данных.
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'tasks.db');

    return await openDatabase(
      path,
      version: 1, // при изменении схемы нужно будет увеличить
      onCreate: (db, version) async {
        // Эта таблица создаётся один раз при первом запуске.
        await db.execute('''
          CREATE TABLE tasks(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            isDone INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  /// Возвращает все задачи.
  /// Сортировка: сначала невыполненные (isDone = 0), потом выполненные.
  /// Внутри каждой группы — новые сверху (id DESC).
  Future<List<Task>> getAll() async {
    final db = await database;
    final maps = await db.query('tasks', orderBy: 'isDone ASC, id DESC');
    return maps.map((m) => Task.fromMap(m)).toList();
  }

  /// Добавляет задачу и возвращает её же, но уже с id из базы.
  Future<Task> add(String title) async {
    final db = await database;
    final task = Task(title: title);
    final id = await db.insert('tasks', task.toMap());
    return task.copyWith(id: id);
  }

  /// Обновляет существующую задачу (название или статус).
  Future<void> update(Task task) async {
    final db = await database;
    await db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  /// Удаляет задачу по id.
  Future<void> delete(int id) async {
    final db = await database;
    await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }
}