// lib/main.dart
import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import 'pages/admin_portal.dart';
import 'pages/user_home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(KoeApp());
}

class KoeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Koe',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.greenAccent,
        scaffoldBackgroundColor: Color(0xFF0D0F12),
        textTheme: ThemeData.dark().textTheme.apply(
              fontFamily: 'Roboto',
            ),
      ),
      initialRoute: '/',
      routes: {
        '/': (_) => LoginPage(),
        '/admin': (_) => AdminPortal(),
        '/home': (_) => UserHomePage(),
      },
    );
  }
}
