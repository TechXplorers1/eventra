import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/app_provider.dart';
import '../../core/models/app_models.dart';

class _NavItem {
  final String path;
  final IconData icon;
  final IconData? activeIcon;
  final String label;

  const _NavItem(this.path, this.icon, this.label, {this.activeIcon});
}

// ── Attendee: Home | Explore | Services | Bookings | Profile ──────────────────
const _attendeeTabs = [
  _NavItem('/home',     LucideIcons.home,     'Home',     activeIcon: LucideIcons.home),
  _NavItem('/explore',  LucideIcons.compass,  'Explore'),
  _NavItem('/services', LucideIcons.sparkles, 'Services'),
  _NavItem('/tickets',  LucideIcons.ticket,   'Bookings'),
  _NavItem('/profile',  LucideIcons.user,     'Profile'),
];

// ── Organizer: Dashboard | Events | Create | Requests | Profile ───────────────
const _organizerTabs = [
  _NavItem('/organizer',          LucideIcons.layoutDashboard, 'Dashboard'),
  _NavItem('/organizer/events',   LucideIcons.calendarDays,    'Events'),
  _NavItem('/organizer/create',   LucideIcons.plus,            'Create'),
  _NavItem('/organizer/services/requests', LucideIcons.briefcase,       'Requests'),
  _NavItem('/organizer/profile',  LucideIcons.user,            'Profile'),
];

// ── Service Provider: Dashboard | Bookings | Calendar | Profile ───────────────
const _serviceTabs = [
  _NavItem('/service-provider',           LucideIcons.layoutDashboard, 'Dashboard'),
  _NavItem('/service-provider/requests',  LucideIcons.inbox,           'Bookings'),
  _NavItem('/service-provider/calendar',  LucideIcons.calendar,        'Calendar'),
  _NavItem('/service-provider/profile',   LucideIcons.user,            'Profile'),
];

class BottomNav extends ConsumerWidget {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    if (appState.hideBottomNav) return const SizedBox.shrink();

    final role = appState.role ?? Role.attendee;
    final tabs = switch (role) {
      Role.attendee  => _attendeeTabs,
      Role.organizer => _organizerTabs,
      Role.service   => _serviceTabs,
    };

    final location = GoRouterState.of(context).uri.toString();
    int activeIdx = -1;
    int bestLen = -1;
    for (int i = 0; i < tabs.length; i++) {
      final t = tabs[i];
      if ((location == t.path || location.startsWith('${t.path}/')) && t.path.length > bestLen) {
        bestLen = t.path.length;
        activeIdx = i;
      }
    }

    final navContent = SafeArea(
      child: Container(
        height: 66,
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(80),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: AppColors.primary.withAlpha(20),
              blurRadius: 32,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: List.generate(tabs.length, (idx) {
            final tab = tabs[idx];
            final isActive = idx == activeIdx;
            final isCreate = tab.label == 'Create';

            if (isCreate) {
              // Special "Create" FAB-style tab for Organizer
              return Expanded(
                child: GestureDetector(
                  onTap: () => context.go(tab.path),
                  child: Center(
                    child: Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withAlpha(80),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(LucideIcons.plus, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              );
            }

            return Expanded(
              child: _NavTabItem(
                tab: tab,
                isActive: isActive,
                onTap: () => context.go(tab.path),
              ),
            );
          }),
        ),
      ),
    );

    final isInsideStack = context.findAncestorWidgetOfExactType<Stack>() != null;
    if (isInsideStack) {
      return Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        child: navContent,
      );
    }

    return navContent;
  }
}

class _NavTabItem extends StatelessWidget {
  final _NavItem tab;
  final bool isActive;
  final VoidCallback onTap;

  const _NavTabItem({required this.tab, required this.isActive, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isActive ? AppColors.primary.withAlpha(28) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              tab.icon,
              size: 19,
              color: isActive ? AppColors.primary : AppColors.mutedForeground,
            ),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 200),
            style: TextStyle(
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
              color: isActive ? AppColors.primary : AppColors.mutedForeground,
            ),
            child: Text(
              tab.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
