// lib/pages/admin_portal.dart
import 'package:flutter/material.dart';
import 'admin_add_song_page.dart';
import 'admin_remove_song_page.dart';

class AdminPortal extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>? ?? {};
    final username = args['username'] ?? 'admin';

    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Portal - $username'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              icon: Icon(Icons.library_add),
              label: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Add Song', style: TextStyle(fontSize: 18)),
              ),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminAddSongPage()));
              },
            ),
            SizedBox(height: 12),
            ElevatedButton.icon(
              icon: Icon(Icons.delete),
              label: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text('Remove Song', style: TextStyle(fontSize: 18)),
              ),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => AdminRemoveSongPage()));
              },
            ),
            Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushReplacementNamed('/'),
              child: Text('Logout'),
            )
          ],
        ),
      ),
    );
  }
}
