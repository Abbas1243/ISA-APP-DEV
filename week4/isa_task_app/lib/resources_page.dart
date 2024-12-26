import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatefulWidget {
  const ResourcesPage({Key? key}) : super(key: key);

  @override
  State<ResourcesPage> createState() => _ResourcesPageState();
}

class _ResourcesPageState extends State<ResourcesPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _supabaseClient = Supabase.instance.client;

  List<String> documents = [];
  List<String> pdfs = [];
  List<String> links = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _fetchResources();
  }

  Future<void> _fetchResources() async {
    try {
      final response = await _supabaseClient.storage.from('resources').list();

      if (response.error != null) {
        throw Exception(response.error?.message);
      }

      final files = response.data ?? [];
      print("Fetched files: $files"); // Debug: Check fetched files

      setState(() {
        documents = files
            .where((file) =>
                file.name.endsWith('.docx') || file.name.endsWith('.txt'))
            .map((file) => file.name)
            .toList();
        pdfs = files
            .where((file) => file.name.endsWith('.pdf'))
            .map((file) => file.name)
            .toList();
        links = files
            .where((file) =>
                file.name.endsWith('.txt') || file.name.endsWith('.json'))
            .map((file) => file.name)
            .toList();

        print("Documents: $documents"); // Debug: Check documents list
        print("PDFs: $pdfs"); // Debug: Check PDFs list
        print("Links: $links"); // Debug: Check links list

        isLoading = false;
      });
    } catch (error) {
      print('Error fetching resources: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  String _getPublicUrl(String fileName) {
    final response = _supabaseClient.storage
        .from('resources') // Your bucket name
        .getPublicUrl(fileName);

    return response.data ??
        ''; // Return the public URL or an empty string if null
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
          unselectedLabelColor: Colors.grey,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Documents"),
            Tab(text: "PDFs"),
            Tab(text: "Links"),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildListView(documents),
                _buildListView(pdfs),
                _buildListView(links),
              ],
            ),
    );
  }

  Widget _buildListView(List<String> files) {
    if (files.isEmpty) {
      return const Center(
        child:
            Text('No items available', style: TextStyle(color: Colors.white)),
      );
    }

    return ListView.builder(
      itemCount: files.length,
      itemBuilder: (context, index) {
        final fileName = files[index];
        final fileUrl = _getPublicUrl(fileName);

        return ListTile(
          title: Text(
            fileName,
            style: const TextStyle(color: Colors.white),
          ),
          onTap: () => _openUrl(fileUrl),
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

extension on String {
  get data => null;
}

extension on List<FileObject> {
  get error => null;

  get data => null;
}
