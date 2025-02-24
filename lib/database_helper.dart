import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import './notification_service.dart';

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
       onCreate: (db,version) async 
       { 
        await _createTables(db);
       },
      );
  }
  Future<void> _createTables(Database db) async {
    await db.execute(
     '''CREATE TABLE tasks(
      id INTEGER PRIMARY KEY AUTOINCREMENT, title TEXT, description Text isCompleted INTEGER
      )''');

    await db.execute(
      ''' CREATE TABLE reminders(id INTEGER PRIMARY KEY AUTOINCREMENT, 
        task_id INTEGER,
        reminder_time TEXT,
        isNotified INTEGER DEFAULT 0,
        FOREIGN KEY (task_id) REFERENCES tasks (id) ON DELETE CASCADE
        )
      '''
    );
  }

  Future<int> insertTask(String title, String description) async{
    final db = await database;
    return await db.insert('tasks',{'title':title,
     'description': description, 
     'isCompleted':0});
  }

  Future<void> insertReminder(int taskId, DateTime reminder) async {
    final db = await database;
    int id = await db.insert('reminders', {
      'task_id': taskId,
      'reminder_time': reminder.toIso8601String(),
      'isNotified': 0
    });
    Map<String, dynamic>? task = await getTask(taskId);
    if(task!=null){
      await NotificationService.scheduleNotification(
          taskId,
          task['title'], 
          task['description'], 
          reminder);
      
       await db.update(
          'reminders',
          {'isNotified': 1},
          where: "id = ?",
          whereArgs: [id],
        );
    }
  }

  Future<int> insertReminders(int taskId, String title, String description, List<DateTime> reminders) async{
    final db = await database;
    for(var reminder in reminders){
      int id = await db.insert('reminders', {
                                      'task_id': taskId, 
                                      'reminder_time':reminder.toIso8601String(),
                                      'idNotified':0
                                      }
                    );
      await NotificationService.scheduleNotification(
        id,
        title, 
        description, 
        reminder);
      
      await db.update(
          'reminders',
          {'isNotified': 1},
          where: "id = ?",
          whereArgs: [id],
        );
    } 
    return taskId;
  }

  Future<void> deleteReminder(int reminderId) async {
    final db = await database;

    // Cancel the notification before deleting the reminder
    await NotificationService.cancelNotification(reminderId);

    await db.delete('reminders', where: 'id = ?', whereArgs: [reminderId]);
  }

  Future<List<Map<String, dynamic>>> getReminders(int id) async {
    final db = await database;
    return await db.query('reminders',
      where: 'task_id = ?',
      whereArgs: [id]
    );
  }

  Future<Map<String, dynamic>?> getTask(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> result = 
        await db.query('tasks', where: 'id = ?', whereArgs: [id]);
    return result.first; 
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
    List<Map<String, dynamic>>? reminders = await db.query('reminders',
                                                            where: 'task_id = ?',
                                                            whereArgs: [id]
                                                          );
    for(var reminder in reminders){
      deleteReminder(reminder['id']);
    }
    
    return await db.delete('tasks', where: 'id = ?', whereArgs: [id]);
  }


}
