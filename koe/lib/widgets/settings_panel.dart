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
    final isDark = currentTheme.isDarkMode;

    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  const Color(0xFF1A1A1A),
                  const Color(0xFF2D2D2D),
                  const Color(0xFF1A1A1A),
                ]
              : [Colors.white, Colors.grey.shade50, Colors.white],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with close button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Settings',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: isDark ? Colors.white : Colors.black,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: mainColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        onPressed: saveSettings,
                        icon: Icon(Icons.close, color: mainColor, size: 24),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Theme Mode Section
                _buildSectionTitle('Theme Mode', Icons.palette, mainColor),
                const SizedBox(height: 16),

                // Theme Mode Cards
                Row(
                  children: [
                    Expanded(
                      child: _buildThemeModeCard(
                        title: 'Light',
                        subtitle: 'Clean & Bright',
                        icon: Icons.light_mode,
                        isSelected: !isDark,
                        isDark: false,
                        mainColor: mainColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildThemeModeCard(
                        title: 'Dark',
                        subtitle: 'Easy on Eyes',
                        icon: Icons.dark_mode,
                        isSelected: isDark,
                        isDark: true,
                        mainColor: mainColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Color Palette Section
                _buildSectionTitle(
                  'Color Palette',
                  Icons.color_lens,
                  mainColor,
                ),
                const SizedBox(height: 16),

                // Current Palette Display
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorPalette['light']!,
                        colorPalette['main']!,
                        colorPalette['dark']!,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(Icons.check, color: mainColor, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Current Theme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              currentTheme.paletteName.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Palette Grid
                Container(
                  height: 250, // Fixed height for the grid
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 1,
                        ),
                    itemCount: KoeColorName.values.length,
                    itemBuilder: (context, index) {
                      return _buildPaletteOption(
                        KoeColorName.values[index],
                        mainColor,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButton(
                  onPressed: saveSettings,
                  text: 'Save Changes',
                  icon: Icons.save,
                  backgroundColor: mainColor,
                  textColor: Colors.white,
                ),
                const SizedBox(height: 12),

                _buildActionButton(
                  onPressed: logout,
                  text: 'Logout',
                  icon: Icons.logout,
                  backgroundColor: isDark
                      ? Colors.red.shade700
                      : Colors.red.shade500,
                  textColor: Colors.white,
                ),

                // Add bottom padding to account for NowPlayingBar
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon, Color mainColor) {
    final isDark = currentTheme.isDarkMode;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: mainColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: mainColor, size: 20),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildThemeModeCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required bool isDark,
    required Color mainColor,
  }) {
    final currentIsDark = currentTheme.isDarkMode;

    return GestureDetector(
      onTap: () => updateTheme(
        KoeTheme(paletteName: currentTheme.paletteName, isDarkMode: isDark),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? mainColor.withOpacity(0.1)
              : (currentIsDark ? Colors.grey.shade800 : Colors.grey.shade100),
          border: Border.all(
            color: isSelected ? mainColor : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? mainColor
                  : (currentIsDark
                        ? Colors.grey.shade400
                        : Colors.grey.shade600),
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: isSelected
                    ? mainColor
                    : (currentIsDark ? Colors.white : Colors.black),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: isSelected
                    ? mainColor.withOpacity(0.8)
                    : (currentIsDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaletteOption(KoeColorName palette, Color mainColor) {
    final isSelected = currentTheme.paletteName == palette;
    final colors = KoePalette.get(palette);
    final isDark = currentTheme.isDarkMode;

    return GestureDetector(
      onTap: () => updateTheme(
        KoeTheme(paletteName: palette, isDarkMode: currentTheme.isDarkMode),
      ),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors['light']!, colors['main']!, colors['dark']!],
          ),
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 3,
                )
              : null,
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 24),
              )
            : null,
      ),
    );
  }

  Widget _buildActionButton({
    required VoidCallback onPressed,
    required String text,
    required IconData icon,
    required Color backgroundColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16)),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
