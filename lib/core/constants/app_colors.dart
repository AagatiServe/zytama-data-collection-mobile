import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand palette ──────────────────────────────────────────────────────────
  static const Color primary    = Color(0xFF0C6170); // Midnight Blue
  static const Color secondary  = Color(0xFF37BEB0); // Blue Green
  static const Color accent     = Color(0xFFA4E5E0); // Tiffany Blue
  static const Color background = Color(0xFFDBF5F0); // Baby Blue

  // ── Text ───────────────────────────────────────────────────────────────────
  static const Color textDark   = Color(0xFF071e27);
  static const Color textMedium = Color(0xFF2C4A52);
  static const Color textLight  = Color(0xFF5A7A82);

  // ── Surface / card ─────────────────────────────────────────────────────────
  static const Color surface     = Color(0xFFFFFFFF);
  static const Color surfaceDim  = Color(0xFFDBF5F0); // same as background
  static const Color outline     = Color(0xFFA4E5E0); // Tiffany Blue border
  static const Color outlineDim  = Color(0xFF37BEB0); // Blue Green border

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color error   = Color(0xFFba1a1a);
  static const Color success = Color(0xFF0C6170);
  static const Color warning = Color(0xFFE65100);

  // ── Dashboard (V3) ────────────────────────────────────────────────────────
  static const Color dashBg        = Color(0xFFE5F4EE); // light green bg
  static const Color dashDeep      = Color(0xFF0E3B38); // CTA button / deep teal
  static const Color dashMid       = Color(0xFF1F706A); // card label / mid teal
  static const Color dashTeal      = Color(0xFF34D6C2); // gradient start / bright teal
  static const Color dashTealMid   = Color(0xFF15877E); // gradient mid
  static const Color dashTealEnd   = Color(0xFF0A4F4A); // gradient end / darkest
  static const Color dashOrange    = Color(0xFFFF8A3D); // notification dot / streak icon
  static const Color dashRingLight = Color(0xFFA8FFF0); // ring arc light end
  static const Color dashGlow      = Color(0xFF7AF0DC); // live dot glow
  static const Color dashTealDark  = Color(0xFF0F6660); // icon box shadow / deep accent
}
