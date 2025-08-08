
import '../backend/database_helper.dart';
import 'pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:koe/pages/song_search_screen.dart';

/*void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  final idGen = DatabaseHelper.getInstance();
  final db = await idGen.database;flutter devices

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
      home: const SongSearchScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}*/


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = await DatabaseHelper.getInstance().database;
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Music Stream',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const LoginPage(), 
      debugShowCheckedModeBanner: false,
     


    );
  }
}
