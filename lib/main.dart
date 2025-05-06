import 'package:flutter/material.dart';

void main() => runApp(AsianCollegeToDoApp());

class Task {
  String title;
  String description;
  DateTime dueDate;
  String category;
  bool isCompleted;

  Task({
    required this.title,
    required this.description,
    required this.dueDate,
    required this.category,
    this.isCompleted = false,
  });
}

class AsianCollegeToDoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asian College TO-DO',
      theme: ThemeData(
        primaryColor: Color(0xFF0056b3),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: Color.fromARGB(255, 22, 204, 204),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF0056b3),
          foregroundColor: const Color.fromARGB(255, 170, 126, 69),
        ),
      ),
      home: ToDoHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ToDoHomePage extends StatefulWidget {
  @override
  _ToDoHomePageState createState() => _ToDoHomePageState();
}

class _ToDoHomePageState extends State<ToDoHomePage> {
  List<Task> tasks = [];

  void _addTaskDialog({Task? task, int? index}) {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    String category = task?.category ?? 'Academic';
    DateTime selectedDate = task?.dueDate ?? DateTime.now();

    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(task == null ? 'Add Task' : 'Edit Task'),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: titleController,
                    decoration: InputDecoration(labelText: 'Title'),
                  ),
                  TextField(
                    controller: descController,
                    decoration: InputDecoration(labelText: 'Description'),
                  ),
                  DropdownButton<String>(
                    value: category,
                    items:
                        ['Academic', 'Work', 'Personal']
                            .map(
                              (c) => DropdownMenuItem(value: c, child: Text(c)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => category = val!),
                  ),
                  TextButton(
                    onPressed: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2100),
                      );
                      if (picked != null) {
                        setState(() => selectedDate = picked);
                      }
                    },
                    child: Text(
                      "Select Due Date: ${selectedDate.toLocal().toString().split(' ')[0]}",
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (titleController.text.trim().isEmpty) return;
                  final newTask = Task(
                    title: titleController.text,
                    description: descController.text,
                    dueDate: selectedDate,
                    category: category,
                  );
                  setState(() {
                    if (index == null) {
                      tasks.add(newTask);
                    } else {
                      tasks[index] = newTask;
                    }
                  });
                  Navigator.pop(ctx);
                },
                child: Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteTask(int index) {
    showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text('Confirm Delete'),
            content: Text('Are you sure you want to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  setState(() => tasks.removeAt(index));
                  Navigator.pop(ctx);
                },
                child: Text('Delete'),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Asian College TO-DO'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(context: context, delegate: TaskSearch(tasks));
            },
          ),
        ],
      ),
      body:
          tasks.isEmpty
              ? Center(child: Text('No tasks yet. Add one!'))
              : ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (ctx, i) {
                  final task = tasks[i];
                  final dueSoon =
                      task.dueDate.difference(DateTime.now()).inDays <= 1 &&
                      !task.isCompleted;

                  return Card(
                    color: dueSoon ? Colors.red.shade100 : null,
                    child: ListTile(
                      title: Text(
                        task.title,
                        style: TextStyle(
                          decoration:
                              task.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        '${task.category} | Due: ${task.dueDate.toLocal().toString().split(' ')[0]}\n${task.description}',
                      ),
                      isThreeLine: true,
                      trailing: Wrap(
                        spacing: 0,
                        children: [
                          Checkbox(
                            value: task.isCompleted,
                            onChanged:
                                (_) => setState(
                                  () => task.isCompleted = !task.isCompleted,
                                ),
                          ),
                          IconButton(
                            icon: Icon(Icons.edit),
                            onPressed:
                                () => _addTaskDialog(task: task, index: i),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete),
                            onPressed: () => _deleteTask(i),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.secondary,
        onPressed: () => _addTaskDialog(),
        child: Icon(Icons.add),
      ),
    );
  }
}

class TaskSearch extends SearchDelegate {
  final List<Task> tasks;

  TaskSearch(this.tasks);

  @override
  List<Widget>? buildActions(BuildContext context) => [
    IconButton(icon: Icon(Icons.clear), onPressed: () => query = ''),
  ];

  @override
  Widget? buildLeading(BuildContext context) => IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => close(context, null),
  );

  @override
  Widget buildResults(BuildContext context) {
    final resultTasks = tasks.where(
      (t) =>
          t.title.toLowerCase().contains(query.toLowerCase()) ||
          t.description.toLowerCase().contains(query.toLowerCase()),
    );
    return ListView(
      children:
          resultTasks
              .map(
                (task) => ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description),
                ),
              )
              .toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);
}
