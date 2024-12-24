import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //Supabase initializing
  await Supabase.initialize(
      url: 'https://hojwkimtesszgrjahuxg.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImhvandraW10ZXNzemdyamFodXhnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzUwMjkxNjYsImV4cCI6MjA1MDYwNTE2Nn0.rE1AG01E-0gR9vx-KhsX06Sq2tK_UsPV_LDiNtHGV6E');

  runApp(TaskApp());
}

class TaskApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final List<Map<String, String>> tasks = []; // Dynamic task list
  String selectedCategory = 'All Members'; // Default category

  void _addTask() {
    showDialog(
      context: context,
      builder: (context) {
        final TextEditingController taskController = TextEditingController();
        final TextEditingController leadController = TextEditingController();
        final TextEditingController dateController = TextEditingController();
        String dropdownValue = 'All Members';

        return AlertDialog(
          title: Text("Add Task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: taskController,
                decoration: InputDecoration(labelText: "Task Name"),
              ),
              TextField(
                controller: leadController,
                decoration: InputDecoration(labelText: "Lead Name"),
              ),
              TextField(
                controller: dateController,
                decoration: InputDecoration(labelText: "Due Date (dd/mm/yy)"),
              ),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                items: ['All Members', 'Specific Allotments']
                    .map((category) => DropdownMenuItem(
                  value: category,
                  child: Text(category),
                ))
                    .toList(),
                onChanged: (value) {
                  dropdownValue = value!;
                },
                decoration: InputDecoration(labelText: "Assign To"),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  tasks.add({
                    'task': taskController.text,
                    'lead': leadController.text,
                    'date': dateController.text,
                    'status': 'In Progress',
                    'category': dropdownValue,
                  });
                });
                Navigator.pop(context);
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text("Assigned Tasks"),
          bottom: TabBar(
            tabs: [
              Tab(text: "All Members"),
              Tab(text: "Specific Allotments"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            TaskList(
              tasks: tasks
                  .where((task) => task['category'] == 'All Members')
                  .toList(),
            ),
            TaskList(
              tasks: tasks
                  .where((task) => task['category'] == 'Specific Allotments')
                  .toList(),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addTask,
          child: Icon(Icons.add),
        ),
        bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: ""),
            BottomNavigationBarItem(icon: Icon(Icons.circle), label: ""),
            BottomNavigationBarItem(
                icon: Icon(Icons.arrow_drop_down), label: ""),
          ],
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Map<String, String>> tasks;

  TaskList({required this.tasks});

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return Center(
        child: Text("No tasks added yet."),
      );
    }

    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final task = tasks[index];
        return Card(
          margin: EdgeInsets.all(8.0),
          child: ListTile(
            title: Text(task['task']!,
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Lead: ${task['lead']}"),
                Text("Date: ${task['date']}"),
                Text("Status: ${task['status']}"),
                Text("Category: ${task['category']}"),
              ],
            ),
          ),
        );
      },
    );
  }
}
