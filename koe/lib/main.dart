import 'package:flutter/material.dart';
import 'pages/login_page.dart';
import '../backend/database_helper.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final idGen = DatabaseHelper.getInstance();
  final db = await idGen.database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Stream',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const LoginPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
