import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import './notification_service.dart';
import 'package:workmanager/workmanager.dart';
import 'task_service.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    await NotificationService.init();
    await TaskService.checkAndSendNotifications();
    return Future.value(true);
  });
}

void scheduleBackgroundTask() {
  Workmanager().registerPeriodicTask(
    "task_check",
    "checkForReminders",
    frequency: Duration(minutes: 15), // Runs every 15 minutes
    existingWorkPolicy: ExistingWorkPolicy.replace, // Ensures only one task runs
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.init();
  await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
  
  scheduleBackgroundTask();

  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Tasks Summary'),
    );
  }
}
