import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/ev_components.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifEvents     = true;
  bool _notifBookings   = true;
  bool _notifMessages   = false;
  bool _notifPromotions = false;
  bool _biometric       = false;
  bool _twoFactor       = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings'),
        leading: EvBackButton(onPressed: () => Navigator.of(context).pop()),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingH, AppSpacing.sm,
          AppSpacing.pagePaddingH, AppSpacing.x2l,
        ),
        children: [

          // ── Notifications ─────────────────────────────────────────────
          _SectionTitle('Notifications'),
          _SettingsTile(
            icon: LucideIcons.bell, title: 'Event Reminders',
            subtitle: 'Get notified before your events',
            trailing: Switch(value: _notifEvents, onChanged: (v) => setState(() => _notifEvents = v)),
          ),
          _SettingsTile(
            icon: LucideIcons.ticket, title: 'Booking Updates',
            subtitle: 'Confirmations, changes and cancellations',
            trailing: Switch(value: _notifBookings, onChanged: (v) => setState(() => _notifBookings = v)),
          ),
          _SettingsTile(
            icon: LucideIcons.messageCircle, title: 'Messages',
            subtitle: 'Chat from organizers and vendors',
            trailing: Switch(value: _notifMessages, onChanged: (v) => setState(() => _notifMessages = v)),
          ),
          _SettingsTile(
            icon: LucideIcons.tag, title: 'Promotions',
            subtitle: 'Deals, offers and featured events',
            trailing: Switch(value: _notifPromotions, onChanged: (v) => setState(() => _notifPromotions = v)),
            isLast: true,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),

          // ── Privacy & Security ────────────────────────────────────────
          _SectionTitle('Privacy & Security'),
          _SettingsTile(
            icon: LucideIcons.fingerprint, title: 'Biometric Login',
            subtitle: 'Use fingerprint or face to log in',
            trailing: Switch(value: _biometric, onChanged: (v) => setState(() => _biometric = v)),
          ),
          _SettingsTile(
            icon: LucideIcons.shieldCheck, title: 'Two-Factor Authentication',
            subtitle: 'Add extra security to your account',
            trailing: Switch(value: _twoFactor, onChanged: (v) => setState(() => _twoFactor = v)),
          ),
          _SettingsTile(
            icon: LucideIcons.eye, title: 'Profile Visibility',
            subtitle: 'Control who can see your profile',
            onTap: () => _showVisibilitySheet(context),
          ),
          _SettingsTile(
            icon: LucideIcons.lock, title: 'Change Password',
            onTap: () => _showSnackBar(context, 'Password change coming soon'),
            isLast: true,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),

          // ── Display ──────────────────────────────────────────────────
          _SectionTitle('Display'),
          _SettingsTile(
            icon: LucideIcons.moon, title: 'Dark Mode',
            subtitle: 'Always on (system default in V2)',
            trailing: const EvStaticBadge('On'),
          ),
          _SettingsTile(
            icon: LucideIcons.globe, title: 'Language',
            subtitle: 'English',
            onTap: () => _showSnackBar(context, 'Language selection coming soon'),
          ),
          _SettingsTile(
            icon: LucideIcons.mapPin, title: 'Default City',
            subtitle: ref.watch(appProvider).selectedCity,
            onTap: () => _showCitySheet(context),
            isLast: true,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),

          // ── Payment ───────────────────────────────────────────────────
          _SectionTitle('Payment'),
          _SettingsTile(
            icon: LucideIcons.creditCard, title: 'Payment Methods',
            onTap: () => context.push('/payment-methods'),
          ),
          _SettingsTile(
            icon: LucideIcons.receipt, title: 'Transaction History',
            onTap: () => _showSnackBar(context, 'Full history coming soon'),
            isLast: true,
          ),
          const SizedBox(height: AppSpacing.sectionSpacing),

          // ── Support ───────────────────────────────────────────────────
          _SectionTitle('Support'),
          _SettingsTile(icon: LucideIcons.helpCircle, title: 'Help & Support', onTap: () => context.push('/help')),
          _SettingsTile(icon: LucideIcons.messageSquare, title: 'Send Feedback', onTap: () => _showSnackBar(context, 'Feedback form coming soon')),
          _SettingsTile(icon: LucideIcons.fileText, title: 'Terms of Service', onTap: () => _showSnackBar(context, 'Opening terms...')),
          _SettingsTile(icon: LucideIcons.shield, title: 'Privacy Policy', onTap: () => _showSnackBar(context, 'Opening policy...'), isLast: true),
          const SizedBox(height: AppSpacing.sectionSpacing),

          // ── Account ──────────────────────────────────────────────────
          _SectionTitle('Account'),
          _SettingsTile(
            icon: LucideIcons.logOut, title: 'Sign Out',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showLogoutDialog(context),
          ),
          _SettingsTile(
            icon: LucideIcons.trash2, title: 'Delete Account',
            subtitle: 'Permanently delete all data',
            iconColor: AppColors.error,
            titleColor: AppColors.error,
            onTap: () => _showSnackBar(context, 'Contact support to delete account'),
            isLast: true,
          ),

          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text('Eventra v1.0.0', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
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
            },
            child: Text('Sign Out', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  void _showVisibilitySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusModal))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Profile Visibility', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground)),
          const SizedBox(height: AppSpacing.md),
          ...['Public', 'Contacts Only', 'Private'].map((opt) => ListTile(
            title: Text(opt, style: TextStyle(color: AppColors.foreground)),
            leading: Radio<String>(value: opt, groupValue: 'Public', onChanged: (_) => Navigator.pop(context), activeColor: AppColors.primary),
            contentPadding: EdgeInsets.zero,
          )),
          const SizedBox(height: AppSpacing.md),
        ]),
      ),
    );
  }

  void _showCitySheet(BuildContext context) {
    const cities = ['Mumbai', 'Delhi', 'Bengaluru', 'Chennai', 'Hyderabad', 'Kolkata', 'Pune', 'Ahmedabad'];
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(AppSpacing.radiusModal))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Select City', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.foreground)),
          const SizedBox(height: AppSpacing.md),
          Wrap(spacing: 8, runSpacing: 8, children: cities.map((c) => GestureDetector(
            onTap: () {
              ref.read(appProvider.notifier).setCity(c);
              Navigator.pop(context);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: ref.read(appProvider).selectedCity == c ? AppColors.primary : AppColors.secondary,
                borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                border: Border.all(color: AppColors.border),
              ),
              child: Text(c, style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: ref.read(appProvider).selectedCity == c ? Colors.white : AppColors.foreground,
              )),
            ),
          )).toList()),
          const SizedBox(height: AppSpacing.lg),
        ]),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// ── Internal helpers ──────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w700,
          color: AppColors.mutedForeground, letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool isLast;
  final Color? iconColor;
  final Color? titleColor;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.isLast = false,
    this.iconColor,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: isLast ? BorderSide(color: AppColors.border) : BorderSide.none,
          left: BorderSide(color: AppColors.border),
          right: BorderSide(color: AppColors.border),
        ),
        borderRadius: isLast
            ? const BorderRadius.vertical(bottom: Radius.circular(AppSpacing.radiusMd))
            : BorderRadius.zero,
      ),
      child: ListTile(
        leading: Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withAlpha(20),
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          ),
          child: Icon(icon, size: 16, color: iconColor ?? AppColors.primary),
        ),
        title: Text(title, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w600,
          color: titleColor ?? AppColors.foreground,
        )),
        subtitle: subtitle != null
            ? Text(subtitle!, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))
            : null,
        trailing: trailing ?? (onTap != null ? Icon(LucideIcons.chevronRight, size: 14, color: AppColors.mutedForeground) : null),
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      ),
    );
  }
}

/// Simple static badge for display-only cases
class EvStaticBadge extends StatelessWidget {
  final String label;
  const EvStaticBadge(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.success.withAlpha(26),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.success)),
    );
  }
}
