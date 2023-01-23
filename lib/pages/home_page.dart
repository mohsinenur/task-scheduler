import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _taskController = TextEditingController();
  final _timeController = TextEditingController();

  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _getTasks();
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = json.encode(_tasks);
    prefs.setString('tasks', tasksJson);
  }

  Future<void> _getTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final tasksJson = prefs.getString('tasks');
    if (tasksJson != null) {
      final tasks = json.decode(tasksJson) as List;
      setState(() {
        _tasks = tasks.map((task) => Task.fromJson(task)).toList();
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
    });
    _saveTasks();
  }

  void addTaskButton() {
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
              onPressed: () async {
                if (_taskController.text.isNotEmpty &&
                    _timeController.text.isNotEmpty) {
                  setState(
                    () {
                      _tasks.add(
                        Task(
                          title: _taskController.text,
                          time: _timeController.text,
                            dateTime: DateFormat.yMd().add_jm().format(DateTime.now()),
                        ),
                      );
                    },
                  );
                  _saveTasks();
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Scheduler'),
        actions: <Widget>[
          GestureDetector(
            onTap: () {
              addTaskButton();
            },
            child: const Padding(
              padding: EdgeInsets.all(8.0),
              child: Icon(Icons.add),
            ),
          ),
        ],
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
                  dateTime: _tasks[index].dateTime,
                  index: index,
                  deleteTask: _deleteTask,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String title;
  final String time;
  final String dateTime;

  Task({required this.title, required this.time, required this.dateTime});

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      title: json['title'] as String,
      time: json['time'] as String,
      dateTime: json['dateTime'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'time': time,
      };
}

class TaskCard extends StatelessWidget {
  final String taskTitle;
  final String taskTime;
  final String dateTime;
  final int index;
  final Function deleteTask;

  const TaskCard({
    super.key,
    required this.taskTitle,
    required this.taskTime,
    required this.dateTime,
    required this.index,
    required this.deleteTask,
  });

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
      child: ListTile(
        title: Text(taskTitle),
        subtitle: Column(
          children: <Widget>[Text(dateTime), Text(taskTime)],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete),
          onPressed: () => deleteTask(index),
        ),
      ),
    );
  }
}
