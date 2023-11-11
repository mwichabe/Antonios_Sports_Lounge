import 'package:antonios/screens/admin/widgets/eventEditList.dart';
import 'package:flutter/material.dart';


class AdminEditEvents extends StatelessWidget {
  const AdminEditEvents({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Edit Events'),
      ),
      body: const EventEditList(),
    );
  }
}