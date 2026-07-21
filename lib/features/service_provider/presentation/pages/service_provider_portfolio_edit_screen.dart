import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';

class ServiceProviderPortfolioEditScreen extends ConsumerStatefulWidget {
  const ServiceProviderPortfolioEditScreen({super.key});

  @override
  ConsumerState<ServiceProviderPortfolioEditScreen> createState() => _ServiceProviderPortfolioEditScreenState();
}

class _ServiceProviderPortfolioEditScreenState extends ConsumerState<ServiceProviderPortfolioEditScreen> {
  final _formKey = GlobalKey<FormState>();

  // ── Common ────────────────────────────────────────────────────────────────
  late TextEditingController _bioController;
  late TextEditingController _cityController;
  late TextEditingController _experienceController;
  late TextEditingController _priceController;
  late String _availability;

  // ── Photography / DJ / Sound ──────────────────────────────────────────────
  late TextEditingController _equipmentController;
  late TextEditingController _servicesController;

  // ── Venue ─────────────────────────────────────────────────────────────────
  late TextEditingController _capacityController;
  late TextEditingController _addressController;
  late TextEditingController _amenitiesController;

  // ── Catering ──────────────────────────────────────────────────────────────
  late TextEditingController _menuTypesController;
  late TextEditingController _maxGuestsController;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(appProvider).serviceProvider;
    _bioController = TextEditingController(text: profile.bio);
    _cityController = TextEditingController(text: profile.city);
    _experienceController = TextEditingController(text: profile.experienceYears == 0 ? '' : profile.experienceYears.toString());
    _priceController = TextEditingController(text: profile.startingPrice == 0 ? '' : profile.startingPrice.toString());
    _availability = profile.availability.isNotEmpty ? profile.availability : 'Available';

    _equipmentController = TextEditingController(text: profile.equipment.join(', '));
    _servicesController = TextEditingController(text: profile.servicesOffered.join(', '));

    _capacityController = TextEditingController(text: profile.capacity == 0 ? '' : profile.capacity.toString());
    _addressController = TextEditingController(text: profile.address);
    _amenitiesController = TextEditingController(text: profile.amenities.join(', '));

    _menuTypesController = TextEditingController(text: profile.menuTypes.join(', '));
    _maxGuestsController = TextEditingController(text: profile.maxGuests == 0 ? '' : profile.maxGuests.toString());
  }

  @override
  void dispose() {
    _bioController.dispose();
    _cityController.dispose();
    _experienceController.dispose();
    _priceController.dispose();
    _equipmentController.dispose();
    _servicesController.dispose();
    _capacityController.dispose();
    _addressController.dispose();
    _amenitiesController.dispose();
    _menuTypesController.dispose();
    _maxGuestsController.dispose();
    super.dispose();
  }

  void _savePortfolio() {
    if (_formKey.currentState!.validate()) {
      final current = ref.read(appProvider).serviceProvider;
      final isVenue = current.serviceCategory.toLowerCase() == 'venue';
      final isCaterer = current.serviceCategory.toLowerCase() == 'catering' || current.serviceCategory.toLowerCase() == 'caterer';

      final updated = current.copyWith(
        bio: _bioController.text.trim(),
        city: _cityController.text.trim(),
        experienceYears: int.tryParse(_experienceController.text) ?? 0,
        startingPrice: int.tryParse(_priceController.text) ?? 0,
        availability: _availability,
        // Shared
        equipment: _equipmentController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        servicesOffered: _servicesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList(),
        // Venue
        capacity: isVenue ? (int.tryParse(_capacityController.text) ?? 0) : current.capacity,
        address: isVenue ? _addressController.text.trim() : current.address,
        amenities: isVenue ? _amenitiesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : current.amenities,
        // Catering
        menuTypes: isCaterer ? _menuTypesController.text.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList() : current.menuTypes,
        maxGuests: isCaterer ? (int.tryParse(_maxGuestsController.text) ?? 0) : current.maxGuests,
      );

      ref.read(appProvider.notifier).updateServiceProviderProfile(updated);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Portfolio updated successfully!'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );

      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(appProvider).serviceProvider;
    final category = profile.serviceCategory.toLowerCase();
    final isVenue = category == 'venue';
    final isCaterer = category == 'catering' || category == 'caterer';
    final isPhotographer = category == 'photography' || category == 'photographer';
    final isDJ = category == 'dj' || category == 'sound' || category == 'sound & lighting';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            width: 36, height: 36,
            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
            child: Icon(LucideIcons.arrowLeft, size: 18, color: AppColors.foreground),
          ),
          onPressed: () => context.pop(),
        ),
        title: Text('Edit Portfolio', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: Text(profile.serviceCategory.isNotEmpty ? profile.serviceCategory : 'General', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Section: Basic Info ──────────────────────────────────────
              _buildSectionHeader(LucideIcons.user, 'Basic Info'),
              const SizedBox(height: 16),
              _buildTextField(controller: _bioController, label: 'Bio / Description', hint: 'Tell organizers about your work...', maxLines: 4),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(child: _buildTextField(controller: _cityController, label: 'City', hint: 'e.g. Mumbai')),
                const SizedBox(width: 16),
                if (!isVenue)
                  Expanded(child: _buildTextField(controller: _experienceController, label: 'Experience (Yrs)', hint: 'e.g. 5', keyboardType: TextInputType.number)),
              ]),
              const SizedBox(height: 16),
              _buildTextField(controller: _priceController, label: isVenue ? 'Price Per Day (₹)' : 'Starting Price (₹)', hint: 'e.g. 15000', keyboardType: TextInputType.number),

              // ── Section: Venue-Specific ──────────────────────────────────
              if (isVenue) ...[
                const SizedBox(height: 32),
                _buildSectionHeader(LucideIcons.building2, 'Venue Details'),
                const SizedBox(height: 16),
                _buildTextField(controller: _addressController, label: 'Full Address', hint: 'e.g. 14, Andheri Link Road, Andheri West'),
                const SizedBox(height: 16),
                _buildTextField(controller: _capacityController, label: 'Max Capacity (persons)', hint: 'e.g. 500', keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                _buildTextField(controller: _amenitiesController, label: 'Amenities (Comma separated)', hint: 'e.g. AC Hall, Stage, Parking, Catering Kitchen', maxLines: 2),
              ],

              // ── Section: Photography/DJ specific ────────────────────────
              if (isPhotographer || isDJ || (!isVenue && !isCaterer)) ...[
                const SizedBox(height: 32),
                _buildSectionHeader(isPhotographer ? LucideIcons.camera : LucideIcons.music2, isPhotographer ? 'Photography Details' : isDJ ? 'DJ & Sound Details' : 'Services & Equipment'),
                const SizedBox(height: 16),
                _buildTextField(controller: _servicesController, label: 'Services Offered (Comma separated)', hint: isPhotographer ? 'e.g. Wedding Photography, Drone Shots, Portraits' : 'e.g. Full Concert Sound, DJ Set, LED Stage', maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField(controller: _equipmentController, label: 'Equipment (Comma separated)', hint: isPhotographer ? 'e.g. Sony A7 IV, DJI Drone, 2x Strobes' : 'e.g. Pioneer CDJ-3000, QSC K12 Speakers', maxLines: 2),
              ],

              // ── Section: Catering-Specific ───────────────────────────────
              if (isCaterer) ...[
                const SizedBox(height: 32),
                _buildSectionHeader(LucideIcons.utensils, 'Catering Details'),
                const SizedBox(height: 16),
                _buildTextField(controller: _servicesController, label: 'Services Offered (Comma separated)', hint: 'e.g. Buffet, Plated Dinner, Live Counters', maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField(controller: _menuTypesController, label: 'Menu Types (Comma separated)', hint: 'e.g. Veg, Non-Veg, Jain, Continental, North Indian', maxLines: 2),
                const SizedBox(height: 16),
                _buildTextField(controller: _maxGuestsController, label: 'Max Guests Served', hint: 'e.g. 1000', keyboardType: TextInputType.number),
              ],

              // ── Section: Availability ─────────────────────────────────────
              const SizedBox(height: 32),
              _buildSectionHeader(LucideIcons.clock, 'Availability Status'),
              const SizedBox(height: 16),
              _buildAvailabilityPicker(),

              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _savePortfolio,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.primaryForeground,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 0,
                  ),
                  child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(IconData icon, String title) {
    return Row(children: [
      Icon(icon, size: 16, color: AppColors.primary),
      const SizedBox(width: 8),
      Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
    ]);
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    bool required = true,
  }) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
      const SizedBox(height: 8),
      TextFormField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
        style: TextStyle(color: AppColors.foreground, fontSize: 14),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.border)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppColors.primary)),
        ),
        validator: required
            ? (value) => (value == null || value.trim().isEmpty) ? 'Required' : null
            : null,
      ),
    ]);
  }

  Widget _buildAvailabilityPicker() {
    final options = [
      {'label': 'Available', 'color': Colors.green, 'icon': LucideIcons.checkCircle2},
      {'label': 'Busy', 'color': Colors.orange, 'icon': LucideIcons.clock},
      {'label': 'On Leave', 'color': Colors.red, 'icon': LucideIcons.xCircle},
    ];
    return Row(children: options.map((opt) {
      final isSelected = _availability == opt['label'] as String;
      final color = opt['color'] as Color;
      return Expanded(
        child: GestureDetector(
          onTap: () => setState(() => _availability = opt['label'] as String),
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? color.withOpacity(0.12) : AppColors.card,
              border: Border.all(color: isSelected ? color : AppColors.border, width: isSelected ? 1.5 : 1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(children: [
              Icon(opt['icon'] as IconData, size: 18, color: isSelected ? color : AppColors.mutedForeground),
              const SizedBox(height: 4),
              Text(opt['label'] as String, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? color : AppColors.mutedForeground)),
            ]),
          ),
        ),
      );
    }).toList());
  }
}
