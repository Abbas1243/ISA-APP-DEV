import 'package:flutter/material.dart';

class ResourceItem extends StatelessWidget {
  final String title;
  final String date;
  final String size;

  const ResourceItem({
    super.key,
    required this.title,
    required this.date,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          const Icon(Icons.folder, color: Color.fromARGB(255, 249, 249, 249)),
      title: Text(title,
          style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(date,
              style:
                  const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
          Text(size,
              style:
                  const TextStyle(color: Color.fromARGB(255, 255, 255, 255))),
        ],
      ),
      tileColor: Color(0xFF161616),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
