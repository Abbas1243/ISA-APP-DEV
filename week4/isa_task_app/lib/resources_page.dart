import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  final List<Map<String, String>> links = [
    {'name': 'Flutter Documentation', 'url': 'https://flutter.dev'},
    {'name': 'Dart Language', 'url': 'https://dart.dev'},
  ];

  final List<Map<String, String>> documents = [
    {'name': 'Week 1 & 2 Report', 'path': 'assets/documents/w1.pdf'},
    {'name': 'Week 4 Report', 'path': 'assets/documents/w4.pdf'},
  ];

  final List<Map<String, String>> pdfs = [
    {'name': 'Flutter Cheat Sheet', 'path': 'assets/documents/cheat.pdf'},
    {'name': 'Notification Flow', 'path': 'assets/documents/notif.pdf'},
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
            _buildListView(documents, context),
            _buildListView(pdfs, context),
            _buildListView(links, context),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(
      List<Map<String, String>> resources, BuildContext context) {
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
          onTap: () {
            if (resource.containsKey('url')) {
              _openUrl(context, resource['url']!);
            } else if (resource.containsKey('path')) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      PDFViewerPage(filePath: resource['path']!),
                ),
              );
            }
          },
        );
      },
    );
  }

  Future<void> _openUrl(BuildContext context, String url) async {
    try {
      final uri = Uri.parse(url);
      if (!await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      )) {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening URL: $url'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class PDFViewerPage extends StatefulWidget {
  final String filePath;

  const PDFViewerPage({Key? key, required this.filePath}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  String? localFilePath;

  @override
  void initState() {
    super.initState();
    _loadPdf();
  }

  Future<void> _loadPdf() async {
    try {
      // Get the temporary directory
      final tempDir = await getTemporaryDirectory();

      // Create a temporary file path
      final tempFile =
          File('${tempDir.path}/${widget.filePath.split('/').last}');

      // Copy the asset to the temporary file
      final byteData = await rootBundle.load(widget.filePath);
      await tempFile.writeAsBytes(byteData.buffer.asUint8List());

      // Update the state with the local file path
      setState(() {
        localFilePath = tempFile.path;
      });
    } catch (e) {
      print('Error loading PDF: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF3F51B5),
        title: const Text('PDF Viewer'),
      ),
      body: localFilePath == null
          ? const Center(child: CircularProgressIndicator())
          : PDFView(
              filePath: localFilePath!,
              onError: (error) {
                print("Error loading PDF: $error");
              },
            ),
    );
  }
}
