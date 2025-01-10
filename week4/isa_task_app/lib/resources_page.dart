import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:typed_data';

final supabase = Supabase.instance.client;

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage> {
  List<Map<String, dynamic>> _resources = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final files = await supabase.storage.from('resources').list();

      if (files.isEmpty) {
        setState(() {
          _resources = [];
        });
      } else {
        final fetchedResources = files.map((file) {
          return {
            'name': file.name,
            'url': supabase.storage.from('resources').getPublicUrl(file.name),
          };
        }).toList();

        setState(() {
          _resources = fetchedResources;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load resources: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectFile() async {
    try {
      // Open file picker
      final result = await FilePicker.platform.pickFiles(
        withData: true, // Ensures the file's bytes are included
      );

      if (result == null) {
        // User canceled the file picker
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("File selection canceled")),
        );
        return;
      }

      // Get the file's bytes and name
      final fileBytes = result.files.single.bytes;
      final fileName = result.files.single.name;

      if (fileBytes == null || fileName.isEmpty) {
        // Invalid file or missing data
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid file selected")),
        );
        return;
      }

      // Proceed to upload the file
      await _uploadFile(fileBytes, fileName);
    } catch (e) {
      // Catch unexpected errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error selecting file: $e")),
      );
    }
  }

  Future<void> _uploadFile(Uint8List fileBytes, String fileName) async {
    try {
      // Attempt to upload the file
      await supabase.storage
          .from('resources')
          .uploadBinary(fileName, fileBytes);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("File uploaded successfully")),
      );

      // Refresh the resources list
      _fetchResources();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload file: $e")),
      );
    }
  }

  Future<String?> _getUserRole() async {
    final user = supabase.auth.currentUser;

    if (user == null) {
      print('No user is logged in');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return null;
    }

    try {
      final response = await supabase
          .from('users')
          .select('role')
          .eq('user_id', user.id)
          .single();

      print('Fetched user role: ${response['role']}');
      return response['role'] as String?;
    } catch (e) {
      print('Error fetching user role: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch user role: $e')),
      );
      return null;
    }
  }

  Future<void> _openResource(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load resources: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openResource(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not open the resource.'),
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
        title: const Text('Resources'),
        title: const Text(
          'Resources',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF3F51B5),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _resources.isEmpty
              ? const Center(
                  child: Text(
                    'No resources available.',
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  itemCount: _resources.length,
                  itemBuilder: (context, index) {
                    final resource = _resources[index];
                    return GestureDetector(
                      onTap: () => _openResource(resource['url']),
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
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
                          border:
                              Border.all(color: Colors.blueAccent, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                resource['name'],
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.open_in_browser,
                                  color: Colors.blueAccent),
                              onPressed: () => _openResource(resource['url']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FutureBuilder<String?>(
        future: _getUserRole(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(); // Don't show button while loading
          }

          if (snapshot.data == 'admin') {
            return FloatingActionButton(
              onPressed: _selectFile,
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.add, color: Colors.white),
            );
          }

          return const SizedBox(); // Hide button for non-admin users
        },
      floatingActionButton: FloatingActionButton(
        onPressed: _fetchResources,
        backgroundColor: Colors.blueAccent,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
