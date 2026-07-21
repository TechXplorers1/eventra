import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Standard Eventra card. Wraps content in a styled container.
class EvCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;
  final Color? color;
  final double? borderRadius;
  final bool highlighted; // primary-tinted border

  const EvCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.borderRadius,
    this.highlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppSpacing.radiusLg;
    final bg = color ?? AppColors.card;
    final borderColor = highlighted
        ? AppColors.primary.withAlpha(100)
        : AppColors.border;

    final inner = Padding(
      padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
      child: child,
    );

    if (onTap != null) {
      return Material(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: AppColors.primary.withAlpha(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: borderColor, width: highlighted ? 1.5 : 1),
            ),
            child: inner,
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: highlighted ? 1.5 : 1),
      ),
      child: inner,
    );
  }
}

/// Gradient card — used for featured/hero cards
class EvGradientCard extends StatelessWidget {
  final Widget child;
  final List<Color>? colors;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const EvGradientCard({
    super.key,
    required this.child,
    this.colors,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradient = LinearGradient(
      colors: colors ?? [AppColors.primary, AppColors.primaryLight],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: child,
        ),
      ),
    );
  }
}
