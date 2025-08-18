import 'package:flutter/material.dart';
import '../backend/theme.dart';
import '../backend/koe_palette.dart';

class CustomNavTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;
  final KoeTheme currentTheme;

  const CustomNavTabs({
    super.key,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colorPalette = KoePalette.get(currentTheme.paletteName);
    final mainColor = colorPalette['main']!;

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          // Horizontal scroll, centered when content fits, scrollable when it overflows
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minWidth: constraints.maxWidth),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildTabItem(context, 0, 'Playlists', mainColor),
                  _buildTabItem(context, 1, 'Discover', mainColor),
                  _buildTabItem(context, 2, 'Notifications', mainColor),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabItem(BuildContext context, int index, String label, Color mainColor) {
    final isSelected = selectedIndex == index;

    return Container(
      margin: const EdgeInsets.only(right: 20),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onTabSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              style: TextStyle(
                fontSize: isSelected ? 27 : 18,
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                color: isSelected ? mainColor : mainColor.withOpacity(0.6),
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}
