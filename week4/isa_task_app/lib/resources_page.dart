// ignore_for_file: unused_import
import 'package:isa_task_app/notif_app.dart';
import 'package:isa_task_app/yours_task.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/material.dart';
import 'package:isa_task_app/reusable.dart';
import 'package:isa_task_app/documents.dart';
import 'package:isa_task_app/pdfs.dart';
import 'package:isa_task_app/links.dart';
import 'package:isa_task_app/profile_page.dart';

void main() {
  runApp(const MaterialApp(
    home: ResourcesPage(),
  ));
}

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({super.key});

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF161616),
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: const Color.fromARGB(255, 254, 253, 253),
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Documents"),
            Tab(text: "PDFs"),
            Tab(text: "Links"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          DocumentsPage(), // Replace with DocumentsPage() if available
          PDFsPage(), // Replace with PDFsPage() if available
          LinksPage(), // Replace with LinksPage() if available
        ],
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => YourTasksScreen()),
              );
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
            case 3:
              Navigator.pushNamed(context, '/resources');
              break;
          }
        },
      ),
    );
  }
}
