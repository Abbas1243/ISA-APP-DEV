import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

final supabase = Supabase.instance.client;

class Resource {
  final String id;
  final String name;
  final String url;
  final String type;
  final String userId;

  Resource({
    required this.id,
    required this.name,
    required this.url,
    required this.type,
    required this.userId,
  });

  factory Resource.fromMap(Map<String, dynamic> map) {
    return Resource(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unknown Resource',
      url: map['url'] ?? '',
      type: map['type'] ?? 'link',
      userId: map['users_id'] ?? '',
    );
  }
}

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  _ResourcesPageState createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  bool _isLoading = true;
  List<Resource> _resources = [];

  @override
  void initState() {
    super.initState();
    _loadResources();
  }

  Future<void> _loadResources() async {
    try {
      final user = supabase.auth.currentUser;
      if (user == null) {
        setState(() => _isLoading = false);
        return;
      }

      final response = await supabase
          .from('storageresources')
          .select()
          .eq('users_id', user.id)
          .order('name', ascending: true);

      setState(() {
        _resources =
            (response as List).map((res) => Resource.fromMap(res)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading resources: ${e.toString()}'),
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
        title: const Text(
          'Your Resources',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshResources,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resources.isEmpty
              ? const Center(
                  child: Text(
                    'No resources available. Please refresh.',
                    style: TextStyle(color: Colors.white70),
                  ),
                )
              : ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    return _buildResourceCard(_resources[index]);
                  },
                ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    return Card(
      color: const Color(0xFF1E1E1E),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Text(
              'Type: ${resource.type.toUpperCase()}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => _openResource(resource.url, resource.type),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Open'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _refreshResources() async {
    setState(() => _isLoading = true);
    await _loadResources();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Resources refreshed successfully'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _openResource(String url, String type) {
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Resource URL is not available.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Logic for opening the resource
    if (type == 'link' || type == 'doc' || type == 'pdf') {
      _downloadResource(url);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unsupported resource type.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _downloadResource(String fileUrl) async {
    // Open resource URL using any supported method
    if (await canLaunch(fileUrl)) {
      await launch(fileUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open resource.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
