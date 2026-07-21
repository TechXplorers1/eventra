import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Brand ────────────────────────────────────────────────────────
  static final primary       = HSLColor.fromAHSL(1.0, 263, 0.70, 0.55).toColor(); // Deep Indigo
  static final primaryLight  = HSLColor.fromAHSL(1.0, 263, 0.70, 0.65).toColor(); // hover
  static final primaryForeground = const Color(0xFFFFFFFF);

  // ── Accent (Orange/Coral) ────────────────────────────────────────────────
  static const accent        = Color(0xFFFF6B35);  // vibrant orange-coral
  static final accentLight   = const Color(0xFFFF6B35).withAlpha(30);
  static const accentForeground = Color(0xFFFFFFFF);

  // ── Surface / Background ────────────────────────────────────────────────
  static final background    = HSLColor.fromAHSL(1.0, 260, 0.20, 0.05).toColor();
  static final card          = HSLColor.fromAHSL(1.0, 260, 0.15, 0.09).toColor();
  static final secondary     = HSLColor.fromAHSL(1.0, 260, 0.15, 0.14).toColor();
  static final muted         = HSLColor.fromAHSL(1.0, 260, 0.10, 0.18).toColor();

  // ── Text ────────────────────────────────────────────────────────────────
  static final foreground         = HSLColor.fromAHSL(1.0, 0, 0.00, 0.98).toColor();
  static final secondaryForeground= HSLColor.fromAHSL(1.0, 0, 0.00, 0.90).toColor();
  static final cardForeground     = HSLColor.fromAHSL(1.0, 0, 0.00, 0.98).toColor();
  static final mutedForeground    = HSLColor.fromAHSL(1.0, 260, 0.05, 0.55).toColor();

  // ── Border / Input ────────────────────────────────────────────────────────
  static final border        = HSLColor.fromAHSL(1.0, 260, 0.10, 0.16).toColor();
  static final input         = HSLColor.fromAHSL(1.0, 260, 0.12, 0.12).toColor();
  static final ring          = HSLColor.fromAHSL(1.0, 263, 0.70, 0.55).toColor();

  // ── Semantic ────────────────────────────────────────────────────────────
  static const success       = Color(0xFF22C55E);  // green-500
  static const successLight  = Color(0xFF16A34A);
  static const warning       = Color(0xFFF59E0B);  // amber-500
  static const warningLight  = Color(0xFFD97706);
  static const error         = Color(0xFFEF4444);  // red-500
  static const errorLight    = Color(0xFFDC2626);
  static const info          = Color(0xFF3B82F6);  // blue-500

  // ── Legacy aliases (kept for existing code compatibility) ─────────────
  static final popover            = HSLColor.fromAHSL(1.0, 260, 0.15, 0.09).toColor();
  static final popoverForeground  = HSLColor.fromAHSL(1.0, 0, 0.00, 0.98).toColor();
  static final destructive        = error;
  static final destructiveForeground = const Color(0xFFFFFFFF);

  // ── Gradient helpers ─────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C55)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: [card, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
