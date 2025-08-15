import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koe/clients/features/splash/view/pages/splash_page.dart';
import 'package:koe/core/theme/theme_provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          home: const SplashPage(),
          theme: themeProvider.theme,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}
