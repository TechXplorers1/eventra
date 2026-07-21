import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Reusable badge component (status pill, count, label)
class EvBadge extends StatelessWidget {
  final String label;
  final Color? color;
  final IconData? icon;
  final bool small;

  const EvBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.small = false,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.primary;
    final fs = small ? 9.0 : 11.0;
    final px = small ? 6.0 : 8.0;
    final py = small ? 2.0 : 3.0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: px, vertical: py),
      decoration: BoxDecoration(
        color: c.withAlpha(28),
        borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        if (icon != null) ...[Icon(icon, size: small ? 9 : 11, color: c), const SizedBox(width: 3)],
        Text(label, style: TextStyle(fontSize: fs, fontWeight: FontWeight.w700, color: c)),
      ]),
    );
  }
}

/// Status-specific badges
class EvStatusBadge extends StatelessWidget {
  final String status;
  const EvStatusBadge(this.status, {super.key});

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status.toLowerCase()) {
      'confirmed' || 'accepted' || 'completed' || 'published' || 'available'
          => (status, AppColors.success),
      'pending' || 'draft' || 'requested'
          => (status, AppColors.warning),
      'cancelled' || 'declined' || 'rejected' || 'busy'
          => (status, AppColors.error),
      'private'
          => ('Private', Colors.orange),
      'public'
          => ('Public', AppColors.success),
      'vip' => ('VIP', AppColors.accent),
      _ => (status, AppColors.mutedForeground),
    };
    return EvBadge(label: _capitalize(label), color: color);
  }

  String _capitalize(String s) => s.isEmpty ? s : '${s[0].toUpperCase()}${s.substring(1)}';
}

/// Notification dot badge
class EvDotBadge extends StatelessWidget {
  final Widget child;
  final bool show;
  final Color? color;
  const EvDotBadge({super.key, required this.child, this.show = true, this.color});

  @override
  Widget build(BuildContext context) {
    if (!show) return child;
    return Stack(clipBehavior: Clip.none, children: [
      child,
      Positioned(
        top: -2,
        right: -2,
        child: Container(
          width: 8, height: 8,
          decoration: BoxDecoration(
            color: color ?? AppColors.accent,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.background, width: 1.5),
          ),
        ),
      ),
    ]);
  }
}

/// Chip selector — used for categories, filters, availability toggles
class EvChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;
  final Color? selectedColor;

  const EvChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
    this.selectedColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = selectedColor ?? AppColors.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.chipPaddingH, vertical: AppSpacing.chipPaddingV),
        decoration: BoxDecoration(
          color: selected ? c.withAlpha(28) : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
          border: Border.all(
            color: selected ? c : AppColors.border,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          if (icon != null) ...[Icon(icon, size: 13, color: selected ? c : AppColors.mutedForeground), const SizedBox(width: 5)],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? c : AppColors.mutedForeground),
          ),
        ]),
      ),
    );
  }
}
