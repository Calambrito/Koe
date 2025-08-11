import 'package:flutter/material.dart';
import 'package:koe/clients/features/splash/view/pages/splash_page.dart';
import 'package:koe/core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SplashPage(),
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
