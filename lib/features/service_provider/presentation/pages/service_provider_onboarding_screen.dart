import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/services_marketplace_data.dart';

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
  
  // Service-specific
  final _descCtrl = TextEditingController();
  final _expCtrl = TextEditingController();
  final _equipCtrl = TextEditingController();
  
  // Venue-specific
  final _capacityCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _layoutCtrl = TextEditingController();
  final _amenitiesCtrl = TextEditingController();

  UserService? _selectedCategory;
  ServiceGroup? _selectedGroup;

  final Map<String, String> _errors = {};
  bool _done = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _mobileCtrl.text = ref.read(appProvider).mobile;
    });
  }

  void _showCategoryPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.85,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.border, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 24),
            Text('Select Your Category', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: serviceGroups.length,
                itemBuilder: (context, index) {
                  final group = serviceGroups[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(group.name.toUpperCase(), style: TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                      ),
                      ...group.services.map((svc) => ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(8)),
                          child: Icon(svc.icon, color: AppColors.mutedForeground, size: 20),
                        ),
                        title: Text(svc.name, style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(svc.description, style: TextStyle(color: AppColors.mutedForeground, fontSize: 12)),
                        onTap: () {
                          setState(() {
                            _selectedCategory = svc;
                            _selectedGroup = group;
                            _errors.remove('category');
                          });
                          Navigator.pop(context);
                        },
                      )),
                      Divider(color: AppColors.border),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submit() {
    setState(() {
      _errors.clear();
      if (_fullNameCtrl.text.trim().isEmpty) _errors['fullName'] = 'Required';
      if (_busNameCtrl.text.trim().isEmpty) _errors['busName'] = 'Required';
      if (_selectedCategory == null) _errors['category'] = 'Select a category';
      if (_mobileCtrl.text.trim().isEmpty) _errors['mobile'] = 'Required';
      if (_cityCtrl.text.trim().isEmpty) _errors['city'] = 'Required';
    });

    if (_errors.isNotEmpty) return;

    final isVenue = _selectedGroup?.id == 'venue';

    final profile = ServiceProviderProfile(
      registered: true,
      status: 'verified', // Auto-approved logic from React code
      fullName: _fullNameCtrl.text.trim(),
      businessName: _busNameCtrl.text.trim(),
      serviceCategory: _selectedCategory!.name,
      city: _cityCtrl.text.trim(),
      
      // Service fields
      bio: isVenue ? '' : _descCtrl.text.trim(),
      experienceYears: int.tryParse(_expCtrl.text.trim()) ?? 0,
      equipment: isVenue ? [] : _equipCtrl.text.split(',').map((e) => e.trim()).toList(),
      
      // Venue fields
      capacity: int.tryParse(_capacityCtrl.text.trim()) ?? 0,
      address: isVenue ? _addressCtrl.text.trim() : '',
      seatingLayout: isVenue ? _layoutCtrl.text.trim() : '',
      amenities: isVenue ? _amenitiesCtrl.text.split(',').map((e) => e.trim()).toList() : [],
      venueType: isVenue ? _selectedCategory!.name : '',
    );
    
    ref.read(appProvider.notifier).registerServiceProvider(profile);
    setState(() => _done = true);
  }

  Widget _buildField(String label, IconData icon, TextEditingController ctrl, String hint, String errKey, {bool isMulti = false, TextInputType? type}) {
    final err = _errors[errKey];
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
          const SizedBox(height: 8),
          TextField(
            controller: ctrl,
            maxLines: isMulti ? 3 : 1,
            keyboardType: type,
            style: TextStyle(color: AppColors.foreground),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: AppColors.mutedForeground),
              prefixIcon: isMulti ? null : Icon(icon, color: AppColors.mutedForeground),
              filled: true,
              fillColor: AppColors.secondary,
              contentPadding: const EdgeInsets.all(16),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: err != null ? AppColors.error : AppColors.border)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: err != null ? AppColors.error : AppColors.border)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: err != null ? AppColors.error : AppColors.primary)),
            ),
          ),
          if (err != null) Padding(padding: const EdgeInsets.only(top: 4), child: Text(err, style: TextStyle(color: AppColors.error, fontSize: 12))),
        ],
      ),
    );
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
                  width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.3), blurRadius: 40, spreadRadius: 8)]),
                  child: Icon(LucideIcons.checkCircle2, size: 40, color: AppColors.primaryForeground),
                ),
                const SizedBox(height: 24),
                Text('You\'re Onboard!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                const SizedBox(height: 8),
                Text('Welcome to the Eventra Service Provider network. Start receiving booking requests right away.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: Colors.teal.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(16)),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.teal, shape: BoxShape.circle)),
                      const SizedBox(width: 6),
                      const Text('Auto-approved', style: TextStyle(color: Colors.teal, fontSize: 12, fontWeight: FontWeight.bold)),
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

    final isVenue = _selectedGroup?.id == 'venue';

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
                boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.2), blurRadius: 20, spreadRadius: 4)],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(LucideIcons.sparkles, color: AppColors.primaryForeground, size: 20),
                  const SizedBox(height: 8),
                  Text('List your service or venue', style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Reach thousands of event organizers. Just tell us what you offer and start accepting bookings.', style: TextStyle(color: AppColors.primaryForeground.withValues(alpha: 0.8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Category Selector
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('CATEGORY', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _showCategoryPicker,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.secondary,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _errors.containsKey('category') ? AppColors.error : AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Icon(_selectedCategory?.icon ?? LucideIcons.search, color: AppColors.primary),
                          const SizedBox(width: 12),
                          Expanded(child: Text(_selectedCategory?.name ?? 'Select your category', style: TextStyle(color: AppColors.foreground, fontSize: 15))),
                          Icon(LucideIcons.chevronDown, color: AppColors.mutedForeground),
                        ],
                      ),
                    ),
                  ),
                  if (_errors.containsKey('category')) Padding(padding: const EdgeInsets.only(top: 4), child: Text(_errors['category']!, style: TextStyle(color: AppColors.error, fontSize: 12))),
                ],
              ),
            ),
            
            _buildField('Full Name', LucideIcons.user, _fullNameCtrl, 'Your full name', 'fullName'),
            _buildField('Business / Brand Name', LucideIcons.briefcase, _busNameCtrl, 'e.g. Lumière Studios', 'busName'),
            
            Row(
              children: [
                Expanded(child: _buildField('Mobile Number', LucideIcons.phone, _mobileCtrl, 'Mobile', 'mobile', type: TextInputType.phone)),
                const SizedBox(width: 12),
                Expanded(child: _buildField('City', LucideIcons.mapPin, _cityCtrl, 'City', 'city')),
              ],
            ),
            
            if (_selectedCategory != null) ...[
              Divider(color: AppColors.border, height: 40),
              Text(isVenue ? 'VENUE DETAILS' : 'SERVICE DETAILS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              
              if (isVenue) ...[
                Row(
                  children: [
                    Expanded(child: _buildField('Capacity (Persons)', LucideIcons.users, _capacityCtrl, 'e.g. 500', 'cap', type: TextInputType.number)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildField('Seating Layout', LucideIcons.layoutGrid, _layoutCtrl, 'e.g. Round Table, Theatre', 'layout')),
                  ],
                ),
                _buildField('Venue Address', LucideIcons.map, _addressCtrl, 'Full venue address', 'address', isMulti: true),
                _buildField('Amenities (Comma separated)', LucideIcons.checkSquare, _amenitiesCtrl, 'e.g. Valet, AC, Catering', 'amenities'),
              ] else ...[
                _buildField('Experience (Years)', LucideIcons.award, _expCtrl, 'e.g. 5', 'exp', type: TextInputType.number),
                _buildField('Equipment (Comma separated)', LucideIcons.package2, _equipCtrl, 'e.g. Sony A7 IV, DJI Drone', 'equip'),
                _buildField('Bio / Description', LucideIcons.fileText, _descCtrl, 'Tell us about your service', 'desc', isMulti: true),
              ],
            ],

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Complete Registration', style: TextStyle(color: AppColors.primaryForeground, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
