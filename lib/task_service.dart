// import 'package:sqflite/sqflite.dart';
// import 'package:path/path.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'notification_service.dart';

// class TaskService {

//   static Future<Database> getDatabase() async {
//     return openDatabase(
//       join(await getDatabasesPath(), 'tasks.db'),
//     );
//   }

//   static Future<void> checkAndSendNotifications() async {
//     final db = await getDatabase();
//     final now = DateTime.now().toIso8601String();

//     final List<Map<String, dynamic>> reminders = await db.query(
//       'reminders',
//       where: "reminder_time <= ? AND isNotified = 0",
//       whereArgs: [now],
//     );

//     for (var reminder in reminders) {
//       final List<Map<String, dynamic>> task = await db.query(
//         'tasks',
//         where: "id = ?",
//         whereArgs: [reminder['task_id']],
//         limit: 1,
//       );

//       if (task.isNotEmpty) {
//         await NotificationService.scheduleNotification(
//           reminder['id'],
//           task.first['name'],
//           task.first['description'],
//           tz.TZDateTime.now(tz.local),
//         );

//         // Mark as notified
//         await db.update(
//           'reminders',
//           {'isNotified': 1},
//           where: "id = ?",
//           whereArgs: [reminder['id']],
//         );
//       }
//     }
//   }
// }
