import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Number of tabs (Documents, PDFs, Links)
      child: Scaffold(
        appBar: AppBar(
          title: Text('Resources Page'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Documents'),
              Tab(text: 'PDFs'),
              Tab(text: 'Links'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ResourceList(resourceType: 'documents'),
            ResourceList(resourceType: 'pdfs'),
            ResourceList(resourceType: 'links'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Upload functionality not implemented')),
            );
          },
          child: Icon(Icons.upload),
        ),
        bottomNavigationBar: BottomAppBar(
          color: Colors.blue,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.folder, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResourceList extends StatelessWidget {
  final String resourceType;

  const ResourceList({Key? key, required this.resourceType}) : super(key: key);

  // Function to fetch resources from Supabase (to be implemented)
  // Replace this with actual Supabase logic when integrating with backend
  Future<List<Map<String, dynamic>>> fetchResources(String type) async {
    // You can replace this with Supabase fetch call
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: fetchResources(
          resourceType), // Fetching resources based on type (documents, pdfs, links)
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final resources = snapshot.data as List<Map<String, dynamic>>;

        if (resources.isEmpty) {
          return Center(child: Text('No $resourceType available.'));
        }

        return ListView.builder(
          itemCount: resources.length,
          itemBuilder: (context, index) {
            final resource = resources[index];
            return ListTile(
              leading: Icon(
                resourceType == 'links' ? Icons.link : Icons.insert_drive_file,
                color: Colors.blue,
              ),
              title: Text(resource['name']),
              subtitle: Text('Added on: ${resource['created_at']}'),
              onTap: () {
                if (resourceType == 'links') {
                  openLink(resource['url']);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text('Open file functionality not implemented')),
                  );
                }
              },
            );
          },
        );
      },
    );
  }

  // Function to open a URL (for links)
  void openLink(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
