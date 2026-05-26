import 'package:flutter/material.dart';

/// Paleta central de colores de TeamPay.
/// Si quieres ajustar el look general, este suele ser el primer lugar.
class AppColors {
  // Light
  static const lightBackground = Color(0xFFF7F8FA);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F3F5);
  static const lightBorder = Color(0xFFE1E4E8);

  static const lightTextPrimary = Color(0xFF111827);
  static const lightTextSecondary = Color(0xFF6B7280);

  // Dark
  static const darkBackground = Color(0xFF0F1115);
  static const darkSurface = Color(0xFF181B20);
  static const darkSurfaceVariant = Color(0xFF22262D);
  static const darkBorder = Color(0xFF2C3138);

  static const darkTextPrimary = Color(0xFFF1F3F6);
  static const darkTextSecondary = Color(0xFFA7ADB5);

  // Brand / states
  static const primary = Color(0xFF14B8A6);
  static const primaryDark = Color(0xFF0F766E);

  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const warningBackground = Color(0xFFFFF4E5);

  // Legacy aliases para no romper código existente
  static const textSecondary = lightTextSecondary;
  static const softSurface = lightSurfaceVariant;
  static const avatarBackground = lightSurfaceVariant;
}
