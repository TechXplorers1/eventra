import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';

const _serviceCategories = [
  'Photographer', 'Videographer', 'Drone Operator', 'DJ',
  'Host / MC', 'Caterer', 'Decorator', 'Makeup Artist',
  'Security Services', 'Event Planner', 'Transportation',
  'Live Band', 'Dancers', 'Banquet Hall', 'Conference Hall', 'Convention Center',
];

class ServiceProviderOnboardingScreen extends ConsumerStatefulWidget {
  const ServiceProviderOnboardingScreen({super.key});

  @override
  ConsumerState<ServiceProviderOnboardingScreen> createState() => _ServiceProviderOnboardingScreenState();
}

class _ServiceProviderOnboardingScreenState extends ConsumerState<ServiceProviderOnboardingScreen> {
  final _fullNameCtrl = TextEditingController();
  final _busNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _stateCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _teamCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  String _category = '';
  final Map<String, String> _errors = {};
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mobileCtrl.text = ref.read(appProvider).mobile;
    });
  }

  void _submit() {
    setState(() {
      _errors.clear();
      if (_fullNameCtrl.text.trim().isEmpty) _errors['fullName'] = 'Required';
      if (_busNameCtrl.text.trim().isEmpty) _errors['busName'] = 'Required';
      if (_category.isEmpty) _errors['category'] = 'Select a category';
      if (_emailCtrl.text.trim().isEmpty) _errors['email'] = 'Required';
      if (_mobileCtrl.text.trim().isEmpty) _errors['mobile'] = 'Required';
      if (_cityCtrl.text.trim().isEmpty) _errors['city'] = 'Required';
      if (_stateCtrl.text.trim().isEmpty) _errors['state'] = 'Required';
      if (_descCtrl.text.trim().isEmpty) _errors['desc'] = 'Required';
    });

    if (_errors.isNotEmpty) return;

    final profile = ServiceProviderProfile(
      registered: true,
      status: 'verified', // Auto-approved logic from React code
      fullName: _fullNameCtrl.text.trim(),
      businessName: _busNameCtrl.text.trim(),
    );
    ref.read(appProvider.notifier).registerServiceProvider(profile);
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
                Text('You\'re Onboard!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8),
                Text('Welcome to the Eventra Service Provider network. Start receiving booking requests right away.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Auto-approved · Pending document review', style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => context.go('/service-provider'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                    child: Text('Enter Service Mode', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  ),
                ),
                TextButton(
                  onPressed: () => context.go('/home'),
                  child: Text('Skip — Go to Eventra', style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                )
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
          onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
        ),
        title: Text('Become a Service Provider', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                  Text('List your service on Eventra', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Reach thousands of event organizers and customers. Verification is automatic for early partners.', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            _buildField('Full Name', LucideIcons.user, _fullNameCtrl, 'Your full name', 'fullName'),
            _buildField('Business Name', LucideIcons.briefcase, _busNameCtrl, 'e.g. Lumière Studios', 'busName'),
            
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SERVICE CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _serviceCategories.map((c) => InkWell(
                      onTap: () => setState(() {
                        _category = c;
                        _errors.remove('category');
                      }),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: _category == c ? AppColors.primary : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: _category == c ? Colors.transparent : AppColors.border),
                        ),
                        child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: _category == c ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    )).toList(),
                  ),
                  if (_errors['category'] != null) Padding(padding: const EdgeInsets.only(top: 6), child: Text(_errors['category']!, style: TextStyle(color: AppColors.destructive, fontSize: 11))),
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
            
            _buildField('Service Description', LucideIcons.building2, _descCtrl, 'What you offer, your style, and what makes you unique', 'desc', TextInputType.multiline, 3),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField('Years Experience', LucideIcons.calendar, _expCtrl, '5', 'exp')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Team Size', LucideIcons.users, _teamCtrl, '4', 'team')),
              ],
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildField('Starting Price', LucideIcons.banknote, _priceCtrl, '15000', 'price')),
                const SizedBox(width: 12),
                Expanded(child: _buildField('Coverage Area', LucideIcons.map, _areaCtrl, 'Mumbai', 'area')),
              ],
            ),
            
            Container(
              padding: const EdgeInsets.all(12),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
              child: Text('Portfolio uploads, government ID and payout details can be added from your Service Provider dashboard after registration.', style: TextStyle(color: AppColors.mutedForeground, fontSize: 11)),
            ),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Text('Register as Service Provider', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 16),
            Text("By continuing you agree to Eventra's Service Provider Terms.", textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, String hint, String errKey, [TextInputType type = TextInputType.text, int maxLines = 1]) {
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
            maxLines: maxLines,
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
