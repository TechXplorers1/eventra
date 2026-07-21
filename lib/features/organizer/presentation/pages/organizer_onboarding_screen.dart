import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

const _organizerTypes = [
  'Individual Creator', 'Influencer', 'Community Organizer', 'Startup Community',
  'Educational Institution', 'College Club', 'Event Company', 'Corporate Organization',
  'NGO / Non-Profit',
];

class OrganizerOnboardingScreen extends ConsumerStatefulWidget {
  const OrganizerOnboardingScreen({super.key});

  @override
  ConsumerState<OrganizerOnboardingScreen> createState() => _OrganizerOnboardingScreenState();
}

class _OrganizerOnboardingScreenState extends ConsumerState<OrganizerOnboardingScreen> {
  final _fullNameCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  String _type = '';
  final Map<String, String> _errors = {};
  bool _done = false;

  void _submit() {
    setState(() {
      _errors.clear();
      if (_fullNameCtrl.text.trim().isEmpty) _errors['fullName'] = 'Required';
      if (_orgNameCtrl.text.trim().isEmpty) _errors['orgName'] = 'Required';
      if (_type.isEmpty) _errors['type'] = 'Select a type';
      if (_emailCtrl.text.trim().isEmpty) _errors['email'] = 'Required';
      if (_mobileCtrl.text.trim().isEmpty) _errors['mobile'] = 'Required';
      if (_cityCtrl.text.trim().isEmpty) _errors['city'] = 'Required';
      if (_stateCtrl.text.trim().isEmpty) _errors['state'] = 'Required';
    });

    if (_errors.isNotEmpty) return;

    final profile = OrganizerProfile(
      registered: true,
      status: 'unverified',
      fullName: _fullNameCtrl.text.trim(),
      orgName: _orgNameCtrl.text.trim(),
    );
    ref.read(appProvider.notifier).registerOrganizer(profile);
    setState(() => _done = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                    boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 40, spreadRadius: 8)],
                  ),
                  child: Icon(LucideIcons.checkCircle2, size: 40, color: AppColors.primaryForeground),
                ),
                const SizedBox(height: 24),
                Text('You\'re In!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8),
                Text('Welcome to Eventra Organizer Mode.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.amber, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Unverified Organizer', style: TextStyle(color: Colors.amber, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text('You can create events, drafts, and free RSVPs. Verify to publish paid events.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/organizer'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('Enter Organizer Dashboard', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Become an Organizer', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 20, spreadRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.sparkles, color: AppColors.primaryForeground, size: 20),
                  const SizedBox(height: 8),
                  Text('Start hosting on Eventra', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Register in minutes. Verify later to unlock paid ticketing & payouts.', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildField('Full Name', LucideIcons.user, _fullNameCtrl, 'Your full name', 'fullName'),
            _buildField('Organizer / Company Name', LucideIcons.building2, _orgNameCtrl, 'e.g. Neon Collective', 'orgName'),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ORGANIZER TYPE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _organizerTypes.map((t) => InkWell(
                      onTap: () => setState(() {
                        _type = t;
                        _errors.remove('type');
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _type == t ? AppColors.primary : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _type == t ? Colors.transparent : AppColors.border),
                        ),
                        child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _type == t ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    )).toList(),
                  ),
                  if (_errors['type'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_errors['type']!, style: TextStyle(color: AppColors.destructive, fontSize: 11))),
                ],
              ),
            ),

            _buildField('Email Address', LucideIcons.mail, _emailCtrl, 'you@email.com', 'email', TextInputType.emailAddress),
            _buildField('Mobile Number', LucideIcons.phone, _mobileCtrl, '+91 98765 43210', 'mobile', TextInputType.phone),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField('City', LucideIcons.mapPin, _cityCtrl, 'Mumbai', 'city')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('State', LucideIcons.mapPin, _stateCtrl, 'MH', 'state')),
              ],
            ),
            
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text('Register as Organizer', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text("By continuing you agree to Eventra's Organizer Terms.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, String hint, String errKey, [TextInputType type = TextInputType.text]) {
    final error = _errors[errKey];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppColors.mutedForeground),
              const SizedBox(width: 6),
              Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            keyboardType: type,
            style: TextStyle(color: AppColors.foreground, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: error != null ? AppColors.destructive : AppColors.primary)),
            ),
            onChanged: (_) => setState(() => _errors.remove(errKey)),
          ),
          if (error != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(error, style: TextStyle(color: AppColors.destructive, fontSize: 11))),
        ],
      ),
    );
  }
}
