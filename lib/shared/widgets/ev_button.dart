import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

enum EvButtonVariant { primary, secondary, outline, ghost, accent, danger }
enum EvButtonSize { sm, md, lg }

class EvButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final EvButtonVariant variant;
  final EvButtonSize size;
  final IconData? icon;
  final IconData? trailingIcon;
  final bool isLoading;
  final bool fullWidth;

  const EvButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = EvButtonVariant.primary,
    this.size = EvButtonSize.md,
    this.icon,
    this.trailingIcon,
    this.isLoading = false,
    this.fullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    final height = switch (size) {
      EvButtonSize.sm => 40.0,
      EvButtonSize.md => AppSpacing.buttonHeight,
      EvButtonSize.lg => 58.0,
    };
    final fontSize = switch (size) {
      EvButtonSize.sm => 12.0,
      EvButtonSize.md => 14.0,
      EvButtonSize.lg => 16.0,
    };
    final hPad = switch (size) {
      EvButtonSize.sm => 12.0,
      EvButtonSize.md => 20.0,
      EvButtonSize.lg => 24.0,
    };
    final (bg, fg, border) = switch (variant) {
      EvButtonVariant.primary   => (AppColors.primary, AppColors.primaryForeground, Colors.transparent),
      EvButtonVariant.accent    => (AppColors.accent, AppColors.accentForeground, Colors.transparent),
      EvButtonVariant.secondary => (AppColors.secondary, AppColors.foreground, Colors.transparent),
      EvButtonVariant.outline   => (Colors.transparent, AppColors.foreground, AppColors.border),
      EvButtonVariant.ghost     => (Colors.transparent, AppColors.mutedForeground, Colors.transparent),
      EvButtonVariant.danger    => (AppColors.error.withAlpha(26), AppColors.error, AppColors.error.withAlpha(60)),
    };

    final child = isLoading
        ? SizedBox(
            width: 18, height: 18,
            child: CircularProgressIndicator(strokeWidth: 2, color: fg),
          )
        : Row(
            mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: fg), const SizedBox(width: 8)],
              Text(label, style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700, color: fg)),
              if (trailingIcon != null) ...[const SizedBox(width: 6), Icon(trailingIcon, size: 14, color: fg)],
            ],
          );

    final btn = Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: isLoading ? null : onPressed,
        splashColor: fg.withAlpha(26),
        highlightColor: fg.withAlpha(13),
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: hPad),
          decoration: BoxDecoration(
            border: border == Colors.transparent ? null : Border.all(color: border),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          ),
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );

    if (fullWidth) return SizedBox(width: double.infinity, child: btn);
    return btn;
  }
}
