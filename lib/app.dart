import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'core/theme/dark_theme.dart';

import 'features/home/screens/main_navigation_screen.dart';

class TeamPayApp extends StatelessWidget {
  const TeamPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      title: 'TeamPay',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: DarkAppTheme.darkTheme,
      themeMode: themeProvider.themeMode,
      home: const MainNavigationScreen(),
    );
  }
}
