import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_project_example/models/node_model.dart';

class DatabaseLocal {
  static final _databaseName = 'notess.db'; //название бд
  static final _databaseVersion = 1; //версия бд

  static final table = 'notes'; //название таблицы

  //название столбцов в таблице
  static final columnId = 'id';
  static final columnTitle = 'title';
  static final columnContent = 'content';

  //Сделать класс синглтоном (ограничить его создание одним экземпляром)
  DatabaseLocal._privateConstructor();
  static final DatabaseLocal instance = DatabaseLocal._privateConstructor();

  //одна ссылка на бд в приложении
  static Database? _database;

  //геттер на получение базы данных
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDatabase();
    return _database!;
  }

  //Инициализируем базу данных и создаем таблицу, если она еще не создана
  _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion,
        onCreate: ((db, version) {
      db.execute(
          'CREATE TABLE $table ($columnId INTEGER PRIMARY KEY, $columnTitle TEXT NOT NULL, $columnContent TEXT NOT NULL)');
    }));
  }

  //Метод добавления новой записи в таблицу
  Future<int> insert(NoteModel note) async {
    Database db = await database;
    return await db.insert(table, note.toMap());
  }

  //Метод удаления записи по id
  Future<int> delete(int id) async {
    return await _database!
        .delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  //Метод обновления записи по id
  Future<int> update(NoteModel note) async {
    return await _database!.update(table, note.toMap(),
        where: '$columnId = ?', whereArgs: [note.id]);
  }

  //Метод получение записей из таблицы notes
  Future<List<NoteModel>> getNotes() async {
    Database db = await database;
    List<Map<String, dynamic>> maps = await db.query(table);
    return List.generate(
        maps.length,
        (index) => NoteModel(
            title: maps[index][columnTitle],
            content: maps[index][columnContent],
            id: maps[index][columnId]));
  }
}
