import 'package:flutter/material.dart';
import 'package:isa_task_app/reusable.dart';

class PDFsPage extends StatelessWidget {
  const PDFsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ResourceItem(
          title: "PDF 1",
          date: "23-Dec 10:14 pm",
          size: "27.3 MB",
        ),
      ],
    );
  }
}
