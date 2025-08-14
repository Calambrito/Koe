import 'package:flutter/material.dart';
import 'package:koe/clients/features/home/view/pages/home_page.dart';
import 'package:koe/core/theme/app_pallete.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  @override
  Widget build(BuildContext context) {
    return const HomePage();
  }
}
