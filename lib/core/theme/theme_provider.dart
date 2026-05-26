import 'package:flutter/material.dart';

/// Guarda el modo de tema elegido.
/// Cuando cambia, avisa a la app para repintar claro/oscuro.
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    notifyListeners();
  }
}
