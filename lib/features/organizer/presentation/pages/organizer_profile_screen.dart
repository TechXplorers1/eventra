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

class OrganizerProfileScreen extends ConsumerWidget {
  const OrganizerProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final org = appState.organizer;
    final myEvents = appState.publishedEvents;
    final serviceRequests = appState.serviceRequests;
    final walletBalance = appState.organizerWalletBalance;
    final isVerified = org.status == 'verified';

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
                  _IBtn(icon: LucideIcons.settings2, onTap: () => context.push('/settings')),
                  const SizedBox(width: 8),
                  _IBtn(icon: LucideIcons.bell, onTap: () => context.push('/notifications')),
                ]),
                const SizedBox(height: AppSpacing.lg),

                // ── Gradient Hero Card ────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                  ),
                  child: Column(children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(30),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withAlpha(80), width: 2),
                        ),
                        child: const Icon(LucideIcons.building2, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(
                          org.orgName.isNotEmpty ? org.orgName : 'My Organization',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          org.fullName.isNotEmpty ? org.fullName : 'Organizer',
                          style: TextStyle(fontSize: 13, color: Colors.white.withAlpha(180)),
                        ),
                        const SizedBox(height: 6),
                        Row(children: [
                          if (org.city.isNotEmpty)
                            Row(children: [
                              Icon(LucideIcons.mapPin, size: 10, color: Colors.white.withAlpha(180)),
                              const SizedBox(width: 3),
                              Text(org.city, style: TextStyle(fontSize: 11, color: Colors.white.withAlpha(180))),
                              const SizedBox(width: 8),
                            ]),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: isVerified
                                  ? AppColors.success.withAlpha(60)
                                  : Colors.white.withAlpha(30),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(isVerified ? LucideIcons.badgeCheck : LucideIcons.clock3,
                                  size: 10, color: Colors.white),
                              const SizedBox(width: 3),
                              Text(
                                isVerified ? 'Verified' : org.status == 'pending' ? 'Pending' : 'Unverified',
                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: Colors.white),
                              ),
                            ]),
                          ),
                        ]),
                      ])),
                    ]),
                    const SizedBox(height: AppSpacing.md),
                    // Stat Row
                    Row(children: [
                      _HStat(value: '${myEvents.length}', label: 'Events', icon: LucideIcons.calendarDays),
                      _divider(),
                      _HStat(value: org.rating, label: 'Rating', icon: LucideIcons.star),
                      _divider(),
                      _HStat(value: '₹${(walletBalance / 1000).toStringAsFixed(0)}K', label: 'Revenue', icon: LucideIcons.wallet),
                      _divider(),
                      _HStat(value: '${serviceRequests.length}', label: 'Vendors', icon: LucideIcons.users),
                    ]),
                  ]),
                ),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Event Management ──────────────────────────────────────
                _SectionLabel('Event Management'),
                _MenuGroup([
                  _MenuTile(LucideIcons.calendarDays, 'My Events',      'View and manage all your events',     () => context.push('/organizer/events')),
                  _MenuTile(LucideIcons.calendarPlus, 'Create Event',   'Start planning a new event',          () => context.push('/organizer/create')),
                  _MenuTile(LucideIcons.scanLine,     'Check-in / Scan','Scan attendee QR codes',              () => context.push('/organizer/scan')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Finances ─────────────────────────────────────────────
                _SectionLabel('Finances'),
                _MenuGroup([
                  _MenuTile(LucideIcons.wallet,       'Wallet',         'Balance and withdrawals',             () => context.push('/organizer/wallet')),
                  _MenuTile(LucideIcons.creditCard,   'Payment Methods','Cards and bank accounts',             () => context.push('/payment-methods')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Services ─────────────────────────────────────────────
                _SectionLabel('Services'),
                _MenuGroup([
                  _MenuTile(LucideIcons.briefcase,    'Service Requests','Vendors hired for your events',      () => context.push('/organizer/services')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Account ──────────────────────────────────────────────
                _SectionLabel('Account'),
                _MenuGroup([
                  _MenuTile(LucideIcons.shieldCheck,  'Verification',   'Business documents & KYC',            () => context.push('/organizer/verification')),
                  _MenuTile(LucideIcons.settings2,    'Settings',       'Notifications, privacy, display',     () => context.push('/settings')),
                  _MenuTile(LucideIcons.helpCircle,   'Help & Support', 'FAQs and contact',                    () => context.push('/help')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Logout ────────────────────────────────────────────────
                _LogoutBtn(ref: ref),
                const SizedBox(height: AppSpacing.md),
                Center(child: Text('Eventra v1.0.0 · Organizer', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  static Widget _divider() =>
      Container(width: 1, height: 28, color: Colors.white.withAlpha(40), margin: const EdgeInsets.symmetric(horizontal: 8));
}

// ── Stat Tile ─────────────────────────────────────────────────────────────────
class _HStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const _HStat({required this.value, required this.label, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 11, color: Colors.white70),
        const SizedBox(width: 3),
        Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white)),
      ]),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withAlpha(160))),
    ]));
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
      child: Text(label.toUpperCase(), style: TextStyle(
        fontSize: 11, fontWeight: FontWeight.w700,
        color: AppColors.mutedForeground, letterSpacing: 0.8,
      )),
    );
  }
}

// ── Menu Group ────────────────────────────────────────────────────────────────
class _MenuGroup extends StatelessWidget {
  final List<_MenuTile> items;
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

class _MenuTile {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;
  const _MenuTile(this.icon, this.label, this.subtitle, this.onTap);
}

// ── Icon Button ───────────────────────────────────────────────────────────────
class _IBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 16, color: AppColors.mutedForeground),
    ),
  );
}

// ── Logout Button ─────────────────────────────────────────────────────────────
class _LogoutBtn extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutBtn({required this.ref});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusModal)),
          title: Text('Sign out?', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w700)),
          content: Text('You will be redirected to the login screen.', style: TextStyle(color: AppColors.mutedForeground)),
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
