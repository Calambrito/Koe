import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../backend/listener.dart' as klistener;
import '../backend/koe_palette.dart';
import '../backend/theme.dart';

class NotificationsPage extends StatefulWidget {
  final klistener.Listener listener;
  final KoeTheme currentTheme;

  const NotificationsPage({super.key, required this.listener, required this.currentTheme});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  Future<void> _removeNotification(String message) async {
    final success =
        await widget.listener.removeNotification(widget.listener.id, message);
    if (success) {
      setState(() {
        widget.listener.notifications.remove(message);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final KoeTheme theme = widget.currentTheme;
    final colorPalette = KoePalette.get(theme.paletteName);
    final backgroundColor = theme.isDarkMode ? Colors.black : Colors.white;
    final tileColor = colorPalette['light'] ?? Colors.grey[300]!;
    const borderRadius = BorderRadius.all(Radius.circular(14));

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        top: true,
        bottom: true,
        child: widget.listener.notifications.isEmpty
            ? Center(
                child: Text(
                  "no notifications at the moment :(",
                  style: TextStyle(
                    fontSize: 16,
                    color: theme.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: widget.listener.notifications.length,
                itemBuilder: (context, index) {
                  final notification = widget.listener.notifications[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    child: Dismissible(
                      key: Key(notification),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        decoration: BoxDecoration(
                          color: Colors.redAccent,
                          borderRadius: borderRadius,
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => _removeNotification(notification),
                      child: Material(
                        color: tileColor,
                        shape: const RoundedRectangleBorder(borderRadius: borderRadius),
                        clipBehavior: Clip.antiAlias,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 12, horizontal: 20),
                          leading: Icon(
                            LucideIcons.music,
                            size: 28,
                            color: Colors.black,
                          ),
                          title: Text(
                            notification,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.black, // always black
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}