import 'package:flutter/material.dart';
import 'package:isa_task_app/admin_page.dart';
import 'package:isa_task_app/notif_app.dart';
import 'package:isa_task_app/resources_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isa_task_app/yours_task.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final supabase = Supabase.instance.client;
  String? userName;
  String? userEmail;
  String? userRole;
  int selectedIndex = 2; // Set to Profile tab index

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response = await supabase
          .from('users')
          .select('name, email, council_role')
          .eq('user_id', userId)
          .single();

      setState(() {
        userName = response['name'];
        userEmail = response['email'];
        userRole = response['council_role'];
      });
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  void onTabTapped(int index) async {
    // Mark the function as async
    setState(() {
      selectedIndex = index; // Update the selected index
    });

    switch (index) {
      case 0:
        {
          if (userName != null && userEmail != null) {
            try {
              // Get user role from the users table
              final userData = await supabase
                  .from('users')
                  .select('role')
                  .eq('email', userEmail!.trim())
                  .single();

              if (mounted) {
                // Navigate based on user role
                if (userData != null && userData['role'] == 'admin') {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => AdminDashboard(),
                    ),
                  );
                } else {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => YourTasksScreen(),
                    ),
                  );
                }
              }
            } catch (e) {
              // Handle errors (e.g., network issues, query failures)
              print('Error fetching user role: $e');
            }
          }
        }
        break;

      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => NotificationScreen()),
        );
        break;

      case 2:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ProfilePage()),
        );
        break;

      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ResourcesPage()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        title: const Text(
          "Your Profile",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex, // Use the selectedIndex here
        backgroundColor: const Color(0xFF161616),
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.white70,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        items: const [
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
        onTap: onTabTapped,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[800],
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 20),
              Text(
                userName ?? 'USER ABC',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildInfoCard('Mail', userEmail ?? 'abcxyz@example.com'),
              const SizedBox(height: 10),
              _buildInfoCard('Role', userRole ?? 'Logistics Coordinator'),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  // Handle edit profile
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E1E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
