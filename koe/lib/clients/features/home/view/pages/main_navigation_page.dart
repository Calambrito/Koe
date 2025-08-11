import 'package:flutter/material.dart';
import 'package:koe/clients/features/home/view/pages/home_page.dart';
import 'package:koe/clients/features/home/widgets/bottom_navigation.dart';
import 'package:koe/core/theme/app_pallete.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;

  // TODO: Add other page widgets when they are created
  final List<Widget> _pages = [
    const HomePage(),
    // TODO: Add SearchPage()
    const PlaceholderPage(title: 'Search'),
    // TODO: Add LibraryPage()
    const PlaceholderPage(title: 'Your Library'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: _pages[_currentIndex],
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onNavItemTapped,
      ),
    );
  }

  /// Handles bottom navigation item taps
  void _onNavItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }
}

/// Placeholder page for tabs that haven't been implemented yet
class PlaceholderPage extends StatelessWidget {
  final String title;

  const PlaceholderPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallete.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.construction, size: 64, color: Pallete.subtitleText),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Pallete.whiteColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Coming Soon',
              style: TextStyle(color: Pallete.subtitleText, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
