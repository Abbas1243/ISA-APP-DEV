import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminPage extends StatefulWidget {
  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  List tasks = [];
  TextEditingController _taskNameController = TextEditingController();
  TextEditingController _taskDescriptionController = TextEditingController();
  String _assignedTo = '';
  String _status = 'Pending';

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  // Fetch all tasks from Supabase
  Future<void> fetchTasks() async {
    final response =
        await Supabase.instance.client.from('tasks').select().single();
    setState(() {
      tasks = response.data ?? [];
    });
  }

  // Create a new task
  Future<void> createTask() async {
    final response = await Supabase.instance.client.from('tasks').insert([
      {
        'task_name': _taskNameController.text,
        'description': _taskDescriptionController.text,
        'status': _status,
        'assigned_to': _assignedTo,
        'created_at': DateTime.now().toIso8601String(),
      }
    ]).single();

    if (response.error == null) {
      // After task creation, clear inputs and fetch tasks again
      _taskNameController.clear();
      _taskDescriptionController.clear();
      setState(() {
        _assignedTo = '';
        _status = 'Pending';
      });
      fetchTasks();
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  // Update task status (mark as complete or pending)
  Future<void> updateTaskStatus(String taskId, String status) async {
    final response = await Supabase.instance.client
        .from('tasks')
        .update({'status': status})
        .eq('id', taskId)
        .single();

    if (response.error == null) {
      fetchTasks();
    } else {
      print('Error: ${response.error?.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admin Dashboard')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            // Task Creation Form
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    TextField(
                      controller: _taskNameController,
                      decoration: InputDecoration(labelText: 'Task Name'),
                    ),
                    TextField(
                      controller: _taskDescriptionController,
                      decoration:
                          InputDecoration(labelText: 'Task Description'),
                    ),
                    DropdownButton<String>(
                      value: _assignedTo,
                      hint: Text('Select User'),
                      items: [
                        // You can replace with user fetching logic
                        DropdownMenuItem(
                          value: 'user1', // Example user
                          child: Text('User 1'),
                        ),
                        DropdownMenuItem(
                          value: 'user2', // Example user
                          child: Text('User 2'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _assignedTo = value ?? '';
                        });
                      },
                    ),
                    DropdownButton<String>(
                      value: _status,
                      items: [
                        DropdownMenuItem(
                          value: 'Pending',
                          child: Text('Pending'),
                        ),
                        DropdownMenuItem(
                          value: 'Complete',
                          child: Text('Complete'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _status = value ?? 'Pending';
                        });
                      },
                    ),
                    ElevatedButton(
                      onPressed: createTask,
                      child: Text('Create Task'),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            // Display List of Tasks
            Expanded(
              child: ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
                  return Card(
                    child: ListTile(
                      title: Text(task['task_name']),
                      subtitle: Text('Assigned to: ${task['assigned_to']}'),
                      trailing: Text(task['status']),
                      onTap: () {
                        // Update the task status (toggle between 'Complete' and 'Pending')
                        String newStatus = task['status'] == 'Pending'
                            ? 'Complete'
                            : 'Pending';
                        updateTaskStatus(task['id'], newStatus);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension on PostgrestMap {
  List? get data => null;

  get error => null;
}
