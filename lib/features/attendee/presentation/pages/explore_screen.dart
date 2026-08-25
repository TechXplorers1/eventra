import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';
import '../../../../shared/widgets/ev_components.dart';

const _allCategories = [
  ('All',        LucideIcons.compass,      Color(0xFF8B5CF6)),
  ('Music',      LucideIcons.music,        Color(0xFF8B5CF6)),
  ('Sports',     LucideIcons.trophy,       Color(0xFF22C55E)),
  ('Festival',   LucideIcons.sparkles,     Color(0xFFEF4444)),
  ('Comedy',     LucideIcons.smile,        Color(0xFFF59E0B)),
  ('Nightlife',  LucideIcons.moon,         Color(0xFF3B82F6)),
  ('Wedding',    LucideIcons.heart,        Color(0xFFEC4899)),
  ('Corporate',  LucideIcons.briefcase,    Color(0xFF6366F1)),
  ('Conference', LucideIcons.mic2,         Color(0xFF14B8A6)),
];

const _timeFilters = ['All Time', 'Today', 'Tomorrow', 'This Weekend', 'This Month'];

class ExploreScreen extends ConsumerStatefulWidget {
  const ExploreScreen({super.key});

  @override
  ConsumerState<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends ConsumerState<ExploreScreen> {
  final _searchController = TextEditingController();
  String _query = '';
  String _activeCategory = 'All';
  String _activeTime = 'All Time';
  bool _gridView = true;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  DateTime? _parseEventDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    final direct = DateTime.tryParse(dateStr);
    if (direct != null) return direct;

    try {
      final parts = dateStr.replaceAll(',', '').trim().split(RegExp(r'\s+'));
      if (parts.length >= 3) {
        final monthStr = parts[0].toLowerCase();
        final day = int.parse(parts[1]);
        final year = int.parse(parts[2]);

        const monthMap = {
          'jan': 1, 'january': 1,
          'feb': 2, 'february': 2,
          'mar': 3, 'march': 3,
          'apr': 4, 'april': 4,
          'may': 5,
          'jun': 6, 'june': 6,
          'jul': 7, 'july': 7,
          'aug': 8, 'august': 8,
          'sep': 9, 'september': 9,
          'oct': 10, 'october': 10,
          'nov': 11, 'november': 11,
          'dec': 12, 'december': 12,
        };

        final month = monthMap[monthStr];
        if (month != null) {
          return DateTime(year, month, day);
        }
      }
    } catch (_) {}
    return null;
  }

  List<EventData> _applyFilters(List<EventData> src) {
    var list = src;
    final q = _query.trim().toLowerCase();
    if (q.length >= 2) {
      list = list.where((e) =>
        e.title.toLowerCase().contains(q) ||
        e.category.toLowerCase().contains(q) ||
        e.city.toLowerCase().contains(q) ||
        e.venue.toLowerCase().contains(q)
      ).toList();
    }
    if (_activeCategory != 'All') {
      list = list.where((e) => e.category == _activeCategory).toList();
    }
    if (_activeTime != 'All Time' && _activeTime != 'All') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);

      list = list.where((e) {
        final eventDate = _parseEventDate(e.date);
        if (eventDate == null) return false;

        final eDay = DateTime(eventDate.year, eventDate.month, eventDate.day);

        if (_activeTime == 'Today') {
          return eDay.year == today.year && eDay.month == today.month && eDay.day == today.day;
        } else if (_activeTime == 'Tomorrow') {
          final tomorrow = today.add(const Duration(days: 1));
          return eDay.year == tomorrow.year && eDay.month == tomorrow.month && eDay.day == tomorrow.day;
        } else if (_activeTime == 'This Weekend') {
          final saturday = today.add(Duration(days: (6 - today.weekday) % 7));
          final sunday = saturday.add(const Duration(days: 1));
          return (eDay.year == saturday.year && eDay.month == saturday.month && eDay.day == saturday.day) ||
                 (eDay.year == sunday.year && eDay.month == sunday.month && eDay.day == sunday.day);
        } else if (_activeTime == 'This Month') {
          return eDay.year == now.year && eDay.month == now.month;
        }
        return true;
      }).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final allEvents = ref.watch(appProvider.select((s) => s.allEvents));
    final filtered = _applyFilters(allEvents);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                // ── Header ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingH, AppSpacing.pagePaddingV,
                    AppSpacing.pagePaddingH, 0,
                  ),
                  child: Row(
                    children: [
                      const EvBackButton(),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Explore', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                          Text('${allEvents.length} events available', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                        ]),
                      ),
                      // Grid/List toggle
                      GestureDetector(
                        onTap: () => setState(() => _gridView = !_gridView),
                        child: Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.secondary,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Icon(
                            _gridView ? LucideIcons.layoutList : LucideIcons.layoutGrid,
                            size: 16, color: AppColors.mutedForeground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Search ─────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() => _query = v),
                    style: TextStyle(color: AppColors.foreground, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search events, cities, categories…',
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Icon(LucideIcons.search, size: 18, color: AppColors.mutedForeground),
                      ),
                      suffixIcon: _query.isNotEmpty
                          ? IconButton(
                              icon: Icon(LucideIcons.x, size: 14, color: AppColors.mutedForeground),
                              onPressed: () {
                                _searchController.clear();
                                setState(() => _query = '');
                              },
                            )
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Category Filter Row ────────────────────────────────
                SizedBox(
                  height: 38,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    scrollDirection: Axis.horizontal,
                    itemCount: _allCategories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final (label, icon, color) = _allCategories[i];
                      final active = _activeCategory == label;
                      return GestureDetector(
                        onTap: () => setState(() => _activeCategory = label),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: active ? color.withAlpha(28) : AppColors.secondary,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                            border: Border.all(color: active ? color : AppColors.border, width: active ? 1.5 : 1),
                          ),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            Icon(icon, size: 13, color: active ? color : AppColors.mutedForeground),
                            const SizedBox(width: 5),
                            Text(label, style: TextStyle(
                              fontSize: 12, fontWeight: FontWeight.w600,
                              color: active ? color : AppColors.mutedForeground,
                            )),
                          ]),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Time Filter Row ────────────────────────────────────
                SizedBox(
                  height: 34,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    scrollDirection: Axis.horizontal,
                    itemCount: _timeFilters.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (_, i) {
                      final f = _timeFilters[i];
                      final active = _activeTime == f;
                      return GestureDetector(
                        onTap: () => setState(() => _activeTime = f),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: active ? AppColors.primary : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppSpacing.radiusChip),
                            border: Border.all(color: active ? AppColors.primary : AppColors.border),
                          ),
                          child: Text(f, style: TextStyle(
                            fontSize: 11, fontWeight: FontWeight.w600,
                            color: active ? Colors.white : AppColors.mutedForeground,
                          )),
                        ),
                      );
                    },
                  ),
                ),

                // ── Result count ──────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, 10, AppSpacing.pagePaddingH, 4),
                  child: Text(
                    '${filtered.length} ${filtered.length == 1 ? 'event' : 'events'} found',
                    style: TextStyle(fontSize: 12, color: AppColors.mutedForeground, fontWeight: FontWeight.w500),
                  ),
                ),

                // ── Results ───────────────────────────────────────────
                Expanded(
                  child: filtered.isEmpty
                      ? EvEmptyState(
                          icon: LucideIcons.searchX,
                          title: 'No Events Found',
                          subtitle: 'Try a different search term or category.',
                          actionLabel: 'Clear Filters',
                          onAction: () => setState(() {
                            _query = '';
                            _searchController.clear();
                            _activeCategory = 'All';
                            _activeTime = 'All Time';
                          }),
                        )
                      : _gridView
                          ? _buildGrid(filtered)
                          : _buildList(filtered),
                ),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildList(List<EventData> events) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingH, AppSpacing.xs,
        AppSpacing.pagePaddingH, AppSpacing.listBottomPad,
      ),
      itemCount: events.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (_, i) => _ExploreListCard(event: events[i]),
    );
  }

  Widget _buildGrid(List<EventData> events) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingH, AppSpacing.xs,
        AppSpacing.pagePaddingH, AppSpacing.listBottomPad,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.75,
      ),
      itemCount: events.length,
      itemBuilder: (_, i) => _ExploreGridCard(event: events[i]),
    );
  }
}

// ── List Card ─────────────────────────────────────────────────────────────────
class _ExploreListCard extends StatelessWidget {
  final EventData event;
  const _ExploreListCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Comedy': Color(0xFFF59E0B), 'Festival': Color(0xFFEF4444),
    'Nightlife': Color(0xFF3B82F6), 'Wedding': Color(0xFFEC4899),
    'Corporate': Color(0xFF6366F1), 'Conference': Color(0xFF14B8A6),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          // Color date block
          Container(
            width: 62, height: 90,
            decoration: BoxDecoration(
              color: color.withAlpha(22),
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(AppSpacing.radiusLg)),
            ),
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text(_month(event.date), style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color)),
              Text(_day(event.date), style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: color, height: 1.1)),
            ]),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(LucideIcons.clock4, size: 11, color: AppColors.mutedForeground),
                  const SizedBox(width: 3),
                  Text(event.time, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
                  const SizedBox(width: 3),
                  Expanded(child: Text('${event.venue}, ${event.city}', maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                ]),
                const SizedBox(height: 6),
                Row(children: [
                  EvBadge(label: event.category, color: color, small: true),
                  const Spacer(),
                  Text(
                    event.price == 0 ? 'Free' : '₹${event.price.toInt()}',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: color),
                  ),
                ]),
              ]),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.sm),
            child: Icon(LucideIcons.chevronRight, size: 14, color: AppColors.mutedForeground),
          ),
        ]),
      ),
    );
  }

  String _month(String d) { try { return d.split(' ')[0].toUpperCase().substring(0, 3); } catch (_) { return ''; } }
  String _day(String d) { try { return d.split(' ')[1].replaceAll(',', ''); } catch (_) { return ''; } }
}

// ── Grid Card ────────────────────────────────────────────────────────────────
class _ExploreGridCard extends StatelessWidget {
  final EventData event;
  const _ExploreGridCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Comedy': Color(0xFFF59E0B), 'Festival': Color(0xFFEF4444),
    'Nightlife': Color(0xFF3B82F6), 'Wedding': Color(0xFFEC4899),
    'Corporate': Color(0xFF6366F1),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    return GestureDetector(
      onTap: () => context.push('/event/${event.id}'),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Header image (approx 70%)
          Expanded(
            flex: 7,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(categoryImages[event.imageKey] ?? 'https://images.unsplash.com/photo-1514525253161-7a46d19cd819?w=500&q=80'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Stack(children: [
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.black.withAlpha(150), Colors.transparent, Colors.black.withAlpha(150)],
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    ),
                  ),
                ),
                Positioned(top: 8, left: 10, child: EvBadge(label: event.category, color: color, small: true)),
                Positioned(bottom: 8, right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.black.withAlpha(180), borderRadius: BorderRadius.circular(4)),
                    child: Text(event.price == 0 ? 'Free' : '₹${event.price.toInt()}',
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                ),
              ]),
            ),
          ),
          // Content (approx 30%)
          Expanded(
            flex: 4,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.foreground, height: 1.2)),
                const Spacer(),
                Row(children: [
                  Icon(LucideIcons.calendar, size: 10, color: AppColors.mutedForeground),
                  const SizedBox(width: 3),
                  Expanded(child: Text(event.date, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: AppColors.mutedForeground))),
                ]),
                const SizedBox(height: 2),
                Row(children: [
                  Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground),
                  const SizedBox(width: 3),
                  Expanded(child: Text(event.city, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 10, color: AppColors.mutedForeground))),
                ]),
              ]),
            ),
          ),
        ]),
      ),
    );
  }
}
