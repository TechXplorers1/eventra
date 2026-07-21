/// Eventra spacing constants — 8pt grid system
class AppSpacing {
  AppSpacing._();

  // ── Base units ────────────────────────────────────────────────────────────
  static const double xs  = 4.0;
  static const double sm  = 8.0;
  static const double md  = 16.0;
  static const double lg  = 24.0;
  static const double xl  = 32.0;
  static const double x2l = 48.0;
  static const double x3l = 64.0;

  // ── Page padding ─────────────────────────────────────────────────────────
  static const double pagePaddingH = 16.0;   // horizontal page margin
  static const double pagePaddingV = 16.0;   // vertical top padding
  static const double listBottomPad = 120.0; // clearance for floating bottom nav

  // ── Component internals ──────────────────────────────────────────────────
  static const double cardPadding    = 16.0;
  static const double buttonHeight   = 52.0;
  static const double inputHeight    = 52.0;
  static const double chipPaddingH   = 14.0;
  static const double chipPaddingV   = 8.0;
  static const double sectionSpacing = 28.0; // between major sections
  static const double itemSpacing    = 12.0; // between list items
  static const double innerSpacing   = 8.0;  // within a component

  // ── Border radius ─────────────────────────────────────────────────────────
  static const double radiusXs   = 6.0;
  static const double radiusSm   = 10.0;
  static const double radiusMd   = 14.0;   // button default
  static const double radiusLg   = 16.0;   // card default
  static const double radiusXl   = 20.0;
  static const double radiusChip = 100.0;  // fully rounded chips
  static const double radiusModal = 24.0;  // bottom sheets

  // ── Icon sizes ────────────────────────────────────────────────────────────
  static const double iconXs  = 12.0;
  static const double iconSm  = 16.0;
  static const double iconMd  = 20.0;
  static const double iconLg  = 24.0;
  static const double iconXl  = 32.0;
}
