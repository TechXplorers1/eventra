import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class VendorProfileScreen extends ConsumerWidget {
  final String serviceId;
  final String vendorId;
  const VendorProfileScreen({super.key, required this.serviceId, required this.vendorId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = findUserService(serviceId);
    final currentProfile = ref.watch(appProvider).serviceProvider;
    final vendor = service != null ? getVendor(service.id, vendorId, service.startingPrice, currentProfile) : null;

    if (service == null || vendor == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Vendor not found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                child: Text('Go back', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      );
    }

    final savedKey = '${service.id}:${vendor.id}';
    final saved = ref.watch(appProvider).savedVendors.contains(savedKey);

    Color availColor;
    Color availBg;
    if (vendor.availability == 'Available') {
      availColor = Colors.teal;
      availBg = Colors.teal.withOpacity(0.15);
    } else if (vendor.availability == 'Busy') {
      availColor = Colors.orange;
      availBg = Colors.orange.withOpacity(0.15);
    } else {
      availColor = Colors.red;
      availBg = Colors.red.withOpacity(0.15);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 160),
            children: [
              // Hero
              Container(
                height: 208,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]),
                ),
                child: SafeArea(
                  child: Stack(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.black12, Colors.transparent, AppColors.background],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      Positioned(
                        top: 16, left: 16, right: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                              child: Container(
                                width: 40, height: 40,
                                decoration: BoxDecoration(color: AppColors.background.withOpacity(0.4), shape: BoxShape.circle),
                                child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                              ),
                            ),
                            Row(
                              children: [
                                InkWell(
                                  onTap: () => ref.read(appProvider.notifier).toggleSaveVendor(savedKey),
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: AppColors.background.withOpacity(0.4), shape: BoxShape.circle),
                                    child: Icon(LucideIcons.bookmark, size: 18, color: saved ? AppColors.primary : AppColors.foreground),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Link copied to clipboard')));
                                  },
                                  child: Container(
                                    width: 40, height: 40,
                                    decoration: BoxDecoration(color: AppColors.background.withOpacity(0.4), shape: BoxShape.circle),
                                    child: Icon(LucideIcons.share2, size: 18, color: AppColors.foreground),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Card
              Transform.translate(
                offset: const Offset(0, -80),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 10)],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), 
                                borderRadius: BorderRadius.circular(16),
                                image: vendor.portfolio.isNotEmpty 
                                    ? DecorationImage(image: NetworkImage(vendor.portfolio.first), fit: BoxFit.cover)
                                    : null,
                              ),
                              alignment: Alignment.center,
                              child: vendor.portfolio.isEmpty 
                                  ? Text(vendor.name.split(' ').take(2).map((w) => w.isNotEmpty ? w[0] : '').join(), style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.primaryForeground))
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(child: Text(vendor.name, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                                      if (vendor.verified) Icon(LucideIcons.shieldCheck, size: 14, color: AppColors.primary),
                                    ],
                                  ),
                                  Text(service.name.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary, letterSpacing: 1)),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Icon(LucideIcons.star, size: 11, color: Colors.amber),
                                      const SizedBox(width: 4),
                                      Text('${vendor.rating} (${vendor.reviews})', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                      const SizedBox(width: 12),
                                      Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
                                      const SizedBox(width: 4),
                                      Text(vendor.city, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                      const SizedBox(width: 12),
                                      Icon(LucideIcons.briefcase, size: 11, color: AppColors.mutedForeground),
                                      const SizedBox(width: 4),
                                      Text('${vendor.experienceYears}y exp', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: availBg, borderRadius: BorderRadius.circular(16)),
                              child: Text(vendor.availability, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: availColor)),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                              child: Text(vendor.specialization, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(vendor.bio, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, height: 1.5)),
                        if (vendor.socialLinks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Row(
                            children: vendor.socialLinks.entries.map((entry) {
                              IconData iconData;
                              switch (entry.key) {
                                case 'instagram': iconData = LucideIcons.instagram; break;
                                case 'facebook': iconData = LucideIcons.facebook; break;
                                case 'twitter': iconData = LucideIcons.twitter; break;
                                case 'website': iconData = LucideIcons.globe; break;
                                default: iconData = LucideIcons.link;
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: InkWell(
                                  onTap: () {
                                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Opening ${entry.key[0].toUpperCase() + entry.key.substring(1)}...')));
                                  }, // Action to open link
                                  child: Row(
                                    children: [
                                      Icon(iconData, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 4),
                                      Text(entry.key[0].toUpperCase() + entry.key.substring(1), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -64),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Starting from', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                            Text('₹${vendor.startingPrice}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          ],
                        ),
                        Container(
                          width: 48, height: 48,
                          decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
                          child: Icon(service.icon, size: 22, color: AppColors.primary),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              Transform.translate(
                offset: const Offset(0, -48),
                child: Column(
                  children: [
                    ...vendor.details.map((group) => _buildSection(group.label, Wrap(
                      spacing: 8, runSpacing: 8,
                      children: group.items.map((it) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                        child: Text(it, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      )).toList(),
                    ))),
                    _buildSection('Equipment', Wrap(
                      spacing: 8, runSpacing: 8,
                      children: vendor.equipment.map((e) => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                        child: Text(e, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                      )).toList(),
                    )),
                    _buildSection('Services Offered', Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                      child: Column(
                        children: vendor.servicesOffered.map((s) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 20, height: 20,
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), shape: BoxShape.circle),
                                child: Icon(LucideIcons.check, size: 12, color: AppColors.primary),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Text(s, style: TextStyle(fontSize: 14, color: AppColors.foreground))),
                            ],
                          ),
                        )).toList(),
                      ),
                    )),
                    _buildSection('Portfolio', GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8, crossAxisSpacing: 8,
                      children: vendor.portfolio.asMap().entries.map((e) => Container(
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          border: Border.all(color: AppColors.border),
                          borderRadius: BorderRadius.circular(12),
                          image: DecorationImage(image: NetworkImage(e.value), fit: BoxFit.cover),
                        ),
                      )).toList(),
                    )),
                    _buildSection('Pricing Packages', Column(
                      children: vendor.packages.map((pkg) => Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${pkg.name} Package', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                Text('₹${pkg.price}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primary)),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ...pkg.features.map((f) => Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Row(
                                children: [
                                  Text('•', style: TextStyle(color: AppColors.primary, fontSize: 14)),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(f, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                                ],
                              ),
                            )),
                          ],
                        ),
                      )).toList(),
                    )),
                  ],
                ),
              ),
            ],
          ),

          // Sticky CTAs
          Positioned(
            bottom: 80 + MediaQuery.of(context).padding.bottom + 16, left: 16, right: 16,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.85),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20)],
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => ref.read(appProvider.notifier).toggleSaveVendor(savedKey),
                    child: Container(
                      width: 48, height: 48,
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(12)),
                      child: Icon(LucideIcons.bookmark, size: 18, color: saved ? AppColors.primary : AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 1,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Calling vendor...')));
                      },
                      icon: Icon(LucideIcons.phone, size: 16),
                      label: Text('Contact'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: AppColors.foreground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed: () => context.push('/services/${service.id}/vendor/${vendor.id}/book'),
                      icon: Icon(LucideIcons.calendarPlus, size: 16),
                      label: Text('Book Service'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const Align(
            alignment: Alignment.bottomCenter,
            child: BottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 12),
          content,
        ],
      ),
    );
  }
}
