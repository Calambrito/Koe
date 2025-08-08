import 'package:flutter/material.dart';

class ViewAsUserHomepage extends StatelessWidget {
  final String userName;
  const ViewAsUserHomepage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View as User ($userName)'),
      ),
      body: Center(
        child: Text(
          'Placeholder for user $userName',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
