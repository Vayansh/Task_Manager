import 'package:flutter/material.dart';
import 'package:task_manager/database_helper.dart';
import 'package:intl/intl.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Map<String, dynamic>> tasks = [];
  
  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async{
    tasks = await DatabaseHelper().getTasks();
    setState(() {});
  }

  Future<void> _addTask() async{
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    List<DateTime> selectedReminders = [];

    showDialog(
      context: context, 
      builder: (context)=> StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
              backgroundColor: const Color.fromARGB(161, 45, 88, 128),
              title: Text("Add Task",
                        style: TextStyle(
                            color: Colors.white
                        ),),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                    TextField(
                      controller:titleController,
                                        decoration: InputDecoration(hintText: "Enter task title",hintStyle: TextStyle(color: const Color.fromARGB(133, 255, 255, 255))),
                                        style: TextStyle(
                                              color: Colors.white
                                          ),
                      ),
                    SizedBox(height: 15,),
                    TextField(
                      controller:descriptionController,
                                        decoration: InputDecoration(hintText: "Enter task description",hintStyle: TextStyle(color: const Color.fromARGB(133, 255, 255, 255))),
                                        style: TextStyle(
                            color: Colors.white
                        ),),
                    SizedBox(height: 30,),
                    Text(
                        'Reminders',
                        style: TextStyle(
                                  fontWeight: FontWeight.bold, 
                                  fontSize: 16,
                                  color: Colors.white),
                      ),
                      SizedBox(height: 10),
                      
                      // Show list of reminders with delete option
                      Column(
                        children: selectedReminders.map((reminder) {
                          String formattedTime = DateFormat('hh:mm a, EEEE dd MMM').format(reminder);

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 3,
                            color: Colors.grey[900],
                            margin: EdgeInsets.symmetric(vertical: 5),
                            child: ListTile(
                              title: Text(formattedTime,style: TextStyle(color: Colors.white),),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () async {
                                  setState(() {
                                    selectedReminders.remove(reminder);
                                  });
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: 15),
                    ElevatedButton(
                    onPressed: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime(2100),
                      );

                      if (pickedDate != null) {
                        TimeOfDay? pickedTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );

                        if (pickedTime != null) {
                          DateTime finalDateTime = DateTime(
                            pickedDate.year,
                            pickedDate.month,
                            pickedDate.day,
                            pickedTime.hour,
                            pickedTime.minute,
                          );

                          setState(() {
                            selectedReminders.add(finalDateTime);
                          });
                        }
                      }
                    },
                    child: Text("Add Reminder", 
                                  style: TextStyle(
                                            color: Colors.white,
                                          ),
                                  
                                ),
                    style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(52, 55, 59, 0.867)),
                  ),

          ],
        ),
        
    
        actions: [
          TextButton(
            onPressed:() async {
              if(titleController.text.isNotEmpty){
                int id = await DatabaseHelper().insertTask(titleController.text, descriptionController.text);
                await DatabaseHelper().insertReminders(id, titleController.text, descriptionController.text, selectedReminders);
  
                Navigator.pop(context);
                _loadTasks();
              }
            },
            child: Text("Add",
                    style: TextStyle(color: Colors.white),),
          )
        ],
       );
      },
     ),
    );
  }

  Future<void> _updateTask(int id) async {
  Map<String, dynamic>? task = await DatabaseHelper().getTask(id);
  List<Map<String, dynamic>> reminders = await DatabaseHelper().getReminders(id);

  TextEditingController titleController =
      TextEditingController(text: task == null ? '' : task['title']);
  TextEditingController descriptionController =
      TextEditingController(text: task == null ? '' : task['description']);

  List<Map<String, dynamic>> selectedReminders = List.from(reminders);

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          backgroundColor: const Color.fromARGB(161, 45, 88, 128),
          title: Text("Update Task",
                  style: TextStyle(
                    color: Colors.white,

                  ),),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(hintText: "Update task title"),
                  style: TextStyle(
                    color: Colors.white
                  ),
                  
                ),
                SizedBox(height: 15),
                TextField(
                  controller: descriptionController,
                  decoration: InputDecoration(hintText: "Update task description"),
                  style: TextStyle(
                    color: Colors.white
                  ),
                ),
                SizedBox(height: 30),
                Text(
                  'Reminders',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16,color: Colors.white),
                ),
                SizedBox(height: 10),
                
                // Show list of reminders with delete option
                Column(
                  children: selectedReminders.map((reminder) {
                    DateTime reminderTime = DateTime.parse(reminder['reminder_time']);
                    String formattedTime = DateFormat('hh:mm a, EEEE dd MMM').format(reminderTime);

                    return Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      color: Colors.grey[900],
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text(formattedTime,style: TextStyle(color: Colors.white),),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            if (reminder['id'] != null) {
                              await DatabaseHelper().deleteReminder(reminder['id']);
                            }
                            setState(() {
                              selectedReminders.remove(reminder);
                            });
                          },
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 15),

                // Button to add new reminder
                ElevatedButton(
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );

                    if (pickedDate != null) {
                      TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );

                      if (pickedTime != null) {
                        DateTime finalDateTime = DateTime(
                          pickedDate.year,
                          pickedDate.month,
                          pickedDate.day,
                          pickedTime.hour,
                          pickedTime.minute,
                        );

                        setState(() {
                          selectedReminders.add({
                            'id': null,
                            'reminder_time': finalDateTime.toIso8601String(),
                          });
                        });
                      }
                    }
                  },
                  child: Text("Add Reminder", 
                              style: TextStyle(
                                        color: Colors.white,
                                      ),
                              
                            ),
                  style: ElevatedButton.styleFrom(backgroundColor: Color.fromRGBO(52, 55, 59, 0.867)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (titleController.text.isNotEmpty) {
                  await DatabaseHelper().updateTask(id, titleController.text);
                }
                if (descriptionController.text.isNotEmpty) {
                  await DatabaseHelper().updateDescription(id, descriptionController.text);
                }
                for (var reminder in selectedReminders) {
                  if (reminder['id'] == null) {
                    await DatabaseHelper().insertReminder(
                        id, DateTime.parse(reminder['reminder_time']));
                  }
                }
                Navigator.pop(context);
                _loadTasks(); // Refresh tasks after update
              },
              child: Text("Update", 
                          style: TextStyle(
                                  color: Colors.white
                                  ),
                        ),
            ),
          ],
        );
      },
    ),
  );
}

  Future<void> _toggleTaskCompletion(int id, int isCompleted) async{
      await DatabaseHelper().markTaskCompleted(id, (isCompleted==1)?0:1);
      _loadTasks();
  }

  Future<void> _deleteTask(int id) async {
    await DatabaseHelper().deleteTask(id);
    _loadTasks();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blueAccent,
          centerTitle: true, // Centers title in AppBar
          title: Text(
            widget.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,  // Increase text size
              fontWeight: FontWeight.bold, // Make text bold
              fontFamily: 'PlayfairDisplay' // Optional: Make text bold
            ),
          ),
        ),
      backgroundColor: Colors.black,
      body: 
        Padding(
            padding: EdgeInsets.only(top: 20),
            child:Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: tasks.map((task) {
                return Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 2,
                  color: Colors.grey[900], // Dark card background
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 15), // Increase card height
                    child: ListTile(
                      leading: Checkbox(
                        value: task['isCompleted'] == 1,
                        onChanged: (value) => _toggleTaskCompletion(task['id'], task['isCompleted']),
                        checkColor: Colors.black, // Checkmark color
                        activeColor: Colors.white, // Checkbox background color
                      ),
                      title: Text(
                        task['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white, // Set text color to white
                        ),
                      ),
                      subtitle: Text(
                        task['description'],
                        style: TextStyle(color: Colors.white70), // Slightly lighter white
                      ),
                      onTap: () => _updateTask(task['id']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteTask(task['id']),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
