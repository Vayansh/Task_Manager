import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async{
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async{
    String path = join(await getDatabasesPath(),'tasks.db');
    return await openDatabase(
      path,
       version: 1,
       onCreate: (db, version) {
        return db.execute(
        "CREATE TABLE tasks(id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description Text isCompleted INTEGER)"
        );
       },
      );
  }

  Future<int> insertTask(String title, String description) async{
    final db = await database;
    return await db.insert('tasks',{'title':title,
     'description': description, 
     'isCompleted':0});
  }

  Future<List<Map<String, dynamic>>> getTasks() async{
    final db = await database;
    return await db.query('tasks');
  } 

  Future<int> markTaskCompleted(int id, int isCompleted) async{
    final db = await database;
    return await db.update('tasks', 
      {'isCompleted':isCompleted},
      where:'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> updateTask(int id, String title) async{
    final db = await database;
    return await db.update('tasks',
      {'title':title},
      where: 'id = ?',whereArgs: [id]);
    }
  Future<int> updateDescription(int id, String description) async {
    final db = await database;
    return await db.update('tasks',
      {'description':description},
      where: 'id = ?',
      whereArgs: [id]
    );
  }

  Future<int> deleteTask(int id) async{
    final db = await database;
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = 
        await db.query('tasks', where: 'id = ?', whereArgs: [id]);

    if (result.isNotEmpty) {
      return result.first; // Return the first row if exists
    }
    return null; // Return null if no matching row is found
  }

}
