import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class _Currency {
  final String code;
  final String label;
  const _Currency(this.code, this.label);
}

const _languages = ['English', 'Hindi', 'Marathi', 'Tamil', 'Telugu', 'Kannada', 'Bengali', 'Gujarati'];
const _currencies = [
  _Currency('INR', 'Indian Rupee (₹)'),
  _Currency('USD', 'US Dollar (\$)'),
  _Currency('EUR', 'Euro (€)'),
  _Currency('GBP', 'British Pound (£)'),
];

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  bool _darkMode = true;
  String _language = 'English';
  String _currency = 'INR';

  bool _notifEventReminders = true;
  bool _notifOffers = true;
  bool _notifNewEvents = false;
  bool _notifBookingUpdates = true;

  bool _saved = false;

  void _handleSave() {
    setState(() => _saved = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _saved = false);
    });
  }

  void _showLangSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Language', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 16),
            ..._languages.map((lang) {
              final active = lang == _language;
              return InkWell(
                onTap: () {
                  setState(() => _language = lang);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary.withOpacity(0.15) : null,
                    border: active ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(lang, style: TextStyle(color: active ? AppColors.primary : AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                      if (active) Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _showCurrSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: const BorderRadius.vertical(top: Radius.circular(24))),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Currency', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 16),
            ..._currencies.map((curr) {
              final active = curr.code == _currency;
              return InkWell(
                onTap: () {
                  setState(() => _currency = curr.code);
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  margin: const EdgeInsets.only(bottom: 4),
                  decoration: BoxDecoration(
                    color: active ? AppColors.primary.withOpacity(0.15) : null,
                    border: active ? Border.all(color: AppColors.primary.withOpacity(0.3)) : null,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(curr.label, style: TextStyle(color: active ? AppColors.primary : AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                      if (active) Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primary),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text('Settings', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      ],
                    ),
                  ),

                  // Appearance
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appearance', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Row(
                            children: [
                              Container(
                                width: 36, height: 36,
                                decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                                child: Icon(LucideIcons.moon, size: 16, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Dark Mode', style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                                    Text('Always-on cinematic dark theme', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Switch(
                                value: _darkMode,
                                onChanged: (v) => setState(() => _darkMode = v),
                                activeColor: Colors.white,
                                activeTrackColor: AppColors.primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: AppColors.muted,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Language & Currency
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Language & Currency', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              InkWell(
                                onTap: _showLangSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.border))),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                                        child: Icon(LucideIcons.globe, size: 16, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Language', style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                                            Text(_language, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Icon(LucideIcons.chevronRight, size: 16, color: AppColors.mutedForeground),
                                    ],
                                  ),
                                ),
                              ),
                              InkWell(
                                onTap: _showCurrSheet,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 36, height: 36,
                                        decoration: BoxDecoration(color: AppColors.muted, borderRadius: BorderRadius.circular(12)),
                                        child: Icon(LucideIcons.dollarSign, size: 16, color: AppColors.primary),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('Currency', style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                                            Text(_currencies.firstWhere((c) => c.code == _currency).label, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                                          ],
                                        ),
                                      ),
                                      Icon(LucideIcons.chevronRight, size: 16, color: AppColors.mutedForeground),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Notifications
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(LucideIcons.bell, size: 14, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Text('Notifications', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              _buildToggle('Event Reminders', 'Get reminded before your events', _notifEventReminders, (v) => setState(() => _notifEventReminders = v), true),
                              _buildToggle('Offers & Deals', 'Exclusive discounts & cashback', _notifOffers, (v) => setState(() => _notifOffers = v), true),
                              _buildToggle('New Events Nearby', 'Events in your selected cities', _notifNewEvents, (v) => setState(() => _notifNewEvents = v), true),
                              _buildToggle('Booking Updates', 'Status changes & confirmations', _notifBookingUpdates, (v) => setState(() => _notifBookingUpdates = v), false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Legal
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Legal & About', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 12),
                        Container(
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                          child: Column(
                            children: [
                              _buildLegalItem(LucideIcons.fileText, 'Terms of Service', true),
                              _buildLegalItem(LucideIcons.shield, 'Privacy Policy', true),
                              _buildLegalItem(LucideIcons.fileText, 'Refund Policy', true),
                              _buildLegalItem(LucideIcons.info, 'About Eventra', false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Save
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: InkWell(
                      onTap: _handleSave,
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: _saved ? null : LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                          color: _saved ? Colors.green.withOpacity(0.2) : null,
                          border: _saved ? Border.all(color: Colors.green.withOpacity(0.3)) : null,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Center(
                          child: Text(
                            _saved ? '✓ Settings Saved!' : 'Save Settings',
                            style: TextStyle(
                              color: _saved ? Colors.green : AppColors.primaryForeground,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Footer
                  Center(
                    child: Text('Eventra v2.4.1 · Build 241', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, String desc, bool value, Function(bool) onChanged, bool bottomBorder) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(border: bottomBorder ? Border(bottom: BorderSide(color: AppColors.border)) : null),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500)),
                Text(desc, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppColors.primary,
            inactiveThumbColor: Colors.white,
            inactiveTrackColor: AppColors.muted,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem(IconData icon, String label, bool bottomBorder) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(border: bottomBorder ? Border(bottom: BorderSide(color: AppColors.border)) : null),
        child: Row(
          children: [
            Icon(icon, size: 16, color: AppColors.mutedForeground),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: TextStyle(color: AppColors.foreground, fontSize: 14, fontWeight: FontWeight.w500))),
            Icon(LucideIcons.externalLink, size: 14, color: AppColors.mutedForeground),
          ],
        ),
      ),
    );
  }
}
