import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_spacing.dart';

/// Section header with optional "See All" action
class EvSectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EvSectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(subtitle!, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              ],
            ],
          ),
        ),
        if (actionLabel != null && onAction != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionLabel!,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary),
            ),
          ),
      ],
    );
  }
}

/// Premium empty state with icon, title, subtitle, and optional CTA
class EvEmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EvEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.x2l),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88, height: 88,
              decoration: BoxDecoration(
                color: AppColors.secondary,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, size: 36, color: AppColors.mutedForeground),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              subtitle,
              style: TextStyle(fontSize: 14, color: AppColors.mutedForeground, height: 1.5),
              textAlign: TextAlign.center,
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppSpacing.lg),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: onAction,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd)),
                  ),
                  child: Text(actionLabel!, style: const TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.x3l),
          ],
        ),
      ),
    );
  }
}

/// App bar back button — standardized across all screens
class EvBackButton extends StatelessWidget {
  final VoidCallback? onPressed;
  const EvBackButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.secondary,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onPressed ?? () => Navigator.of(context).pop(),
        child: const SizedBox(
          width: 40, height: 40,
          child: Icon(Icons.arrow_back_ios_new_rounded, size: 16),
        ),
      ),
    );
  }
}

/// Divider with label in center (used in forms/settings)
class EvDividerLabel extends StatelessWidget {
  final String label;
  const EvDividerLabel(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: Divider(color: AppColors.border)),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
        child: Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
      ),
      Expanded(child: Divider(color: AppColors.border)),
    ]);
  }
}

/// Stat row — icon + label + value (used in KPI/detail rows)
class EvStatRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const EvStatRow({super.key, required this.icon, required this.label, required this.value, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(children: [
        Icon(icon, size: 13, color: iconColor ?? AppColors.mutedForeground),
        const SizedBox(width: 8),
        Text(label, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
        const Spacer(),
        Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
      ]),
    );
  }
}

/// KPI metric card — icon + value + label
class EvKpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final String? change;
  final Color? accentColor;

  const EvKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.change,
    this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = accentColor ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: c.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, size: 16, color: c),
              ),
              if (change != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.success.withAlpha(26), borderRadius: BorderRadius.circular(8)),
                  child: Text(change!, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.success)),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.foreground)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
        ],
      ),
    );
  }
}
