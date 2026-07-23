import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class OrganizerVendorProfileScreen extends ConsumerWidget {
  final String vendorId;

  const OrganizerVendorProfileScreen({
    super.key,
    required this.vendorId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // vendorId is like 'photographer-1'. Extract categoryId.
    final categoryId = vendorId.split('-').first;
    final category = allUserServices.firstWhere((c) => c.id == categoryId, orElse: () => allUserServices[0]);
    final vendor = getVendor(categoryId, vendorId, category.startingPrice);

    if (vendor == null) {
      return const Scaffold(body: Center(child: Text('Vendor not found')));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                          width: 40, height: 40,
                          decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text('Vendor Profile', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    ],
                  ),
                ),

                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 64, height: 64,
                                  decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(16)),
                                  child: Center(child: Text(vendor.name.split(' ').take(2).map((w) => w[0]).join(''), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForeground))),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(vendor.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      Text(category.name, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.star, size: 12, color: AppColors.primary),
                                          const SizedBox(width: 4),
                                          Text('${vendor.rating}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          const SizedBox(width: 12),
                                          Text('${vendor.reviews} reviews', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          const SizedBox(width: 12),
                                          Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text(vendor.city, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(vendor.bio, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      _buildSection('Pricing Packages', [
                        ...vendor.packages.map((p) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(p.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text('₹${p.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                ],
                              ),
                              const SizedBox(height: 8),
                              ...p.features.map((i) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  children: [
                                    Icon(LucideIcons.check, size: 12, color: AppColors.primary),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(i, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                                  ],
                                ),
                              )),
                            ],
                          ),
                        )),
                      ]),
                      const SizedBox(height: 16),

                      _buildSection('Portfolio', [
                        GridView.count(
                          crossAxisCount: 3,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          children: vendor.portfolio.map((p) => Container(
                            decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.border)),
                            child: Center(child: Text(p, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground), textAlign: TextAlign.center)),
                          )).toList(),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      _buildSection('Ratings & Reviews', [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Row(
                            children: [
                              Text('${vendor.rating}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: List.generate(5, (index) => Icon(LucideIcons.star, size: 12, color: index < vendor.rating.round() ? AppColors.primary : AppColors.muted)),
                                  ),
                                  const SizedBox(height: 4),
                                  Text('${vendor.reviews} verified reviews', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                      const SizedBox(height: 16),

                      _buildSection('Contact', [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Icon(LucideIcons.phone, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text('+91 98765 43210', style: TextStyle(fontSize: 12, color: AppColors.foreground)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Icon(LucideIcons.mail, size: 12, color: AppColors.primary),
                                  const SizedBox(width: 8),
                                  Text('contact@${vendor.name.toLowerCase().replaceAll(" ", "")}.com', style: TextStyle(fontSize: 12, color: AppColors.foreground)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ]),
                    ],
                  ),
                ),
              ],
            ),

            Positioned(
              left: 16, right: 16, bottom: 90,
              child: ElevatedButton(
                onPressed: () {
                  ref.read(appProvider.notifier).addServiceRequest(
                    ServiceRequest(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      categoryId: categoryId,
                      categoryName: category.name,
                      status: 'Confirmed',
                      budget: vendor.startingPrice.toDouble(),
                      professionals: 1,
                      duration: '4 hours',
                      notes: 'Direct hire — ${vendor.name}',
                      quotes: 1,
                      createdAt: DateTime.now(),
                      vendorId: vendor.id,
                      vendorName: vendor.name,
                      vendorPrice: vendor.startingPrice.toDouble(),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${vendor.name} hired successfully', style: TextStyle(color: AppColors.primaryForeground)), backgroundColor: AppColors.primary, behavior: SnackBarBehavior.floating));
                  context.push('/organizer/services/requests');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.primaryForeground,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Hire Vendor — ₹${vendor.startingPrice}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}
