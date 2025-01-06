import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  final List<Map<String, String>> documents = [
    {
      'name': 'SUPABASE',
      'url':
          'https://docs.google.com/document/d/1OBG3A6bXu-Rw7B2aBIF1c0ANvwa9NyZwjqWcfL-zsIo/edit?tab=t.0'
    },
    {
      'name': 'TASKS',
      'url':
          'https://docs.google.com/document/d/1pqOPOP51BQYpFaUdXTOUFDqI4PDdnkMWrWm7eZj6wM4/edit?tab=t.0#heading=h.kfw3s1prn5r0'
    },
  ];

  final List<Map<String, String>> pdfs = [
    {
      'name': 'WEEK 1&2 ',
      'url':
          'https://drive.google.com/file/d/1YybIdP7mxOUPk6QirvpklDVZRDqqvBjS/view?usp=sharing'
    },
    {
      'name': 'WEEK 4',
      'url':
          'https://drive.google.com/file/d/1ODar4dYWYrs-rOmWqbxXhgG2GgesLsPN/view?usp=sharing'
    },
    {
      'name': 'CHEATSHEET',
      'url':
          'https://drive.google.com/file/d/1WLwWcCoFSkR2zeQN03VYAjJxTIO0xqyi/view?usp=sharing'
    },
  ];

  final List<Map<String, String>> links = [
    {'name': 'Flutter Documentation', 'url': 'https://flutter.dev'},
    {'name': 'Dart Language', 'url': 'https://dart.dev'},
  ];

  ResourcesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFF161616),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3F51B5),
          title: const Text('Resources'),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: "Documents"),
              Tab(text: "PDFs"),
              Tab(text: "Links"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildListView(documents),
            _buildListView(pdfs),
            _buildListView(links),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<Map<String, String>> resources) {
    if (resources.isEmpty) {
      return const Center(
        child: Text(
          'No items available',
          style: TextStyle(color: Colors.white),
        ),
      );
    }

    return ListView.builder(
      itemCount: resources.length,
      itemBuilder: (context, index) {
        final resource = resources[index];
        return ListTile(
          title: Text(
            resource['name']!,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () => _openUrl(resource['url']!),
        );
      },
    );
  }

  void _openUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      throw 'Could not launch $url';
    }
  }
}
