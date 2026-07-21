import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../shared/widgets/ev_components.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  static IconData _iconFor(String type) {
    switch (type) {
      case 'booking':  return LucideIcons.ticket;
      case 'reminder': return LucideIcons.clock3;
      case 'offer':    return LucideIcons.tag;
      case 'quote':    return LucideIcons.fileText;
      case 'invite':   return LucideIcons.mailOpen;
      case 'system':   return LucideIcons.info;
      default:         return LucideIcons.bell;
    }
  }

  static Color _colorFor(String type) {
    switch (type) {
      case 'booking':  return AppColors.success;
      case 'reminder': return AppColors.primary;
      case 'offer':    return AppColors.accent;
      case 'quote':    return AppColors.warning;
      case 'invite':   return const Color(0xFFEC4899);
      case 'system':   return AppColors.mutedForeground;
      default:         return AppColors.primary;
    }
  }

  static String _labelFor(String type) {
    switch (type) {
      case 'booking':  return 'Booking';
      case 'reminder': return 'Reminder';
      case 'offer':    return 'Offer';
      case 'quote':    return 'Quote';
      case 'invite':   return 'Invite';
      case 'system':   return 'System';
      default:         return 'Notification';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(appProvider.select((s) => s.notifications));
    final unread = notifications.where((n) => !n.isRead).length;

    // Group: today vs earlier
    final today = <AppNotification>[];
    final earlier = <AppNotification>[];
    for (final n in notifications) {
      // Simple heuristic: if time contains 'ago' or 'just now' → today
      final t = n.time.toLowerCase();
      if (t.contains('ago') || t.contains('just now') || t.contains('hour') || t.contains('min')) {
        today.add(n);
      } else {
        earlier.add(n);
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ── App Bar ─────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingH, AppSpacing.pagePaddingV,
                AppSpacing.pagePaddingH, 0,
              ),
              child: Row(
                children: [
                  EvBackButton(onPressed: () => context.pop()),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Notifications', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                      if (unread > 0)
                        Text('$unread unread', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
                    ]),
                  ),
                  if (unread > 0)
                    GestureDetector(
                      onTap: () => ref.read(appProvider.notifier).markAllNotificationsRead(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withAlpha(18),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppColors.primary.withAlpha(60)),
                        ),
                        child: Text('Mark all read',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // ── List ─────────────────────────────────────────────────────
            if (notifications.isEmpty)
              Expanded(
                child: EvEmptyState(
                  icon: LucideIcons.bellOff,
                  title: "You're all caught up!",
                  subtitle: 'No notifications yet. We\'ll let you know when something happens.',
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingH, 0,
                    AppSpacing.pagePaddingH, AppSpacing.md,
                  ),
                  children: [
                    if (today.isNotEmpty) ...[
                      _GroupLabel('Today'),
                      ...today.map((n) => _NotifTile(
                        n: n,
                        icon: _iconFor(n.type),
                        color: _colorFor(n.type),
                        typeLabel: _labelFor(n.type),
                        onTap: () => ref.read(appProvider.notifier).markNotificationRead(n.id),
                      )),
                    ],
                    if (earlier.isNotEmpty) ...[
                      _GroupLabel('Earlier'),
                      ...earlier.map((n) => _NotifTile(
                        n: n,
                        icon: _iconFor(n.type),
                        color: _colorFor(n.type),
                        typeLabel: _labelFor(n.type),
                        onTap: () => ref.read(appProvider.notifier).markNotificationRead(n.id),
                      )),
                    ],
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ── Group label ───────────────────────────────────────────────────────────────
class _GroupLabel extends StatelessWidget {
  final String label;
  const _GroupLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, top: 4),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 0.8),
      ),
    );
  }
}

// ── Notification Tile ─────────────────────────────────────────────────────────
class _NotifTile extends StatelessWidget {
  final AppNotification n;
  final IconData icon;
  final Color color;
  final String typeLabel;
  final VoidCallback onTap;

  const _NotifTile({
    required this.n,
    required this.icon,
    required this.color,
    required this.typeLabel,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: n.isRead ? AppColors.card : AppColors.primary.withAlpha(8),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(
            color: n.isRead ? AppColors.border : AppColors.primary.withAlpha(60),
            width: n.isRead ? 1 : 1.5,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 42, height: 42,
              decoration: BoxDecoration(
                color: color.withAlpha(22),
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const SizedBox(width: AppSpacing.sm),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: color.withAlpha(20),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(typeLabel, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
                    ),
                    const Spacer(),
                    if (!n.isRead)
                      Container(
                        width: 7, height: 7,
                        decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      ),
                  ]),
                  const SizedBox(height: 5),
                  Text(n.title,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w700,
                        color: AppColors.foreground,
                      )),
                  const SizedBox(height: 3),
                  Text(n.body,
                      style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.4),
                      maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 5),
                  Text(n.time, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
