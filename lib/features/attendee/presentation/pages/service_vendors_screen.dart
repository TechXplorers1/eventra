import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';
import '../../../../shared/widgets/ev_components.dart';

class ServiceVendorsScreen extends ConsumerStatefulWidget {
  final String id;
  const ServiceVendorsScreen({super.key, required this.id});

  @override
  ConsumerState<ServiceVendorsScreen> createState() => _ServiceVendorsScreenState();
}

class _ServiceVendorsScreenState extends ConsumerState<ServiceVendorsScreen> {
  final _searchCtrl = TextEditingController();
  String _query = '';
  bool _filtersOpen = false;
  String _cityFilter = 'All';
  double _minRating = 0.0;
  bool _availOnly = false;
  String _sortBy = 'Rating'; // 'Rating' | 'Price' | 'Experience'

  static const _sortOptions = ['Rating', 'Price', 'Experience'];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final service = findUserService(widget.id);

    if (service == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: EvEmptyState(
          icon: LucideIcons.searchX,
          title: 'Service Not Found',
          subtitle: 'This service category was not found.',
          actionLabel: 'Browse Services',
          onAction: () => context.go('/services'),
        ),
      );
    }

    final currentProfile = ref.watch(appProvider).serviceProvider;
    var vendors = getVendorsForService(service.id, service.startingPrice, currentProfile);
    final cities = ['All', ...vendors.map((v) => v.city).toSet()];

    // Filter
    vendors = vendors.where((v) {
      final q = _query.trim().toLowerCase();
      if (q.isNotEmpty && !(v.name.toLowerCase().contains(q) || v.specialization.toLowerCase().contains(q) || v.city.toLowerCase().contains(q))) return false;
      if (_cityFilter != 'All' && v.city != _cityFilter) return false;
      if (v.rating < _minRating) return false;
      if (_availOnly && v.availability != 'Available') return false;
      return true;
    }).toList();

    // Sort
    switch (_sortBy) {
      case 'Rating':     vendors.sort((a, b) => b.rating.compareTo(a.rating)); break;
      case 'Price':      vendors.sort((a, b) => a.startingPrice.compareTo(b.startingPrice)); break;
      case 'Experience': vendors.sort((a, b) => b.experienceYears.compareTo(a.experienceYears)); break;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [

                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, AppSpacing.pagePaddingV, AppSpacing.pagePaddingH, 0),
                  child: Row(children: [
                    EvBackButton(onPressed: () => context.pop()),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('${service.name}s', maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                      Text('${vendors.length} vendors found', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                    ])),
                    Container(
                      width: 42, height: 42,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      ),
                      child: Icon(service.icon, size: 20, color: Colors.white),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Search + Filter Toggle ────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                  child: Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _searchCtrl,
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search ${service.name.toLowerCase()}s…',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Icon(LucideIcons.search, size: 16, color: AppColors.mutedForeground),
                          ),
                          suffixIcon: _query.isNotEmpty
                              ? IconButton(
                                  icon: Icon(LucideIcons.x, size: 14, color: AppColors.mutedForeground),
                                  onPressed: () { _searchCtrl.clear(); setState(() => _query = ''); },
                                )
                              : null,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () => setState(() => _filtersOpen = !_filtersOpen),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 46, height: 46,
                        decoration: BoxDecoration(
                          gradient: _filtersOpen ? AppColors.primaryGradient : null,
                          color: _filtersOpen ? null : AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          border: Border.all(color: _filtersOpen ? Colors.transparent : AppColors.border),
                        ),
                        child: Icon(LucideIcons.slidersHorizontal, size: 18,
                            color: _filtersOpen ? Colors.white : AppColors.mutedForeground),
                      ),
                    ),
                  ]),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Sort Pills ────────────────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    scrollDirection: Axis.horizontal,
                    itemCount: _sortOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final opt = _sortOptions[i];
                      final active = _sortBy == opt;
                      return GestureDetector(
                        onTap: () => setState(() => _sortBy = opt),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: active ? AppColors.primary : AppColors.border),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(
                              opt == 'Rating' ? LucideIcons.star : opt == 'Price' ? LucideIcons.indianRupee : LucideIcons.award,
                              size: 11, color: active ? Colors.white : AppColors.mutedForeground,
                            ),
                            const SizedBox(width: 4),
                            Text(opt, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                color: active ? Colors.white : AppColors.mutedForeground)),
                          ]),
                        ),
                      );
                    },
                  ),
                ),

                // ── Filter Panel ──────────────────────────────────────
                if (_filtersOpen)
                  AnimatedSize(
                    duration: const Duration(milliseconds: 250),
                    child: Container(
                      margin: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, AppSpacing.sm, AppSpacing.pagePaddingH, 0),
                      padding: const EdgeInsets.all(AppSpacing.cardPadding),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // City
                        Text('City', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 0.6)),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6, runSpacing: 6,
                          children: cities.map((c) {
                            final sel = _cityFilter == c;
                            return GestureDetector(
                              onTap: () => setState(() => _cityFilter = c),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                                ),
                                child: Text(c, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
                                    color: sel ? Colors.white : AppColors.foreground)),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Rating
                        Text('Min Rating: ${_minRating == 0 ? 'Any' : '$_minRating+'}',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.mutedForeground, letterSpacing: 0.6)),
                        const SizedBox(height: 8),
                        Row(children: [0.0, 4.0, 4.5, 4.8].map((r) {
                          final sel = _minRating == r;
                          return Expanded(child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: GestureDetector(
                              onTap: () => setState(() => _minRating = r),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(vertical: 7),
                                decoration: BoxDecoration(
                                  color: sel ? AppColors.primary : AppColors.secondary,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: sel ? AppColors.primary : AppColors.border),
                                ),
                                alignment: Alignment.center,
                                child: Text(r == 0 ? 'Any' : '$r+',
                                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                                        color: sel ? Colors.white : AppColors.foreground)),
                              ),
                            ),
                          ));
                        }).toList()),
                        const SizedBox(height: AppSpacing.md),

                        // Available only
                        Row(children: [
                          Text('Available only', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                          const Spacer(),
                          Switch.adaptive(
                            value: _availOnly,
                            onChanged: (v) => setState(() => _availOnly = v),
                            activeColor: AppColors.primary,
                          ),
                        ]),
                      ]),
                    ),
                  ),

                const SizedBox(height: AppSpacing.sm),

                // ── Vendor List ───────────────────────────────────────
                Expanded(
                  child: vendors.isEmpty
                      ? EvEmptyState(
                          icon: LucideIcons.searchX,
                          title: 'No Vendors Found',
                          subtitle: 'Try adjusting your filters or search term.',
                          actionLabel: 'Clear Filters',
                          onAction: () => setState(() {
                            _query = ''; _searchCtrl.clear();
                            _cityFilter = 'All'; _minRating = 0; _availOnly = false;
                          }),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.pagePaddingH, 0,
                            AppSpacing.pagePaddingH, AppSpacing.listBottomPad,
                          ),
                          itemCount: vendors.length,
                          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.itemSpacing),
                          itemBuilder: (_, i) => _VendorCard(
                            vendor: vendors[i],
                            serviceId: service.id,
                          ),
                        ),
                ),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }
}

// ── Vendor Card ───────────────────────────────────────────────────────────────
class _VendorCard extends StatelessWidget {
  final dynamic vendor;
  final String serviceId;
  const _VendorCard({required this.vendor, required this.serviceId});

  @override
  Widget build(BuildContext context) {
    final avail = vendor.availability as String;

    // Initials avatar
    final initials = (vendor.name as String)
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return GestureDetector(
      onTap: () => context.push('/services/$serviceId/vendor/${vendor.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              ),
              alignment: Alignment.center,
              child: Text(initials, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Details
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(
                    child: Text(vendor.name as String,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  EvStatusBadge(avail),
                ]),
                const SizedBox(height: 5),
                Row(children: [
                  _Meta(LucideIcons.star, '${vendor.rating}', color: AppColors.warning),
                  const SizedBox(width: 10),
                  _Meta(LucideIcons.mapPin, vendor.city as String),
                  const SizedBox(width: 10),
                  _Meta(LucideIcons.award, '${vendor.experienceYears}y exp'),
                ]),
                const SizedBox(height: 5),
                Text(vendor.specialization as String,
                    style: TextStyle(fontSize: 11, color: AppColors.mutedForeground),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 6),
                Row(children: [
                  Text('₹${vendor.startingPrice}',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.primary)),
                  Text(' onwards', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(18),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.primary.withAlpha(60)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.primary)),
                      const SizedBox(width: 3),
                      Icon(LucideIcons.arrowRight, size: 10, color: AppColors.primary),
                    ]),
                  ),
                ]),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}

class _Meta extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;
  const _Meta(this.icon, this.text, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppColors.mutedForeground;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 11, color: c),
      const SizedBox(width: 3),
      Text(text, style: TextStyle(fontSize: 11, color: c, fontWeight: color != null ? FontWeight.w600 : FontWeight.normal)),
    ]);
  }
}
