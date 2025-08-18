import 'package:flutter/material.dart';
import '../backend/koe_palette.dart';
import '../backend/theme.dart';

class SettingsPanel extends StatelessWidget {
  final KoeTheme currentTheme;
  final void Function(KoeTheme) updateTheme;
  final VoidCallback saveSettings;
  final VoidCallback logout;

  const SettingsPanel({
    super.key,
    required this.currentTheme,
    required this.updateTheme,
    required this.saveSettings,
    required this.logout,
  });

  @override
  Widget build(BuildContext context) {
    final colorPalette = KoePalette.get(currentTheme.paletteName);
    final mainColor = colorPalette['main']!;

    return Material(
      elevation: 10,
      color: currentTheme.isDarkMode ? Colors.grey[900] : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Center(
              child: Text(
                'Theme Settings',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: currentTheme.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ),
            const SizedBox(height: 30),
            ThemeModeButton(
              title: 'Dark Mode',
              subtitle: 'Easier on the eyes',
              isDark: true,
              currentTheme: currentTheme,
              updateTheme: updateTheme,
            ),
            const SizedBox(height: 20),
            ThemeModeButton(
              title: 'Light Mode',
              subtitle: 'Cleaner aesthetic',
              isDark: false,
              currentTheme: currentTheme,
              updateTheme: updateTheme,
            ),
            const SizedBox(height: 30),

            // Currently Selected with Swatch
            Row(
              children: [
                Text(
                  'Currently : ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: currentTheme.isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
                Container(
                  width: 16,
                  height: 16,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: mainColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1),
                  ),
                ),
                Text(
                  currentTheme.paletteName.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: mainColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Palette Grid 3x3
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1,
                ),
                itemCount: KoeColorName.values.length,
                itemBuilder: (context, index) {
                  return PaletteOption(
                    palette: KoeColorName.values[index],
                    currentTheme: currentTheme,
                    updateTheme: updateTheme,
                  );
                },
              ),
            ),
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: saveSettings,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'SAVE CHANGES',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: logout,
                style: ElevatedButton.styleFrom(
                  backgroundColor: mainColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text(
                  'LOGOUT',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ThemeModeButton extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isDark;
  final KoeTheme currentTheme;
  final void Function(KoeTheme) updateTheme;

  const ThemeModeButton({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isDark,
    required this.currentTheme,
    required this.updateTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTheme.isDarkMode == isDark;
    final textColor = currentTheme.isDarkMode ? Colors.white : Colors.black;

    return InkWell(
      onTap: () => updateTheme(KoeTheme(paletteName: currentTheme.paletteName, isDarkMode: isDark)),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.grey.withOpacity(0.3) : Colors.transparent,
          border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: isSelected ? 2 : 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(isDark ? Icons.dark_mode : Icons.light_mode, color: isSelected ? Colors.blue : textColor, size: 30),
            const SizedBox(width: 15),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
                Text(subtitle, style: TextStyle(fontSize: 14, color: textColor.withOpacity(0.7))),
              ],
            ),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle, color: Colors.blue),
          ],
        ),
      ),
    );
  }
}

class PaletteOption extends StatelessWidget {
  final KoeColorName palette;
  final KoeTheme currentTheme;
  final void Function(KoeTheme) updateTheme;

  const PaletteOption({
    super.key,
    required this.palette,
    required this.currentTheme,
    required this.updateTheme,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = currentTheme.paletteName == palette;
    final colors = KoePalette.get(palette);

    return GestureDetector(
      onTap: () => updateTheme(KoeTheme(paletteName: palette, isDarkMode: currentTheme.isDarkMode)),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors['light']!, colors['main']!, colors['dark']!],
          ),
          borderRadius: BorderRadius.circular(8),
          border: isSelected ? Border.all(color: Colors.white, width: 2) : null,
        ),
      ),
    );
  }
}
