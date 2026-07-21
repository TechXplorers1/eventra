import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/app_provider.dart';

class OrganizerServiceProvidersScreen extends ConsumerWidget {
  final String categoryId;

  const OrganizerServiceProvidersScreen({
    super.key,
    required this.categoryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentProfile = ref.watch(appProvider).serviceProvider;
    final category = allUserServices.firstWhere((c) => c.id == categoryId, orElse: () => allUserServices[0]);
    final providers = getVendorsForService(categoryId, category.startingPrice, currentProfile);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(category.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('${providers.length} vendors available', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: providers.length,
                itemBuilder: (context, index) {
                  final vendor = providers[index];
                  final isAvailable = vendor.availability == 'Available';
                  final isLimited = vendor.availability == 'Limited';

                  return Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 48, height: 48,
                              decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                              child: Center(child: Text(vendor.name.split(' ').take(2).map((w) => w[0]).join(''), style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primaryForeground))),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(vendor.name, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.star, size: 11, color: AppColors.primary),
                                      const SizedBox(width: 2),
                                      Text('${vendor.rating}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                      const SizedBox(width: 8),
                                      Text('${vendor.reviews} reviews', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                      const SizedBox(width: 8),
                                      Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground),
                                      const SizedBox(width: 2),
                                      Text(vendor.city, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green.withOpacity(0.15) : isLimited ? Colors.orange.withOpacity(0.15) : Colors.red.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(vendor.availability, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: isAvailable ? Colors.greenAccent : isLimited ? Colors.orangeAccent : Colors.redAccent)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(height: 1, color: AppColors.border),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Starting from', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                Text('₹${vendor.startingPrice}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            Row(
                              children: [
                                ElevatedButton(
                                  onPressed: () => context.push('/organizer/services/vendor/$categoryId/${vendor.id}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.secondary,
                                    foregroundColor: AppColors.foreground,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () => context.push('/organizer/services/vendor/$categoryId/${vendor.id}'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.primaryForeground,
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                  child: const Text('Hire', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }
}
