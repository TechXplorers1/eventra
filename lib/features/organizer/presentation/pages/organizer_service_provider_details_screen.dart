import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/services_marketplace_data.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_provider.dart';

class OrganizerServiceProviderDetailsScreen extends ConsumerStatefulWidget {
  final String categoryId;
  final String providerId;

  const OrganizerServiceProviderDetailsScreen({
    super.key,
    required this.categoryId,
    required this.providerId,
  });

  @override
  ConsumerState<OrganizerServiceProviderDetailsScreen> createState() => _OrganizerServiceProviderDetailsScreenState();
}

class _OrganizerServiceProviderDetailsScreenState extends ConsumerState<OrganizerServiceProviderDetailsScreen> {
  int _selectedPkg = 0;

  void _handleSelect(Vendor vendor, UserService category) {
    // Select current package (stored in state)
    final _ = vendor.packages[_selectedPkg]; // package is passed to ServiceRequest on next screen
    context.go('/organizer/create');
  }

  @override
  Widget build(BuildContext context) {
    final currentProfile = ref.watch(appProvider).serviceProvider;
    final category = allUserServices.firstWhere((c) => c.id == widget.categoryId, orElse: () => allUserServices.first);
    final vendor = getVendor(widget.categoryId, widget.providerId, category.startingPrice, currentProfile);

    if (vendor == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Provider not found', style: TextStyle(color: AppColors.foreground, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: Text('Go back', style: TextStyle(color: AppColors.primary, fontSize: 14)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: AppColors.background.withOpacity(0.85),
                  elevation: 0,
                  automaticallyImplyLeading: false,
                  titleSpacing: 0,
                  title: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () => context.pop(),
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                            child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(child: Text(vendor.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground), maxLines: 1, overflow: TextOverflow.ellipsis)),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Hero
                        Container(
                          margin: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))],
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(16)),
                                child: Center(child: Text(vendor.name.characters.first, style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.w900, fontSize: 24))),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(child: Text(vendor.name, style: TextStyle(color: AppColors.primaryForeground, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                        if (vendor.verified) ...[
                                          const SizedBox(width: 6),
                                          Icon(LucideIcons.badgeCheck, size: 14, color: AppColors.primaryForeground),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 2),
                                    Text(vendor.specialization, style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.8), fontSize: 12)),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(LucideIcons.star, size: 11, color: AppColors.primaryForeground),
                                        const SizedBox(width: 4),
                                        Text('${vendor.rating} (${vendor.reviews})', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.9), fontSize: 11)),
                                        const SizedBox(width: 12),
                                        Icon(LucideIcons.briefcase, size: 11, color: AppColors.primaryForeground),
                                        const SizedBox(width: 4),
                                        Text('${vendor.experienceYears} yrs', style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.9), fontSize: 11)),
                                        const SizedBox(width: 12),
                                        Icon(LucideIcons.mapPin, size: 11, color: AppColors.primaryForeground),
                                        const SizedBox(width: 4),
                                        Expanded(child: Text(vendor.city, style: TextStyle(color: AppColors.primaryForeground.withOpacity(0.9), fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Sections
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Column(
                            children: [
                              _Section(
                                title: 'About',
                                child: Text(vendor.bio, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5)),
                              ),
                              const SizedBox(height: 16),
                              _Section(
                                title: 'Portfolio',
                                child: GridView.builder(
                                  padding: EdgeInsets.zero,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 3, crossAxisSpacing: 8, mainAxisSpacing: 8,
                                  ),
                                  itemCount: vendor.portfolio.length,
                                  itemBuilder: (context, index) => Container(
                                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                                    child: Center(child: Icon(LucideIcons.camera, size: 20, color: AppColors.mutedForeground)),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _Section(
                                title: 'Equipment',
                                child: Wrap(
                                  spacing: 8, runSpacing: 8,
                                  children: vendor.equipment.map((e) => Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                                    child: Text(e, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _Section(
                                title: 'Services Included',
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: vendor.servicesOffered.map((s) => Padding(
                                    padding: const EdgeInsets.only(bottom: 6),
                                    child: Row(
                                      children: [
                                        Icon(LucideIcons.check, size: 13, color: AppColors.primary),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text(s, style: TextStyle(fontSize: 12, color: AppColors.foreground))),
                                      ],
                                    ),
                                  )).toList(),
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...vendor.details.map((group) => Padding(
                                padding: const EdgeInsets.only(bottom: 16),
                                child: _Section(
                                  title: group.label,
                                  child: Wrap(
                                    spacing: 8, runSpacing: 8,
                                    children: group.items.map((i) => Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(8)),
                                      child: Text(i, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    )).toList(),
                                  ),
                                ),
                              )),
                              _Section(
                                title: 'Packages & Pricing',
                                child: Column(
                                  children: List.generate(vendor.packages.length, (i) {
                                    final pkg = vendor.packages[i];
                                    final isSelected = _selectedPkg == i;
                                    return Padding(
                                      padding: const EdgeInsets.only(bottom: 8),
                                      child: InkWell(
                                        onTap: () => setState(() => _selectedPkg = i),
                                        borderRadius: BorderRadius.circular(16),
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: isSelected ? AppColors.primary.withOpacity(0.1) : AppColors.secondary,
                                            border: Border.all(color: isSelected ? AppColors.primary : AppColors.border),
                                            borderRadius: BorderRadius.circular(16),
                                            boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.2), blurRadius: 10)] : null,
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(LucideIcons.package, size: 14, color: AppColors.primary),
                                                      const SizedBox(width: 8),
                                                      Text(pkg.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                                    ],
                                                  ),
                                                  Text('₹${pkg.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              ...pkg.features.map((f) => Padding(
                                                padding: const EdgeInsets.only(bottom: 4),
                                                child: Row(
                                                  children: [
                                                    Icon(LucideIcons.check, size: 10, color: AppColors.primary),
                                                    const SizedBox(width: 6),
                                                    Expanded(child: Text(f, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                                                  ],
                                                ),
                                              )),
                                            ],
                                          ),
                                        ),
                                      ),
                                    );
                                  }),
                                ),
                              ),
                              const SizedBox(height: 16),
                              _Section(
                                title: 'Reviews',
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(color: AppColors.secondary, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(LucideIcons.star, size: 16, color: Colors.yellow),
                                          const SizedBox(width: 8),
                                          Text('${vendor.rating}', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                          const SizedBox(width: 8),
                                          Text('(${vendor.reviews} reviews)', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Trusted by ${vendor.reviews}+ organizers across ${vendor.city}. Consistent ratings for professionalism and on-time delivery.',
                                        style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                                      ),
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
                ),
              ],
            ),
          ),
          
          // Sticky Bottom CTA
          Positioned(
            left: 0, right: 0, bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(16, 12, 16, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.9),
                border: Border(top: BorderSide(color: AppColors.border.withOpacity(0.4))),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SELECTED PACKAGE', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 2),
                  Text('${vendor.packages[_selectedPkg].name} · ₹${vendor.packages[_selectedPkg].price}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _handleSelect(vendor, category),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: AppColors.primary.withOpacity(0.4),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.check, size: 16),
                          const SizedBox(width: 8),
                          Text('Select Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;

  const _Section({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title.toUpperCase(), style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground, letterSpacing: 1)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
