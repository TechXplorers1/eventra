import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';

class AppTheme {
  AppTheme._();

  // ── Text Styles ────────────────────────────────────────────────────────────
  static TextTheme get _textTheme {
    final base = GoogleFonts.interTextTheme(ThemeData.dark().textTheme);
    return base.copyWith(
      displayLarge:   base.displayLarge?.copyWith(fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: -0.5),
      displayMedium:  base.displayMedium?.copyWith(fontSize: 28, fontWeight: FontWeight.w700, letterSpacing: -0.3),
      displaySmall:   base.displaySmall?.copyWith(fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.2),
      headlineMedium: base.headlineMedium?.copyWith(fontSize: 20, fontWeight: FontWeight.w700),
      headlineSmall:  base.headlineSmall?.copyWith(fontSize: 18, fontWeight: FontWeight.w600),
      titleLarge:     base.titleLarge?.copyWith(fontSize: 16, fontWeight: FontWeight.w600),
      titleMedium:    base.titleMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      titleSmall:     base.titleSmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w600),
      bodyLarge:      base.bodyLarge?.copyWith(fontSize: 15, fontWeight: FontWeight.w400),
      bodyMedium:     base.bodyMedium?.copyWith(fontSize: 14, fontWeight: FontWeight.w400),
      bodySmall:      base.bodySmall?.copyWith(fontSize: 13, fontWeight: FontWeight.w400),
      labelLarge:     base.labelLarge?.copyWith(fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium:    base.labelMedium?.copyWith(fontSize: 12, fontWeight: FontWeight.w600),
      labelSmall:     base.labelSmall?.copyWith(fontSize: 11, fontWeight: FontWeight.w600),
    );
  }

  static ThemeData get darkTheme {
    final textTheme = _textTheme.apply(
      bodyColor: AppColors.foreground,
      displayColor: AppColors.foreground,
    );

    return ThemeData.dark(useMaterial3: true).copyWith(
      scaffoldBackgroundColor: AppColors.background,
      primaryColor: AppColors.primary,
      colorScheme: ColorScheme.dark(
        primary:          AppColors.primary,
        onPrimary:        AppColors.primaryForeground,
        primaryContainer: AppColors.primaryLight,
        secondary:        AppColors.secondary,
        onSecondary:      AppColors.secondaryForeground,
        tertiary:         AppColors.accent,
        onTertiary:       AppColors.accentForeground,
        surface:          AppColors.card,
        onSurface:        AppColors.foreground,
        error:            AppColors.error,
        onError:          const Color(0xFFFFFFFF),
        outline:          AppColors.border,
        outlineVariant:   AppColors.muted,
      ),
      textTheme: textTheme,

      // ── AppBar ────────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.foreground, size: AppSpacing.iconMd),
        titleTextStyle: GoogleFonts.inter(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.foreground,
        ),
      ),

      // ── Card ─────────────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: AppColors.card,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          side: BorderSide(color: AppColors.border),
        ),
      ),

      // ── ElevatedButton ────────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.primaryForeground,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),

      // ── OutlinedButton ───────────────────────────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.foreground,
          minimumSize: const Size(double.infinity, AppSpacing.buttonHeight),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 14),
          side: BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
        ),
      ),

      // ── TextButton ───────────────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        ),
      ),

      // ── InputDecoration ──────────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.card,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          borderSide: BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm + 2),
          borderSide: BorderSide(color: AppColors.error),
        ),
      ),

      // ── BottomSheet ──────────────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: AppColors.card,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusModal)),
        ),
        elevation: 0,
      ),

      // ── SnackBar ─────────────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.secondary,
        contentTextStyle: GoogleFonts.inter(color: AppColors.foreground, fontSize: 14),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
      ),

      // ── Divider ──────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(color: AppColors.border, thickness: 1, space: 0),

      // ── Switch ──────────────────────────────────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primaryForeground : AppColors.mutedForeground,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? AppColors.primary : AppColors.secondary,
        ),
      ),

      // ── Chip ─────────────────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.secondary,
        selectedColor: AppColors.primary,
        labelStyle: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w600),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide(color: AppColors.border),
      ),

      // ── Scrollbar ────────────────────────────────────────────────────────
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(AppColors.muted),
        radius: const Radius.circular(4),
      ),
    );
  }

  // ── Static text style shortcuts ───────────────────────────────────────────
  static TextStyle display(BuildContext context) =>
      Theme.of(context).textTheme.displayLarge!;
  static TextStyle heading(BuildContext context) =>
      Theme.of(context).textTheme.headlineMedium!;
  static TextStyle title(BuildContext context) =>
      Theme.of(context).textTheme.titleLarge!;
  static TextStyle body(BuildContext context) =>
      Theme.of(context).textTheme.bodyMedium!;
  static TextStyle caption(BuildContext context) =>
      Theme.of(context).textTheme.labelSmall!;
}
