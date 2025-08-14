import 'package:flutter/material.dart';
import 'package:koe/core/theme/app_pallete.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A2A), // Slightly lighter than background
        border: Border(top: BorderSide(color: Color(0xFF404040), width: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            isSelected: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.search,
            label: 'Search',
            index: 1,
            isSelected: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.library_music,
            label: 'Your Library',
            index: 2,
            isSelected: currentIndex == 2,
          ),
        ],
      ),
    );
  }

  /// Builds a navigation item with icon and label
  Widget _buildNavItem({
    required IconData? icon,
    required String label,
    required int index,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () => onTap?.call(index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon (if available)
            if (icon != null) ...[
              Icon(
                icon,
                color: isSelected ? Pallete.whiteColor : Pallete.subtitleText,
                size: 24,
              ),
              const SizedBox(height: 4),
            ],

            // Label
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Pallete.whiteColor : Pallete.subtitleText,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
