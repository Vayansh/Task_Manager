import 'package:flutter/material.dart';
import 'package:task_manager/database_helper.dart';

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
  void initState(){
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
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: Text("Add Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              TextField(
                controller:titleController,
                                  decoration: InputDecoration(hintText: "Enter task title")),
              SizedBox(height: 15,),
              TextField(
                controller:descriptionController,
                                  decoration: InputDecoration(hintText: "Enter task description")),
          ],
        ),
        
    
        actions: [
          TextButton(
            onPressed:() async {
              if(titleController.text.isNotEmpty){
                await DatabaseHelper().insertTask(titleController.text, descriptionController.text);
                Navigator.pop(context);
                _loadTasks();
              }
            },
            child: Text("Add"),
          )
        ],
      )
      );
  }

  Future<void> _updateTask(int id) async {
    Map<String, dynamic>? task = await DatabaseHelper().getTask(id);
    TextEditingController titleController = TextEditingController(text: task==null?'':task['title']);
    TextEditingController descriptionController = TextEditingController(text: task==null?'':task['description']);
    
    showDialog(
      context: context, 
      builder: (context)=> AlertDialog(
        title: Text("Update Task"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
              TextField(
                controller:titleController,
                                  decoration: InputDecoration(hintText: "Update task title")),
              SizedBox(height: 15,),
              TextField(
                controller:descriptionController,
                                  decoration: InputDecoration(hintText: "Update task description")),
          ],
        ),
        
    
        actions: [
          TextButton(
            onPressed:() async {
              if(titleController.text.isNotEmpty){
                await DatabaseHelper().updateTask(id,titleController.text);
              }
              if(descriptionController.text.isNotEmpty){
                await DatabaseHelper().updateDescription(id, descriptionController.text);
              }
              Navigator.pop(context);
              _loadTasks();
            },
            child: Text("Update"),
          )
        ],
      )
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context,index){
          final task = tasks[index];
          return ListTile(
            title: Text(task['title']),
            subtitle: Text(task['description']),
            leading: Checkbox(value: task['isCompleted']==1, 
                              onChanged: (value) => _toggleTaskCompletion(task['id'],task['isCompleted'])),
            onTap: () => _updateTask(task['id']),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red,),
              onPressed: () => _deleteTask(task['id']),
              ), 
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
