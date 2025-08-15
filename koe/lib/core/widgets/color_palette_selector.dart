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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Color Palette',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ColorPalettes.paletteNames.map((paletteName) {
            final isSelected = paletteName == currentPalette;
            final palette = ColorPalettes.getPalette(paletteName);
            final mainColor = palette['main']!;
            final lightColor = palette['light']!;

            return GestureDetector(
              onTap: () {
                themeProvider.setPalette(paletteName);
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected 
                        ? Theme.of(context).colorScheme.primary
                        : Colors.transparent,
                    width: 3,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ]
                      : null,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(9),
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
                        height: 30,
                        child: Container(
                          decoration: BoxDecoration(
                            color: lightColor,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(9),
                              topRight: Radius.circular(9),
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
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: mainColor,
                                width: 2,
                              ),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 10,
                              color: mainColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        // Back to Default button (only show when not on default)
        if (currentPalette != 'Default') ...[
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                themeProvider.setPalette('Default');
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Back to Default'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.surface,
                foregroundColor: Theme.of(context).colorScheme.onSurface,
                elevation: 1,
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
        const SizedBox(height: 8),
        Text(
          'Current: $currentPalette',
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
