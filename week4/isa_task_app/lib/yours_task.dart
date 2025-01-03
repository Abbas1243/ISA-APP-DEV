import 'package:flutter/material.dart';
import 'package:isa_task_app/notif_app.dart';
import 'package:isa_task_app/profile_page.dart';
import 'package:isa_task_app/resources_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Task {
  final String taskId;
  final String taskName;
  final String description;
  final String status;
  final DateTime dueDate;
  final int priority;
  final String assignedTo;
  final String assignedToName;
  final String createdBy;

  Task({
    required this.taskId,
    required this.taskName,
    required this.description,
    required this.status,
    required this.dueDate,
    required this.priority,
    required this.assignedTo,
    required this.assignedToName,
    required this.createdBy,
  });

  factory Task.fromMap(Map<String, dynamic> map) {
    String assignedToName = 'Unknown';
    if (map['assigned_user'] != null) {
      assignedToName = map['assigned_user']['name'] ?? 'Unknown';
    }

    return Task(
      taskId: map['task_id'] ?? '',
      taskName: map['task_name'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? '',
      dueDate: map['due_date'] != null
          ? DateTime.parse(map['due_date'])
          : DateTime.now(),
      priority: map['priority']?.toInt() ?? 0,
      assignedTo: map['assigned_to'] ?? '',
      assignedToName: assignedToName,
      createdBy: map['created_by'] ?? '',
    );
  }
}

class YourTasksScreen extends StatefulWidget {
  const YourTasksScreen({Key? key}) : super(key: key);

  @override
  _YourTasksScreenState createState() => _YourTasksScreenState();
}

class _YourTasksScreenState extends State<YourTasksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('tasks')
          .select()
          .eq('assigned_to', user.id)
          .order('due_date', ascending: true);

      setState(() {
        _tasks = (response as List).map((task) => Task.fromMap(task)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading tasks: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xFF3F51B5),
        title: const Text('Your Tasks',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Pending'),
            Tab(text: 'Approved'),
          ],
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildTaskList('pending'),
                _buildTaskList('approved'),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          await _loadTasks();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Tasks refreshed successfully'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 1),
            ),
          );
        },
        backgroundColor: Colors.blueAccent,
        child: const Icon(
          Icons.refresh,
          color: Colors.white,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161616),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.5),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          backgroundColor: const Color(0xFF161616),
          selectedItemColor: Colors.blueAccent,
          unselectedItemColor: Colors.white70,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined, size: 28),
              activeIcon: Icon(Icons.home, size: 28, color: Colors.blueAccent),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.notifications_none, size: 28),
              activeIcon:
                  Icon(Icons.notifications, size: 28, color: Colors.blueAccent),
              label: 'Notifications',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline, size: 28),
              activeIcon:
                  Icon(Icons.person, size: 28, color: Colors.blueAccent),
              label: 'Profile',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.folder_open_outlined, size: 28),
              activeIcon:
                  Icon(Icons.folder, size: 28, color: Colors.blueAccent),
              label: 'Resources',
            ),
          ],
          onTap: (index) {
            switch (index) {
              case 0:
                Navigator.pushNamed(context, '/home');
                break;
              case 1:
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => NotificationScreen()));
                break;
              case 2:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ResourcesPage()),
                );
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildTaskList(String status) {
    final filteredTasks =
        _tasks.where((task) => task.status.toLowerCase() == status).toList();

    if (filteredTasks.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 300),
          Center(
            child: Text(
              'No tasks in this category\nRefresh karo',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                height: 1.5,
              ),
            ),
          ),
        ],
      );
    }

    return ListView.builder(
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        return GestureDetector(
          onTap: () => _showTaskDetailsModal(filteredTasks[index]),
          child: _buildTaskCard(filteredTasks[index]),
        );
      },
    );
  }

  Widget _buildTaskCard(Task task) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.blueAccent, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  task.taskName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Row(
                children: [
                  Icon(
                    Icons.priority_high,
                    color: _getPriorityColor(task.priority),
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'P${task.priority}',
                    style: TextStyle(
                      color: _getPriorityColor(task.priority),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            task.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: Colors.white70,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              Text(
                task.status,
                style: TextStyle(
                  color: task.status.toLowerCase() == 'approved'
                      ? Colors.greenAccent
                      : Colors.orangeAccent,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showTaskDetailsModal(Task task) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF161616),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                task.taskName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                task.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.calendar_today, color: Colors.white70),
                  const SizedBox(width: 8),
                  Text(
                    'Due: ${task.dueDate.day}/${task.dueDate.month}/${task.dueDate.year}',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Upload link',
                  labelStyle: const TextStyle(color: Colors.white70),
                  filled: true,
                  fillColor: const Color(0xFF1E1E1E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Logic to mark task as completed and upload link
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Task marked as completed!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Mark as Completed'),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Color _getPriorityColor(int priority) {
    switch (priority) {
      case 1:
        return Colors.greenAccent;
      case 2:
        return Colors.orangeAccent;
      case 3:
        return Colors.redAccent;
      default:
        return Colors.blueAccent;
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
