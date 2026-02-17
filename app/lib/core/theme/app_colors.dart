import 'package:flutter/material.dart';

/// Design tokens extracted from DESIGN_CONTEXT.md specifications.
/// Updated to match L'Carnet B2B Master Design Prompt (Morocco B2B).
class AppColors {
  AppColors._();

  // ── Primary Brand (New Design System) ──
  static const Color primary = Color(0xFF4F46E5); // Deep Indigo — Trust & Business
  static const Color successGreen = Color(0xFF10B981); // Emerald Green — Money & Confirmation
  static const Color alertRed = Color(0xFFE11D48); // Rose Red — Debt & Errors
  
  // ── Legacy Brand Colors (for backward compatibility) ──
  @Deprecated('Use primary instead')
  static const Color accentOrange = Color(0xFFC2410C);

  // ── Backgrounds ──
  static const Color bgPrimary = Color(0xFFF8FAFC); // Slate Gray — Clean, low glare
  static const Color bgSurface = Color(0xFFFFFFFF); // White — Card backgrounds
  static const Color bgMuted = Color(0xFFE2E8F0); // Cool gray — Borders, dividers
  static const Color bgDark = Color(0xFF1E293B);
  static const Color bgDarkMuted = Color(0xFF334155);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textTertiary = Color(0xFF94A3B8);
  static const Color textOnDark = Color(0xFFF8FAFC);
  static const Color textMutedOnDark = Color(0xFF94A3B8);
  static const Color onAccent = Color(0xFFFFFFFF);

  // ── Borders ──
  static const Color borderSubtle = Color(0xFFE2E8F0);

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

  // ── Status Badge Colors (Updated for New Design) ──
  static const Color badgePendingBg = Color(0xFFFEF3C7);
  static const Color badgePendingFg = Color(0xFFD97706);
  static const Color badgeDeliveredBg = Color(0xFFD1FAE5);
  static const Color badgeDeliveredFg = Color(0xFF065F46);
  static const Color badgeCODBg = Color(0xFFFEE2E2);
  static const Color badgeCODFg = Color(0xFF991B1B);
  
  // ── New Status Badges (Open/Closed, Credit/Debt) ──
  static const Color badgeOpenBg = Color(0xFFDBEAFE);
  static const Color badgeOpenFg = Color(0xFF1E40AF);
  static const Color badgeClosedBg = Color(0xFFFEE2E2);
  static const Color badgeClosedFg = Color(0xFF991B1B);
  static const Color badgeCreditBg = Color(0xFFD1FAE5);
  static const Color badgeCreditFg = Color(0xFF065F46);
  static const Color badgeDebtBg = Color(0xFFFEE2E2);
  static const Color badgeDebtFg = Color(0xFF991B1B);
}
