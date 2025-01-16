import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class Notification {
  final String taskName;
  final String status;

  Notification({
    required this.taskName,
    required this.status,
  });

  factory Notification.fromMap(Map<String, dynamic> map) {
    return Notification(
      taskName: map['task_name'] ?? '',
      status: map['status'] ?? '',
    );
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool _isLoading = true;
  List<Notification> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('tasks')
          .select('task_name, status')
          .eq('assigned_to', user.id)
          .order('due_date', ascending: true);

      setState(() {
        _notifications = (response as List)
            .map((notif) => Notification.fromMap(notif))
            .toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading notifications: ${e.toString()}'),
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
        backgroundColor: const Color(0xFF3F51B5),
        title: const Text('Notifications',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    'No notifications yet!',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (context, index) {
                    return _buildNotificationCard(_notifications[index]);
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          setState(() => _isLoading = true);
          await _loadNotifications();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Notifications refreshed successfully'),
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
    );
  }

  Widget _buildNotificationCard(Notification notification) {
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
        border: Border.all(
          color: notification.status.toLowerCase() == 'pending'
              ? Colors.orangeAccent
              : Colors.greenAccent,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              notification.taskName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            notification.status,
            style: TextStyle(
              color: notification.status.toLowerCase() == 'pending'
                  ? Colors.orangeAccent
                  : Colors.greenAccent,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
