import 'package:flutter/material.dart';
import '../backend/koe_palette.dart';
import '../backend/theme.dart';

class SettingsPanel extends StatelessWidget {
  final KoeTheme currentTheme;
  final void Function(KoeTheme) updateTheme;
  final VoidCallback saveSettings;
  final VoidCallback logout;
  final VoidCallback? onSubscriptionsTap;

  const SettingsPanel({
    super.key,
    required this.currentTheme,
    required this.updateTheme,
    required this.saveSettings,
    required this.logout,
    this.onSubscriptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorPalette = KoePalette.get(currentTheme.paletteName);
    final mainColor = colorPalette['main']!;
    final isDark = currentTheme.isDarkMode;

    return GestureDetector(
      onTap: () {
        // Just call saveSettings to close the panel properly
        saveSettings();
      },
      child: Container(
        color: Colors.black.withOpacity(0.4),
        child: GestureDetector(
          onTap: () {},
          child: Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1C1C1E) : Colors.white,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    // iOS-style header
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF2C2C2E)
                            : Colors.grey.shade50,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(20),
                        ),
                      ),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () {
                              // Just call saveSettings to close the panel properly
                              saveSettings();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? Colors.grey.shade800
                                    : Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.arrow_back,
                                color: isDark ? Colors.white : Colors.black,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Settings',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Settings content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Theme Mode Toggle
                            _buildThemeToggle(isDark, mainColor),
                            const SizedBox(height: 32),

                            // Current Color Palette Display
                            _buildCurrentColorDisplay(isDark, mainColor),
                            const SizedBox(height: 16),

                            // Color Palette
                            _buildColorPalette(isDark, mainColor),
                            const SizedBox(height: 32),

                            // Subscriptions Button
                            if (onSubscriptionsTap != null) ...[
                              _buildSubscriptionsButton(isDark, mainColor),
                              const SizedBox(height: 32),
                            ],

                            // Spacer to push logout to bottom
                            const Spacer(),

                            // Logout Button at the bottom
                            _buildLogoutButton(isDark),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, bool isDark) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildThemeToggle(bool isDark, Color mainColor) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => updateTheme(
                KoeTheme(
                  paletteName: currentTheme.paletteName,
                  isDarkMode: false,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: !isDark ? mainColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.light_mode,
                      color: !isDark ? Colors.white : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Light',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: !isDark
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => updateTheme(
                KoeTheme(
                  paletteName: currentTheme.paletteName,
                  isDarkMode: true,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: isDark ? mainColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.dark_mode,
                      color: isDark ? Colors.white : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Dark',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? Colors.white
                            : (isDark ? Colors.white : Colors.black),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentColorDisplay(bool isDark, Color mainColor) {
    final currentColors = KoePalette.get(currentTheme.paletteName);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          // Current color preview
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  currentColors['light']!,
                  currentColors['main']!,
                  currentColors['dark']!,
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Current Theme',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                  ),
                ),
                Text(
                  currentTheme.paletteName.name.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildColorPalette(bool isDark, Color mainColor) {
    return Container(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: KoeColorName.values.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 12),
            child: _buildPaletteOption(KoeColorName.values[index], mainColor),
          );
        },
      ),
    );
  }

  Widget _buildSubscriptionsButton(bool isDark, Color mainColor) {
    return GestureDetector(
      onTap: onSubscriptionsTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.subscriptions, color: mainColor, size: 20),
            const SizedBox(width: 12),
            Text(
              'My Subscriptions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(bool isDark) {
    return GestureDetector(
      onTap: logout,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF2C2C2E) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.red.shade500, size: 20),
            const SizedBox(width: 12),
            Text(
              'Logout',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.red.shade500,
              ),
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
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colors['light']!, colors['main']!, colors['dark']!],
          ),
          borderRadius: BorderRadius.circular(22.5),
          border: isSelected
              ? Border.all(
                  color: isDark ? Colors.white : Colors.black,
                  width: 2.5,
                )
              : null,
        ),
        child: isSelected
            ? Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(22.5),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 18),
              )
            : null,
      ),
    );
  }
}
