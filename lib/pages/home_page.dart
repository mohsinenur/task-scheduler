import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskController = TextEditingController();
  final _timeController = TextEditingController();


  final List<Task> _tasks = [
    Task(title: 'Meeting with John', time: '9:00 AM'),
    Task(title: 'Grocery Shopping', time: '12:00 PM'),
    Task(title: 'Call Mom', time: '3:00 PM'),
  ];

  Future<void> initializeDatabase() async {
    var directory = await getApplicationDocumentsDirectory();
    var dbPath = '${directory.path}/tasks.db';
    Database db = await openDatabase(dbPath, version: 1, onCreate: _onCreate);
  }

  void _onCreate(Database db, int version) async {
      await db.execute(
          'CREATE TABLE tasks (id INTEGER PRIMARY KEY, title TEXT, time TEXT)');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Scheduler'),
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                return TaskCard(
                  taskTitle: _tasks[index].title,
                  taskTime: _tasks[index].time,
                );
              },
            ),
          ),
          addTaskButton(),
        ],
      ),
    );
  }

  Widget addTaskButton() {
    return Container(
      alignment: Alignment.center,
      child: OutlinedButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Add Task'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      controller: _taskController,
                      decoration: const InputDecoration(hintText: 'Task Title'),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _timeController,
                      decoration: const InputDecoration(hintText: 'Task Time'),
                    ),
                  ],
                ),
                actions: <Widget>[
                  OutlinedButton(
                    child: const Text('Save'),
                    onPressed: () {
                      if (_taskController.text.isNotEmpty &&
                          _timeController.text.isNotEmpty) {
                        setState(() {
                          _tasks.add(Task(
                            title: _taskController.text,
                            time: _timeController.text,
                          ));
                        });
                        _taskController.clear();
                        _timeController.clear();
                      }
                      Navigator.of(context).pop();
                    },
                  ),
                  OutlinedButton(
                    child: const Text('Cancel'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
        },
        child: const Text(
          'Add Task',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );
  }
}

class Task {
  final String title;
  final String time;

  Task({required this.title, required this.time});
}

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String taskTime;

  const TaskCard({super.key, required this.taskTitle, required this.taskTime});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            taskTitle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 8,
          ),
          Text(
            taskTime,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
