import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

class _RoleOption {
  final Role id;
  final String title;
  final String desc;
  final IconData icon;

  const _RoleOption(this.id, this.title, this.desc, this.icon);
}

const _roles = [
  _RoleOption(Role.attendee, 'Event Attendee', 'Discover, book and attend events. Hire trusted services for your own occasions.', LucideIcons.user),
  _RoleOption(Role.organizer, 'Event Organizer', 'Create, manage and sell tickets for public events. Run private functions.', LucideIcons.megaphone),
  _RoleOption(Role.service, 'Eventra Service Provider', 'Offer photography, catering, DJ, venues and more to Eventra customers.', LucideIcons.briefcase),
];

class RoleSelectScreen extends ConsumerStatefulWidget {
  const RoleSelectScreen({super.key});

  @override
  ConsumerState<RoleSelectScreen> createState() => _RoleSelectScreenState();
}

class _RoleSelectScreenState extends ConsumerState<RoleSelectScreen> {
  Role? _selectedRole;
  bool _showConfirm = false;

  void _confirm() {
    if (_selectedRole == null) return;
    ref.read(appProvider.notifier).setRole(_selectedRole!);
    // Router will automatically redirect
  }

  @override
  Widget build(BuildContext context) {
    final mobile = ref.watch(appProvider).mobile;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.sparkles, size: 18, color: AppColors.primary),
                      const SizedBox(width: 8),
                      Text('WELCOME TO EVENTRA', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 2)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text('Who Are You?', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                  const SizedBox(height: 8),
                  Text(
                    'Choose how you want to use Eventra. Your role is permanent and cannot be switched later.',
                    style: TextStyle(fontSize: 14, color: AppColors.mutedForeground),
                  ),
                  if (mobile.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    RichText(
                      text: TextSpan(
                        text: 'Signed in as ',
                        style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                        children: [
                          TextSpan(text: mobile, style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Expanded(
                    child: ListView.separated(
                      itemCount: _roles.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final r = _roles[index];
                        return InkWell(
                          onTap: () => setState(() {
                            _selectedRole = r.id;
                            _showConfirm = true;
                          }),
                          borderRadius: BorderRadius.circular(16),
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: AppColors.border),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 10, spreadRadius: 2),
                                    ],
                                  ),
                                  child: Icon(r.icon, color: AppColors.primaryForeground, size: 22),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(r.title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      const SizedBox(height: 4),
                                      Text(r.desc, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(LucideIcons.chevronRight, size: 18, color: AppColors.mutedForeground),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Each Eventra account belongs to a single role. To use a different role, sign up with another mobile number.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 10, color: AppColors.mutedForeground),
                  ),
                ],
              ),
            ),
          ),
          if (_showConfirm && _selectedRole != null) ...[
            Container(color: Colors.black.withOpacity(0.8)),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                        child: Icon(LucideIcons.alertCircle, color: AppColors.primary, size: 22),
                      ),
                      const SizedBox(height: 16),
                      Text('Confirm Your Role', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      const SizedBox(height: 8),
                      Text("You're joining Eventra as a", style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                      const SizedBox(height: 4),
                      Text(_roles.firstWhere((r) => r.id == _selectedRole).title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary)),
                      const SizedBox(height: 16),
                      Text('This choice is permanent. You won\'t be able to switch roles from this account.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => setState(() => _showConfirm = false),
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.muted, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text('Cancel', style: TextStyle(color: AppColors.foreground)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: _confirm,
                              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 16)),
                              child: Text('Confirm', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
