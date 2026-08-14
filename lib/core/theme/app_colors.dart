import 'package:flutter/material.dart';

class AppColors {
  // ── Primary Brand ────────────────────────────────────────────────────────
  static final primary       = HSLColor.fromAHSL(1.0, 263, 0.60, 0.65).toColor(); // Light/Soft Purple
  static final primaryLight  = HSLColor.fromAHSL(1.0, 263, 0.60, 0.75).toColor(); // hover
  static final primaryForeground = const Color(0xFFFFFFFF);

  // ── Accent ───────────────────────────────────────────────────────────────
  static final accent        = HSLColor.fromAHSL(1.0, 275, 0.50, 0.65).toColor();  // Subtle analogous purple
  static final accentLight   = HSLColor.fromAHSL(1.0, 275, 0.50, 0.65).toColor().withAlpha(30);
  static const accentForeground = Color(0xFFFFFFFF);

  // ── Surface / Background ────────────────────────────────────────────────
  static final background    = const Color(0xFF09090B); // Very dark, almost black
  static final card          = const Color(0xFF121214); // Slightly lighter for cards
  static final secondary     = const Color(0xFF1A1A1D); // For secondary elements
  static final muted         = const Color(0xFF27272A); // Muted dark background

  // ── Text ────────────────────────────────────────────────────────────────
  static final foreground         = const Color(0xFFFAFAFA); // Near white
  static final secondaryForeground= const Color(0xFFE4E4E7); // Light gray
  static final cardForeground     = const Color(0xFFFAFAFA); // Near white
  static final mutedForeground    = const Color(0xFFA1A1AA); // Gray

  // ── Border / Input ────────────────────────────────────────────────────────
  static final border        = const Color(0xFF27272A); // Dark border
  static final input         = const Color(0xFF18181B); // Input background
  static final ring          = HSLColor.fromAHSL(1.0, 263, 0.60, 0.65).toColor();

  // ── Semantic ────────────────────────────────────────────────────────────
  static const success       = Color(0xFF22C55E);  // green-500
  static const successLight  = Color(0xFF16A34A);
  static const warning       = Color(0xFFF59E0B);  // amber-500
  static const warningLight  = Color(0xFFD97706);
  static const error         = Color(0xFFEF4444);  // red-500
  static const errorLight    = Color(0xFFDC2626);
  static const info          = Color(0xFF3B82F6);  // blue-500

  // ── Legacy aliases (kept for existing code compatibility) ─────────────
  static final popover            = const Color(0xFF121214);
  static final popoverForeground  = const Color(0xFFFAFAFA);
  static final destructive        = error;
  static final destructiveForeground = const Color(0xFFFFFFFF);

  // ── Gradient helpers ─────────────────────────────────────────────────────
  static LinearGradient get primaryGradient => LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final LinearGradient accentGradient = LinearGradient(
    colors: [accent, HSLColor.fromAHSL(1.0, 275, 0.50, 0.75).toColor()],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get cardGradient => LinearGradient(
    colors: [card, secondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
