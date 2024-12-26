import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final supabase = Supabase.instance.client;
  List<Map<String, dynamic>> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Fetch notifications for the current user where status is 'pending'
      final response = await supabase
          .from('notifications')
          .select(
              'notification_id, task_name, due_date, is_read, time_created, status')
          .eq('user_id', userId) // Ensure to link to the correct user_id
          .eq('status', 'pending') // Filter for pending notifications
          .order('time_created', ascending: false) // Order by time created
          .single();

      if (response.error == null) {
        setState(() {
          notifications = List<Map<String, dynamic>>.from(response.data ?? []);
          isLoading = false;
        });
      } else {
        print('Error fetching notifications: ${response.error?.message}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818), // Dark background color
      appBar: AppBar(
        title: Text("Notifications"),
        backgroundColor: Color(0xFF6A5ACD), // Nav bar color (periwinkle)
      ),
      bottomNavigationBar: BottomNavigationBar(
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
            activeIcon: Icon(Icons.person, size: 28, color: Colors.blueAccent),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open_outlined, size: 28),
            activeIcon: Icon(Icons.folder, size: 28, color: Colors.blueAccent),
            label: 'Resources',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home
              break;
            case 1:
              // Stay on the notifications page
              break;
            case 2:
              // Navigate to Profile
              break;
            case 3:
              // Navigate to Resources
              break;
          }
        },
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? Center(
                  child: Text(
                    'No Pending Notifications',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationCard(
                      taskName: notification['task_name'],
                      dueDate: notification['due_date'],
                      timeCreated: notification['time_created'],
                      isRead: notification['is_read'],
                    );
                  },
                ),
    );
  }
}

extension on PostgrestMap {
  get error => null;

  Iterable? get data => null;
}

class NotificationCard extends StatelessWidget {
  final String taskName;
  final String dueDate;
  final String timeCreated;
  final bool isRead;

  const NotificationCard({
    required this.taskName,
    required this.dueDate,
    required this.timeCreated,
    required this.isRead,
  });

  String formatDate(String date) {
    // Format the time_created (ISO 8601 format) into a more readable format
    DateTime dt = DateTime.parse(date);
    return "${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute}";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isRead
            ? Color(0xFF2E2E2E)
            : Color(0xFF3E3E3E), // Highlight unread notifications
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            taskName,
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 5),
          Text(
            'Due: $dueDate',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            'Created: ${formatDate(timeCreated)}',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          SizedBox(height: 5),
          Text(
            'Status: Pending',
            style: TextStyle(color: Colors.amber, fontSize: 14),
          ),
        ],
      ),
    );
  }
}
