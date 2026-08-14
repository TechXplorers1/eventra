import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final mobile = appState.mobile.isNotEmpty ? appState.mobile : '+91 98765 43210';
    final bookedCount = appState.bookedTickets.length;
    final serviceCount = appState.serviceBookings.length;
    final inviteCount = appState.invitations.where((i) => i.status == 'accepted').length;

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

                // ── Header ────────────────────────────────────────────────
                Row(children: [
                  Text('Profile',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                  const Spacer(),
                  _IconBtn(icon: LucideIcons.settings2, onTap: () => context.push('/settings')),
                  const SizedBox(width: 8),
                  _IconBtn(icon: LucideIcons.bell, onTap: () => context.push('/notifications')),
                ]),
                const SizedBox(height: AppSpacing.lg),

                // ── Profile Card ──────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(AppSpacing.cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 68, height: 68,
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(LucideIcons.user, size: 30, color: Colors.white),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Eventra User',
                              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                          const SizedBox(height: 3),
                          Text(mobile,
                              style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          const SizedBox(height: 8),
                          EvBadge(label: 'Attendee', color: AppColors.primary),
                        ]),
                      ),
                      _IconBtn(icon: LucideIcons.pencil, onTap: () => _showEditProfile(context)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Stats ─────────────────────────────────────────────────
                Row(children: [
                  _StatCard(value: '$bookedCount', label: 'Tickets', color: AppColors.primary),
                  const SizedBox(width: AppSpacing.sm),
                  _StatCard(value: '$serviceCount', label: 'Services', color: AppColors.accent),
                  const SizedBox(width: AppSpacing.sm),
                  _StatCard(value: '$inviteCount', label: 'Events', color: const Color(0xFF22C55E)),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── My Activity ──────────────────────────────────────────
                _SectionLabel('My Activity'),
                _MenuGroup([
                  _MenuItem(LucideIcons.ticket, 'My Tickets', 'View booked tickets', () => context.go('/tickets')),
                  _MenuItem(LucideIcons.briefcase, 'My Services', 'Track service bookings', () => context.go('/tickets?tab=services')),
                  _MenuItem(LucideIcons.mailOpen, 'Invitations', 'Private event invitations', () => context.go('/tickets?tab=invites')),
                  _MenuItem(LucideIcons.heart, 'Saved', 'Your favorite events and vendors', () => context.push('/saved')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Account ──────────────────────────────────────────────
                _SectionLabel('Account'),
                _MenuGroup([
                  _MenuItem(LucideIcons.creditCard, 'Payment Methods', 'Cards & wallets', () => context.push('/payment-methods')),
                  _MenuItem(LucideIcons.bell, 'Notifications', 'Manage alerts', () => context.push('/notifications')),
                  _MenuItem(LucideIcons.settings2, 'Settings', 'App preferences & privacy', () => context.push('/settings')),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Support ──────────────────────────────────────────────
                _SectionLabel('Support'),
                _MenuGroup([
                  _MenuItem(LucideIcons.helpCircle, 'Help & Support', 'FAQs, chat & contact', () => context.push('/help')),
                  _MenuItem(LucideIcons.messageSquare, 'Send Feedback', 'Share your thoughts', () => _showFeedback(context)),
                ]),
                const SizedBox(height: AppSpacing.sectionSpacing),

                // ── Logout ───────────────────────────────────────────────
                _LogoutButton(ref: ref),
                const SizedBox(height: AppSpacing.md),
                Center(child: Text('Eventra v1.0.0', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  void _showEditProfile(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.pagePaddingH,
            right: AppSpacing.pagePaddingH,
            top: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter your name',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  hintText: '+91 ...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile updated successfully!')),
                    );
                  },
                  child: const Text('Save Changes', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  void _showFeedback(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: AppSpacing.pagePaddingH,
            right: AppSpacing.pagePaddingH,
            top: AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Send Feedback', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 16),
              TextField(
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Tell us how we can improve...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Thank you for your feedback!')),
                    );
                  },
                  child: const Text('Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }
}

// ── Internal components ──────────────────────────────────────────────────────

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _IconBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
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
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatCard({required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground, fontWeight: FontWeight.w500)),
        ]),
      ),
    );
  }
}

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
        children: items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          final isLast = i == items.length - 1;
          return Column(children: [
            ListTile(
              leading: Container(
                width: 34, height: 34,
                decoration: BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.circular(8),
                ),
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

class _LogoutButton extends StatelessWidget {
  final WidgetRef ref;
  const _LogoutButton({required this.ref});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.error.withAlpha(15),
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
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
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.error.withAlpha(50)),
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.logOut, size: 16, color: AppColors.error),
              const SizedBox(width: 8),
              Text('Sign Out', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.error)),
            ],
          ),
        ),
      ),
    );
  }
}
