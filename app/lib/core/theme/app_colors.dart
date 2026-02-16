import 'package:flutter/material.dart';

/// Design tokens extracted from UI&UX.pen variables.
/// Maps directly to the design system's variable names.
class AppColors {
  AppColors._();

  // ── Brand / Accent ──
  static const Color accentOrange = Color(0xFFC2410C);
  static const Color successGreen = Color(0xFF10B981);
  static const Color alertRed = Color(0xFFEF4444);

  // ── Backgrounds ──
  static const Color bgPrimary = Color(0xFFFAF9F7);
  static const Color bgSurface = Color(0xFFE7E5E4);
  static const Color bgMuted = Color(0xFFD6D3D1);
  static const Color bgDark = Color(0xFF2D2D2D);
  static const Color bgDarkMuted = Color(0xFF44403C);

  // ── Text ──
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF78716C);
  static const Color textTertiary = Color(0xFFA8A29E);
  static const Color textOnDark = Color(0xFFFAF9F7);
  static const Color textMutedOnDark = Color(0xFFA8A29E);
  static const Color onAccent = Color(0xFFFAF9F7);

  // ── Borders ──
  static const Color borderSubtle = Color(0xFFD6D3D1);

  // ── Web Dashboard ──
  static const Color webBg = Color(0xFFFAFAF9);
  static const Color webCardBg = Color(0xFFFFFFFF);
  static const Color webCardBorder = Color(0xFFE7E5E4);
  static const Color webIndigo = Color(0xFF1E1B4B);
  static const Color webIndigoLight = Color(0xFF4F46E5);
  static const Color webSidebarBg = Color(0xFF1C1917);
  static const Color webSidebarHover = Color(0xFF292524);
  static const Color webSidebarText = Color(0xFFD6D3D1);
  static const Color webSidebarTextActive = Color(0xFFFAF9F7);
  static const Color webSidebarActive = Color(0xFFC2410C);
  static const Color webTableHeader = Color(0xFFF5F5F4);
  static const Color webTableRowAlt = Color(0xFFFAFAF9);

  // ── Status Badge Colors ──
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingFg = Color(0xFFD97706);
  static const Color badgeDeliveredBg = Color(0xFFECFDF5);
  static const Color badgeDeliveredFg = Color(0xFF10B981);
  static const Color badgeCODBg = Color(0xFFFEE2E2);
  static const Color badgeCODFg = Color(0xFFEF4444);
}
