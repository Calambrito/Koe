import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/theme_provider.dart';
import '../theme/color_palettes.dart';

class ColorPaletteSelector extends StatelessWidget {
  const ColorPaletteSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentPalette = themeProvider.currentPalette;
    final paletteNames = ColorPalettes.paletteNames;

    // Safety check for empty palette list
    if (paletteNames.isEmpty) {
      return const SizedBox(
        height: 80,
        child: Center(child: Text('No palettes available')),
      );
    }

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: paletteNames.map((paletteName) {
        final isSelected = paletteName == currentPalette;
        final palette = ColorPalettes.getPalette(paletteName);

        // Safety check for palette data
        if (!palette.containsKey('main') || !palette.containsKey('light')) {
          return const SizedBox.shrink();
        }

        final mainColor = palette['main']!;
        final lightColor = palette['light']!;

        return GestureDetector(
          onTap: () {
            try {
              themeProvider.setPalette(paletteName);
            } catch (e) {
              // Handle any errors during palette setting
              debugPrint('Error setting palette: $e');
            }
          },
          child: Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Colors.transparent,
                width: 2,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Stack(
                children: [
                  // Main color background
                  Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: mainColor,
                  ),
                  // Light color overlay (top half)
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 35,
                    child: Container(
                      decoration: BoxDecoration(
                        color: lightColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                  ),
                  // Selection indicator
                  if (isSelected)
                    Positioned(
                      top: 4,
                      right: 4,
                      child: Container(
                        width: 18,
                        height: 18,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: mainColor, width: 2),
                        ),
                        child: Icon(Icons.check, size: 12, color: mainColor),
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
