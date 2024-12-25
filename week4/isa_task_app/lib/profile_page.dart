import 'package:flutter/material.dart';
import 'package:isa_task_app/notif_app.dart';
import 'package:isa_task_app/yours_task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:isa_task_app/resources_page.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF181818), // Dark background color
      appBar: AppBar(
        title: Text("Your Profile"),
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => YourTasksScreen()));
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
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ResourcesPage()));
              break;
          }
        },
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.grey[300],
              child: Icon(Icons.person, size: 50, color: Colors.grey[700]),
            ),
            SizedBox(height: 10),
            Text(
              userName ?? 'USER ABC',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            SizedBox(height: 20),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF2E2E2E), // Box color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Mail: ',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    userEmail ?? 'abcxyz@example.com',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Color(0xFF2E2E2E), // Box color
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Text(
                    'Role: ',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  Text(
                    userRole ?? 'Logistics Coordinator',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ],
              ),
            ),
            Spacer(),
            FloatingActionButton(
              onPressed: () {
                // Handle edit profile
              },
              backgroundColor: Color(0xFF6A5ACD),
              child: Icon(Icons.edit, color: Colors.white),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
