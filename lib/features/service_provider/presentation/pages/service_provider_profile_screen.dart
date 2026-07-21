import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';
import '../../../../shared/widgets/ev_components.dart';

class ServiceProviderProfileScreen extends ConsumerWidget {
  const ServiceProviderProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final sp = appState.serviceProvider;
    final rating = double.tryParse(sp.rating) ?? 5.0;
    final requests = appState.serviceRequests;
    final confirmed = requests.where((r) => r.status == 'Confirmed').length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingH, AppSpacing.pagePaddingV,
                AppSpacing.pagePaddingH, AppSpacing.listBottomPad,
              ),
              children: [

                // ── Header Row ────────────────────────────────────────────
                Row(children: [
                  Text('Profile', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                  const Spacer(),
                  _IconBtn(icon: LucideIcons.settings2, onTap: () => context.push('/settings')),
                  const SizedBox(width: 8),
                  _IconBtn(icon: LucideIcons.bell, onTap: () => context.push('/notifications')),
                ]),
                const SizedBox(height: AppSpacing.lg),

                // ── Profile Hero Card ─────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Avatar
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                        ),
                        child: const Icon(LucideIcons.user, size: 32, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          sp.businessName.isNotEmpty ? sp.businessName : 'My Business',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          sp.fullName.isNotEmpty ? sp.fullName : 'Service Provider',
                          style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(180)),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          if (sp.serviceCategory.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(sp.serviceCategory,
                                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white)),
                            ),
                          const SizedBox(width: 6),
                          EvStatusBadge(sp.availability.toLowerCase()),
                        ]),
                      ])),
                      _IconBtn(
                        icon: LucideIcons.pencil,
                        onTap: () => context.push('/service-provider/portfolio'),
                        light: true,
                      ),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    // Stats Row
                    Row(children: [
                      _HeroStat(value: rating.toStringAsFixed(1), label: 'Rating', icon: LucideIcons.star),
                      _heroDivider(),
                      _HeroStat(value: '${sp.totalGigs}', label: 'Gigs', icon: LucideIcons.calendarCheck),
                      _heroDivider(),
                      _HeroStat(value: '$confirmed', label: 'Active', icon: LucideIcons.zap),
                      _heroDivider(),
                      _HeroStat(value: '${sp.experienceYears}y', label: 'Experience', icon: LucideIcons.award),
                    ]),
                  ]),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Bio / City snippet ────────────────────────────────────
                if (sp.bio.isNotEmpty || sp.city.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.cardPadding),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      if (sp.bio.isNotEmpty) ...[
                        Text(sp.bio, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground, height: 1.5)),
                        const SizedBox(height: 8),
                      ],
                      if (sp.city.isNotEmpty)
                        Row(children: [
                          Icon(LucideIcons.mapPin, size: 12, color: AppColors.mutedForeground),
                          const SizedBox(width: 4),
                          Text(sp.city, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                          if (sp.startingPrice > 0) ...[
                            const SizedBox(width: 16),
                            Icon(LucideIcons.indianRupee, size: 12, color: AppColors.mutedForeground),
                            const SizedBox(width: 2),
                            Text('From ₹${sp.startingPrice}',
                                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                          ],
                        ]),
                    ]),
                  ),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Portfolio & Business ──────────────────────────────────
                _SectionLabel('Portfolio & Business'),
                _MenuGroup([
                  _MenuItem(LucideIcons.image,       'Portfolio',  'Photos, videos and past work',   () => context.push('/service-provider/portfolio')),
                  _MenuItem(LucideIcons.package,     'Packages',   'Manage pricing and packages',     () => context.push('/service-provider/packages')),
                  _MenuItem(LucideIcons.star,        'Reviews',    'Client feedback and ratings',     () => context.push('/service-provider/reviews')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Account ───────────────────────────────────────────────
                _SectionLabel('Account'),
                _MenuGroup([
                  _MenuItem(LucideIcons.wallet,      'Earnings',   'Wallet and transaction history',  () => context.push('/service-provider/wallet')),
                  _MenuItem(LucideIcons.calendar,    'Calendar',   'Availability and bookings',       () => context.push('/service-provider/calendar')),
                  _MenuItem(LucideIcons.creditCard,  'Payments',   'Payment methods',                 () => context.push('/payment-methods')),
                  _MenuItem(LucideIcons.settings2,   'Settings',   'Preferences, privacy & security', () => context.push('/settings')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Support ───────────────────────────────────────────────
                _SectionLabel('Support'),
                _MenuGroup([
                  _MenuItem(LucideIcons.helpCircle,  'Help & Support',  'Get assistance',         () => context.push('/help')),
                  _MenuItem(LucideIcons.messageSquare,'Send Feedback',   'Share your thoughts',    () {}),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Logout ────────────────────────────────────────────────
                _LogoutButton(ref: ref),
                const SizedBox(height: AppSpacing.md),
                Center(child: Text('Eventra v1.0.0 · SP', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  static Widget _heroDivider() {
    return Container(width: 1, height: 30, color: Colors.white.withAlpha(40), margin: const EdgeInsets.symmetric(horizontal: 10));
  }
}

// ── HeroStat ──────────────────────────────────────────────────────────────────
class _HeroStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _HeroStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: Colors.white70),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(160))),
    ]));
  }
}

// ── Icon Button ───────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool light;
  const _IconBtn({required this.icon, required this.onTap, this.light = false});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: Container(
        width: 36, height: 36,
        decoration: BoxDecoration(
          color: light ? Colors.white.withAlpha(30) : AppColors.secondary,
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          border: Border.all(color: light ? Colors.white.withAlpha(60) : AppColors.border),
        ),
        child: Icon(icon, size: 16, color: light ? Colors.white : AppColors.mutedForeground),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────
class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        label.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 0.8),
      ),
    );
  }
}

// ── Menu Group ────────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuGroup(this.items);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final i = e.key;
          final item = e.value;
          final isLast = i == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                child: Icon(item.icon, size: 16, color: AppColors.primary),
              ),
              title: Text(item.label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.foreground)),
              subtitle: Text(item.subtitle, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              trailing: Icon(LucideIcons.chevronRight, size: 14, color: AppColors.mutedForeground),
              onTap: item.onTap,
              contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            ),
            if (!isLast) Divider(indent: 62, endIndent: 16, height: 1, color: AppColors.border),
          ]);
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuItem(this.icon, this.label, this.subtitle, this.onTap);
}

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusModal)),
          title: Text('Sign out?', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w700)),
          content: Text("You'll be redirected to the login screen.", style: TextStyle(color: AppColors.mutedForeground)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            TextButton(
              onPressed: () {
                ref.read(appProvider.notifier).logout();
                Navigator.pop(context);
                context.go('/login');
              },
              child: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(12),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.error.withAlpha(50)),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(LucideIcons.logOut, size: 16, color: AppColors.error),
          const SizedBox(width: 8),
          Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
        ]),
      ),
    );
  }
}
