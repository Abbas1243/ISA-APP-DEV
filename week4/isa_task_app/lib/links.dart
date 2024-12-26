import 'package:flutter/material.dart';
import 'package:isa_task_app/reusable.dart';

class LinksPage extends StatelessWidget {
  // ignore: use_super_parameters
  const LinksPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const [
        ResourceItem(
          title: "LINK 1",
          date: "23-Dec 10:14 pm",
          size: "1 item",
        ),
      ],
    );
  }
}
