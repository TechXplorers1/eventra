import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/data/services_marketplace_data.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_components.dart';

// ── Category definitions ──────────────────────────────────────────────────────
class _Cat {
  final String label;
  final IconData icon;
  final String route;
  final Color color;
  const _Cat(this.label, this.icon, this.route, this.color);
}

const _categories = [
  _Cat('Music',        LucideIcons.music,          '/explore', Color(0xFF8B5CF6)),
  _Cat('Sports',       LucideIcons.trophy,          '/explore', Color(0xFF22C55E)),
  _Cat('Nightlife',    LucideIcons.moon,            '/explore', Color(0xFF3B82F6)),
  _Cat('Comedy',       LucideIcons.smile,           '/explore', Color(0xFFF59E0B)),
  _Cat('Festival',     LucideIcons.sparkles,        '/explore', Color(0xFFEF4444)),
  _Cat('Wedding',      LucideIcons.heart,           '/explore', Color(0xFFEC4899)),
  _Cat('Corporate',    LucideIcons.briefcase,       '/explore', Color(0xFF6366F1)),
  _Cat('All',          LucideIcons.compass,         '/explore', AppColors.accent),
];

const _serviceCategories = [
  _Cat('Photography',  LucideIcons.camera,        '/services/photographer',  Color(0xFF8B5CF6)),
  _Cat('Catering',     LucideIcons.utensils,      '/services/caterer',       Color(0xFFF59E0B)),
  _Cat('DJ / Music',   LucideIcons.disc3,         '/services/dj',            Color(0xFF3B82F6)),
  _Cat('Decoration',   LucideIcons.flower2,       '/services/decoration',    Color(0xFFEC4899)),
  _Cat('Venue',        LucideIcons.building2,     '/services/venue',         Color(0xFF22C55E)),
  _Cat('Videography',  LucideIcons.video,         '/services/videographer',  Color(0xFF6366F1)),
  _Cat('Planner',      LucideIcons.clipboardList, '/services/planner',       Color(0xFFEF4444)),
  _Cat('More',         LucideIcons.moreHorizontal,'/services',               AppColors.accent),
];

// Mock Offers Data
class OfferData {
  final String title;
  final String code;
  final String bgUrl;
  final Color color;
  OfferData(this.title, this.code, this.bgUrl, this.color);
}
final _mockOffers = [
  OfferData('20% Off Your First Booking', 'FIRST20', 'https://images.unsplash.com/photo-1492684223066-81342ee5ff30?w=500&q=80', Color(0xFF8B5CF6)),
  OfferData('Early Bird Festival Deals', 'FEST26', 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=500&q=80', Color(0xFFEF4444)),
];

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String _activeFilter = 'All';

  static const _filters = ['All', 'Music', 'Sports', 'Comedy', 'Festival', 'Nightlife', 'Wedding'];

  List<EventData> _filtered(List<EventData> src) =>
      _activeFilter == 'All' ? src : src.where((e) => e.category == _activeFilter).toList();

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final allEvents = appState.allEvents;
    final featured = allEvents.where((e) => e.featured).take(5).toList();
    final upcomingThisWeek = _filtered(allEvents).skip(1).take(5).toList();
    final upcomingAll = _filtered(allEvents).take(8).toList();
    final city = appState.selectedCity;
    final unread = appState.unreadCount;

    // Fetch mock providers and venues
    final topProviders = getVendorsForService('photographer', 8000).take(2).toList()
      ..addAll(getVendorsForService('dj', 10000).take(2))
      ..addAll(getVendorsForService('decorator', 11000).take(1));
    final topVenues = getVendorsForService('banquet-hall', 50000).take(5).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [
                // ── Top App Bar ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, AppSpacing.pagePaddingV, AppSpacing.pagePaddingH, 0),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(children: [
                                Icon(LucideIcons.mapPin, size: 12, color: AppColors.accent),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(city, maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.accent)),
                                ),
                                const SizedBox(width: 2),
                                Icon(LucideIcons.chevronsUpDown, size: 10, color: AppColors.mutedForeground),
                              ]),
                              const SizedBox(height: 2),
                              Text('Discover Events', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppColors.foreground)),
                            ],
                          ),
                        ),
                        _HeaderBadgeBtn(
                          icon: LucideIcons.bell,
                          hasBadge: unread > 0,
                          onTap: () => context.push('/notifications'),
                        ),
                        const SizedBox(width: 10),
                        _HeaderBadgeBtn(
                          icon: LucideIcons.user,
                          hasBadge: false,
                          onTap: () => context.go('/profile'),
                        ),
                      ],
                    ),
                  ),
                ),

                // ── Search Bar ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, AppSpacing.lg, AppSpacing.pagePaddingH, 0),
                    child: GestureDetector(
                      onTap: () => context.push('/search'),
                      child: Container(
                        height: 54,
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                          border: Border.all(color: AppColors.border.withAlpha(50)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(children: [
                          Icon(LucideIcons.search, size: 20, color: AppColors.mutedForeground),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Text('Search events, artists, venues…',
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                                style: TextStyle(fontSize: 14, color: AppColors.mutedForeground.withAlpha(180))),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.card,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 4, offset: const Offset(0, 2))],
                            ),
                            child: Icon(LucideIcons.sliders, size: 16, color: AppColors.foreground),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),

                // ── Category Pills ────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: AppSpacing.lg),
                    child: SizedBox(
                      height: 42,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (context, i) {
                          final cat = _categories[i];
                          final active = _activeFilter == cat.label || (cat.label == 'All' && _activeFilter == 'All');
                          
                          return GestureDetector(
                            onTap: () {
                              setState(() => _activeFilter = cat.label == 'All' ? 'All' : cat.label);
                              if (cat.label == 'All' && i == _categories.length - 1) context.push('/explore');
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                              decoration: BoxDecoration(
                                color: active ? cat.color.withAlpha(25) : AppColors.secondary.withAlpha(80),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: active ? cat.color.withAlpha(150) : Colors.transparent,
                                  width: 1,
                                ),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                if (cat.label != 'All') ...[
                                  Icon(cat.icon, size: 14, color: active ? cat.color : AppColors.mutedForeground),
                                  const SizedBox(width: 6),
                                ],
                                Text(cat.label, style: TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.w700,
                                  color: active ? cat.color : AppColors.mutedForeground,
                                )),
                              ]),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── [NEW] Offers & Deals ──────────────────────────────────
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 120,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      scrollDirection: Axis.horizontal,
                      itemCount: _mockOffers.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _PremiumOfferCard(offer: _mockOffers[i]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── Featured Events Hero Carousel ─────────────────────────
                if (featured.isNotEmpty) ...[
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      child: EvSectionHeader(
                        title: 'Featured Events',
                        actionLabel: 'See All',
                        onAction: () => context.push('/explore'),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 240,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                        scrollDirection: Axis.horizontal,
                        itemCount: featured.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 16),
                        itemBuilder: (_, i) => _PremiumFeaturedCard(event: featured[i]),
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),
                ],

                // ── [NEW] Upcoming This Week ──────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Upcoming This Week',
                      actionLabel: 'View Calendar',
                      onAction: () => context.push('/explore'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 210,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      scrollDirection: Axis.horizontal,
                      itemCount: upcomingThisWeek.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _UpcomingThisWeekCard(event: upcomingThisWeek[i]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── Event Categories Grid ─────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Browse by Category',
                      actionLabel: 'Explore',
                      onAction: () => context.push('/explore'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 100,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      scrollDirection: Axis.horizontal,
                      itemCount: _filters.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 12),
                      itemBuilder: (_, i) {
                        final cat = _categories[i < _categories.length ? i : 0];
                        return _PremiumCategoryTile(cat: cat);
                      },
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── [NEW] Top Rated Providers ─────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Top Rated Providers',
                      subtitle: 'Highly recommended by organizers',
                      actionLabel: 'View All',
                      onAction: () => context.push('/services'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 160,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      scrollDirection: Axis.horizontal,
                      itemCount: topProviders.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _TopProviderCard(vendor: topProviders[i]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── Services Marketplace ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Book a Service',
                      subtitle: 'Photographers, DJs, Decorators & more',
                      actionLabel: 'All Services',
                      onAction: () => context.push('/services'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: GridView.count(
                    crossAxisCount: 4,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.80,
                    children: _serviceCategories.map((s) => _PremiumServiceTile(cat: s)).toList(),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── [NEW] Popular Venues ──────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Popular Venues',
                      subtitle: 'Find the perfect place for your event',
                      actionLabel: 'See All',
                      onAction: () => context.push('/services/banquet-hall'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 200,
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      scrollDirection: Axis.horizontal,
                      itemCount: topVenues.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (_, i) => _PopularVenueCard(venue: topVenues[i]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xl)),

                // ── All Events (Vertical List) ───────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Discover More Events',
                      subtitle: _activeFilter == 'All' ? null : _activeFilter,
                      actionLabel: 'Browse All',
                      onAction: () => context.push('/explore'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, 0, AppSpacing.pagePaddingH, 16),
                      child: _PremiumEventListCard(event: upcomingAll[i]),
                    ),
                    childCount: upcomingAll.length,
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.listBottomPad)),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }
}

// ── HEADER BADGE BTN ──────────────────────────────────────────────────────────
class _HeaderBadgeBtn extends StatelessWidget {
  final IconData icon;
  final bool hasBadge;
  final VoidCallback onTap;
  const _HeaderBadgeBtn({required this.icon, required this.hasBadge, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.border.withAlpha(50)),
            ),
            child: Icon(icon, size: 20, color: AppColors.foreground),
          ),
          if (hasBadge)
            Positioned(
              top: -2, right: -2,
              child: Container(
                width: 10, height: 10,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.background, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── [NEW] PREMIUM OFFER CARD ──────────────────────────────────────────────────
class _PremiumOfferCard extends StatelessWidget {
  final OfferData offer;
  const _PremiumOfferCard({required this.offer});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: offer.color.withAlpha(30), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.network(offer.bgUrl, fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: offer.color.withAlpha(200)),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(offer.title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(6)),
                        child: Text('Code: ${offer.code}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                  child: Icon(LucideIcons.arrowRight, color: offer.color),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── [NEW] UPCOMING THIS WEEK CARD ─────────────────────────────────────────────
class _UpcomingThisWeekCard extends StatelessWidget {
  final EventData event;
  const _UpcomingThisWeekCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Comedy': Color(0xFFF59E0B), 'Festival': Color(0xFFEF4444),
    'Nightlife': Color(0xFF3B82F6), 'Wedding': Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    final imageUrl = categoryImages[event.imageKey] ?? 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80';

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(100)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100, width: 160,
              decoration: BoxDecoration(image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover)),
              child: Stack(
                children: [
                  Positioned(
                    top: 8, left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(4)),
                      child: Text('${_day(event.date)} ${_month(event.date)}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.foreground, height: 1.2)),
                  const SizedBox(height: 6),
                  Row(children: [
                    Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.city, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 10, color: AppColors.mutedForeground))),
                  ]),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _month(String date) { try { return date.split(' ')[0].substring(0, 3).toUpperCase(); } catch (_) { return ''; } }
  String _day(String date) { try { return date.split(' ')[1].replaceAll(',', ''); } catch (_) { return ''; } }
}

// ── [NEW] TOP PROVIDER CARD ───────────────────────────────────────────────────
class _TopProviderCard extends StatelessWidget {
  final Vendor vendor;
  const _TopProviderCard({required this.vendor});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Could link to vendor profile
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withAlpha(100)),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(color: AppColors.primary.withAlpha(20), shape: BoxShape.circle),
                  child: Center(child: Text(vendor.name.substring(0, 1), style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.primary))),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(vendor.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                      Text(vendor.specialization, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1, color: AppColors.border),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(LucideIcons.star, size: 14, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${vendor.rating}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                  ],
                ),
                Text('₹${vendor.startingPrice}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.primary)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── [NEW] POPULAR VENUE CARD ──────────────────────────────────────────────────
class _PopularVenueCard extends StatelessWidget {
  final Vendor venue;
  const _PopularVenueCard({required this.venue});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // Could link to venue profile
      child: Container(
        width: 260,
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withAlpha(100)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned(
              top: 0, left: 0, right: 0, height: 120,
              child: Image.network('https://images.unsplash.com/photo-1519167758481-83f550bb49b3?w=600&q=80', fit: BoxFit.cover),
            ),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    const Icon(LucideIcons.star, size: 12, color: Colors.orange),
                    const SizedBox(width: 4),
                    Text('${venue.rating}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: Colors.black)),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 120, left: 0, right: 0, bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(venue.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Icon(LucideIcons.mapPin, size: 12, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Expanded(child: Text(venue.city, maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PREMIUM FEATURED HERO CARD ────────────────────────────────────────────────
class _PremiumFeaturedCard extends StatelessWidget {
  final EventData event;
  const _PremiumFeaturedCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Comedy': Color(0xFFF59E0B), 'Festival': Color(0xFFEF4444),
    'Nightlife': Color(0xFF3B82F6), 'Wedding': Color(0xFFEC4899),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    final imageUrl = categoryImages[event.imageKey] ?? 'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?auto=format&fit=crop&q=80';

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 15, offset: const Offset(0, 8)),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Positioned.fill(
              child: Image.network(imageUrl, fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withAlpha(220)],
                    stops: const [0.3, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 16, right: 16, bottom: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            color: color.withAlpha(50),
                            child: Text(event.category, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Icon(LucideIcons.calendar, size: 12, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(event.date, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white70)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.white, height: 1.2)),
                  const SizedBox(height: 8),
                  Row(children: [
                    const Icon(LucideIcons.mapPin, size: 12, color: Colors.white70),
                    const SizedBox(width: 4),
                    Expanded(child: Text(event.city, maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70))),
                    Text(
                      event.price == 0 ? 'Free' : '₹${event.price.toInt()}',
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: Colors.white),
                    ),
                  ]),
                ],
              ),
            ),
            Positioned(
              top: 12, right: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    color: Colors.black.withAlpha(80),
                    child: Row(
                      children: [
                        const Icon(LucideIcons.star, size: 10, color: Colors.orange),
                        const SizedBox(width: 4),
                        const Text('Featured', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Colors.white)),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── PREMIUM CATEGORY TILE ─────────────────────────────────────────────────────
class _PremiumCategoryTile extends StatelessWidget {
  final _Cat cat;
  const _PremiumCategoryTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(cat.route),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64, height: 64,
            decoration: BoxDecoration(
              color: cat.color.withAlpha(20),
              shape: BoxShape.circle,
              border: Border.all(color: cat.color.withAlpha(40)),
            ),
            child: Icon(cat.icon, size: 24, color: cat.color),
          ),
          const SizedBox(height: 8),
          Text(cat.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        ],
      ),
    );
  }
}

// ── PREMIUM SERVICE TILE ──────────────────────────────────────────────────────
class _PremiumServiceTile extends StatelessWidget {
  final _Cat cat;
  const _PremiumServiceTile({required this.cat});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(cat.route),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.secondary.withAlpha(100),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border.withAlpha(50)),
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: cat.color.withAlpha(20), shape: BoxShape.circle),
            child: Icon(cat.icon, size: 20, color: cat.color),
          ),
          const SizedBox(height: 10),
          Text(cat.label, textAlign: TextAlign.center, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.foreground)),
        ]),
      ),
    );
  }
}

// ── PREMIUM EVENT LIST CARD (VERTICAL) ────────────────────────────────────────
class _PremiumEventListCard extends StatelessWidget {
  final EventData event;
  const _PremiumEventListCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Comedy': Color(0xFFF59E0B), 'Festival': Color(0xFFEF4444),
    'Nightlife': Color(0xFF3B82F6), 'Wedding': Color(0xFFEC4899),
    'Corporate': Color(0xFF6366F1),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    final imageUrl = categoryImages[event.imageKey] ?? 'https://images.unsplash.com/photo-1513364776144-60967b0f800f?auto=format&fit=crop&q=80';

    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.border.withAlpha(100)),
          boxShadow: [
            BoxShadow(color: Colors.black.withAlpha(20), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(image: NetworkImage(imageUrl), fit: BoxFit.cover),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('${_day(event.date)} ${_month(event.date)} • ${event.time}', 
                          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: color)),
                      const Spacer(),
                      Icon(LucideIcons.bookmark, size: 16, color: AppColors.mutedForeground),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(LucideIcons.mapPin, size: 12, color: AppColors.mutedForeground),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(event.city, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ),
                      Text(
                        event.price == 0 ? 'Free' : '₹${event.price.toInt()}',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  String _month(String date) { try { return date.split(' ')[0].substring(0, 3).toUpperCase(); } catch (_) { return ''; } }
  String _day(String date) { try { return date.split(' ')[1].replaceAll(',', ''); } catch (_) { return ''; } }
}
