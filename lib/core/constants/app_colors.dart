import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ===== Brand =====
  static const Color primary = Color(0xFF0F766E);
  static const Color primaryLight = Color(0xFF14B8A6);
  static const Color primaryDark = Color(0xFF115E59);
  static const Color accent = Color(0xFFF59E0B);
  static const Color accentLight = Color(0xFFFBBF24);

  // ===== Status =====
  static const Color success = Color(0xFF16A34A);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF2563EB);

  // ===== E-commerce specific =====
  static const Color discount = Color(0xFFDC2626);
  static const Color rating = Color(0xFFFBBF24);
  static const Color priceTag = Color(0xFF0F766E);

  static const Color inStock = Color(0xFF16A34A);
  static const Color lowStock = Color(0xFFF59E0B);
  static const Color outOfStock = Color(0xFFDC2626);

  static const Color lightBackground = Color(0xFFF9FAFB);
  static const Color lightSurface = Color(0xFFFFFFFF);
  static const Color lightSurfaceVariant = Color(0xFFF3F4F6);
  static const Color lightTextPrimary = Color(0xFF111827);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextHint = Color(0xFF9CA3AF);
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightDivider = Color(0xFFE5E7EB);
  static const Color lightShimmerBase = Color(0xFFE5E7EB);
  static const Color lightShimmerHighlight = Color(0xFFF3F4F6);

  static const Color darkBackground = Color(0xFF0F1115);
  static const Color darkSurface = Color(0xFF1A1D23);
  static const Color darkSurfaceVariant = Color(0xFF23272F);
  static const Color darkTextPrimary = Color(0xFFF3F4F6);
  static const Color darkTextSecondary = Color(0xFF9CA3AF);
  static const Color darkTextHint = Color(0xFF6B7280);
  static const Color darkBorder = Color(0xFF2D3139);
  static const Color darkDivider = Color(0xFF2D3139);
  static const Color darkShimmerBase = Color(0xFF23272F);
  static const Color darkShimmerHighlight = Color(0xFF2D3139);

  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color transparent = Colors.transparent;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient discountGradient = LinearGradient(
    colors: [Color(0xFFDC2626), Color(0xFFF59E0B)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
