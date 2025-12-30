import 'package:flutter/material.dart';

/// App color palette for ThreadVerse
class AppColors {
  AppColors._();

  // Primary Colors (Orange/Upvote theme)
  static const Color primary = Color(0xFFFF4500); // Reddit-like orange
  static const Color primaryLight = Color(0xFFFF6B35);
  static const Color primaryDark = Color(0xFFCC3700);

  // Accent Colors
  static const Color accent = Color(0xFF0079D3); // Blue for links/actions
  static const Color accentLight = Color(0xFF3399E6);

  // Voting Colors
  static const Color upvote = Color(0xFFFF4500); // Orange
  static const Color downvote = Color(0xFF7193FF); // Periwinkle blue

  // Neutral Colors - Light Mode
  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color lightSurface = Color(0xFFF5F5F5);
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightDivider = Color(0xFFE0E0E0);

  // Neutral Colors - Dark Mode
  static const Color darkBackground = Color(0xFF1A1A1B);
  static const Color darkSurface = Color(0xFF272729);
  static const Color darkCard = Color(0xFF1A1A1B);
  static const Color darkDivider = Color(0xFF343536);

  // AMOLED Mode (Pure black)
  static const Color amoledBackground = Color(0xFF000000);
  static const Color amoledSurface = Color(0xFF121212);

  // Text Colors
  static const Color textPrimary = Color(0xFF222222);
  static const Color textSecondary = Color(0xFF7C7C7C);
  static const Color textTertiary = Color(0xFFB8B8B8);
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status Colors
  static const Color success = Color(0xFF46D160);
  static const Color error = Color(0xFFEA0027);
  static const Color warning = Color(0xFFFFA500);
  static const Color info = Color(0xFF0079D3);

  // Special Colors
  static const Color gold = Color(0xFFFFD700); // Awards/Premium
  static const Color silver = Color(0xFFC0C0C0);
  static const Color nsfw = Color(0xFFFF4458);
  static const Color spoiler = Color(0xFF4ECDC4);
  static const Color pinned = Color(0xFF46D160);
}
