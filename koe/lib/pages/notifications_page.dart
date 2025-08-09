// lib/pages/notifications_page.dart
import 'package:flutter/material.dart';
import '../backend/listener.dart' as blistener;

class NotificationsPage extends StatefulWidget {
  final blistener.Listener listener;
  NotificationsPage({required this.listener});

  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<String> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final n = await Future.value(widget.listener.notifications);
    setState(() => _notes = n);
  }

  @override
  Widget build(BuildContext context) {
    if (_notes.isEmpty) {
      return Center(child: Text('No notifications', style: TextStyle(color: Colors.white70)));
    }

    return ListView.separated(
      padding: EdgeInsets.all(12),
      itemCount: _notes.length,
      separatorBuilder: (_, __) => Divider(color: Colors.white12),
      itemBuilder: (ctx, i) {
        final msg = _notes[i];
        return ListTile(
          title: Text(msg, style: TextStyle(color: Colors.white)),
          subtitle: Text('Notification', style: TextStyle(color: Colors.white60)),
        );
      },
    );
  }
}
