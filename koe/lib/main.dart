import 'package:flutter/material.dart';
import 'package:koe/clients/features/auth/view/pages/signup_page.dart';
import 'package:koe/core/theme/theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const SignupPage(),
      theme: AppTheme.darkThemeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
