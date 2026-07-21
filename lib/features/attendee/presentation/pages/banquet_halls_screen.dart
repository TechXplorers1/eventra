import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/banquet_halls_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class BanquetHallsScreen extends ConsumerStatefulWidget {
  const BanquetHallsScreen({super.key});

  @override
  ConsumerState<BanquetHallsScreen> createState() => _BanquetHallsScreenState();
}

class _BanquetHallsScreenState extends ConsumerState<BanquetHallsScreen> {
  String _query = '';
  bool _showFilters = false;
  String _sortBy = 'recommended';

  String _city = 'All';
  String _venueType = 'All';
  String _io = 'All';
  double _minCap = 0;
  double _maxBudget = 500000;
  bool _parkingOnly = false;
  bool _acOnly = false;
  double _minRating = 0;

  List<BanquetHall> get _filteredHalls {
    final q = _query.trim().toLowerCase();
    var list = banquetHalls.where((h) {
      if (q.isNotEmpty && !'${h.name} ${h.city} ${h.area}'.toLowerCase().contains(q)) return false;
      if (_city != 'All' && h.city != _city) return false;
      if (_venueType != 'All' && h.venueType != _venueType) return false;
      if (_io != 'All' && h.indoorOutdoor != _io && h.indoorOutdoor != 'Both') return false;
      if (h.capacity < _minCap) return false;
      if (h.startingPrice > _maxBudget) return false;
      if (_parkingOnly && !h.parking) return false;
      if (_acOnly && !h.ac) return false;
      if (h.rating < _minRating) return false;
      return true;
    }).toList();

    switch (_sortBy) {
      case 'price-low':
        list.sort((a, b) => a.startingPrice.compareTo(b.startingPrice));
        break;
      case 'price-high':
        list.sort((a, b) => b.startingPrice.compareTo(a.startingPrice));
        break;
      case 'rating':
        list.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case 'capacity':
        list.sort((a, b) => b.capacity.compareTo(a.capacity));
        break;
    }
    return list;
  }

  void _resetFilters() {
    setState(() {
      _city = 'All'; _venueType = 'All'; _io = 'All';
      _minCap = 0; _maxBudget = 500000; _parkingOnly = false; _acOnly = false; _minRating = 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredHalls;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
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
                        Text('Banquet Halls', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        Text('${filtered.length} premium venues', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: () => setState(() => _showFilters = !_showFilters),
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40, height: 40,
                      decoration: BoxDecoration(
                        gradient: _showFilters ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                        color: _showFilters ? null : AppColors.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(LucideIcons.slidersHorizontal, size: 18, color: _showFilters ? AppColors.primaryForeground : AppColors.foreground),
                    ),
                  ),
                ],
              ),
            ),

            // Search
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                child: Row(
                  children: [
                    Icon(LucideIcons.search, size: 18, color: AppColors.mutedForeground),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        onChanged: (v) => setState(() => _query = v),
                        style: TextStyle(color: AppColors.foreground, fontSize: 14),
                        decoration: InputDecoration(
                          hintText: 'Search venues, cities, areas...',
                          hintStyle: TextStyle(color: AppColors.mutedForeground),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    if (_query.isNotEmpty)
                      InkWell(
                        onTap: () => setState(() => _query = ''),
                        child: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Sort chips
            SizedBox(
              height: 32,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  {'id': 'recommended', 'label': 'Recommended'},
                  {'id': 'rating', 'label': 'Top Rated'},
                  {'id': 'price-low', 'label': 'Price: Low'},
                  {'id': 'price-high', 'label': 'Price: High'},
                  {'id': 'capacity', 'label': 'Capacity'},
                ].map((s) {
                  final isSelected = _sortBy == s['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _sortBy = s['id']!),
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                          color: isSelected ? null : AppColors.secondary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        alignment: Alignment.center,
                        child: Text(s['label']!, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryForeground : AppColors.foreground)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 12),

            // Filters panel
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.6),
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChipRow('City', _city, ['All', ...allHallCities], (v) => setState(() => _city = v)),
                      const SizedBox(height: 12),
                      _buildChipRow('Venue Type', _venueType, ['All', ...allVenueTypes], (v) => setState(() => _venueType = v)),
                      const SizedBox(height: 12),
                      _buildChipRow('Indoor / Outdoor', _io, ['All', 'Indoor', 'Outdoor', 'Both'], (v) => setState(() => _io = v)),
                      const SizedBox(height: 16),
                      
                      Text('Minimum Capacity: ${_minCap.toInt()} guests', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                      Slider(
                        value: _minCap, min: 0, max: 2000, divisions: 40,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _minCap = v),
                      ),
                      
                      Text('Max Budget: ₹${_maxBudget.toInt()}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                      Slider(
                        value: _maxBudget, min: 50000, max: 500000, divisions: 45,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _maxBudget = v),
                      ),

                      Text('Min Rating: ${_minRating.toStringAsFixed(1)}★', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
                      Slider(
                        value: _minRating, min: 0, max: 5, divisions: 10,
                        activeColor: AppColors.primary,
                        onChanged: (v) => setState(() => _minRating = v),
                      ),

                      Row(
                        children: [
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _parkingOnly = !_parkingOnly),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: _parkingOnly ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: _parkingOnly ? null : AppColors.background,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.parkingCircle, size: 14, color: _parkingOnly ? AppColors.primaryForeground : AppColors.foreground),
                                    const SizedBox(width: 6),
                                    Text('Parking', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _parkingOnly ? AppColors.primaryForeground : AppColors.foreground)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: InkWell(
                              onTap: () => setState(() => _acOnly = !_acOnly),
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 8),
                                decoration: BoxDecoration(
                                  gradient: _acOnly ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                                  color: _acOnly ? null : AppColors.background,
                                  border: Border.all(color: AppColors.border),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(LucideIcons.snowflake, size: 14, color: _acOnly ? AppColors.primaryForeground : AppColors.foreground),
                                    const SizedBox(width: 6),
                                    Text('AC', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: _acOnly ? AppColors.primaryForeground : AppColors.foreground)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton(
                          onPressed: _resetFilters,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.foreground,
                            side: BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text('Reset Filters', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Listings
            Expanded(
              child: filtered.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(LucideIcons.filter, size: 32, color: AppColors.mutedForeground),
                          const SizedBox(height: 12),
                          Text('No venues found', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          const SizedBox(height: 4),
                          Text('Try adjusting your filters.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) {
                        final h = filtered[i];
                        final savedKey = 'banquet:${h.id}';
                        final saved = ref.watch(appProvider).savedVendors.contains(savedKey);
                        return GestureDetector(
                          onTap: () => context.push('/banquet-halls/${h.id}'),
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: AppColors.secondary.withOpacity(0.6),
                              border: Border.all(color: AppColors.border),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 160,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Color(h.gallery[0]['colors'][0]),
                                        Color(h.gallery[0]['colors'][1]),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                  ),
                                  child: Stack(
                                    children: [
                                      Center(child: Icon(LucideIcons.building2, size: 56, color: Colors.white.withOpacity(0.4))),
                                      Positioned(
                                        top: 12, right: 12,
                                        child: InkWell(
                                          onTap: () => ref.read(appProvider.notifier).toggleSaveVendor(savedKey),
                                          child: Container(
                                            width: 36, height: 36,
                                            decoration: BoxDecoration(color: AppColors.background.withOpacity(0.6), shape: BoxShape.circle),
                                            child: Icon(LucideIcons.heart, size: 16, color: saved ? AppColors.primary : AppColors.foreground),
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 12, left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.background.withOpacity(0.7), borderRadius: BorderRadius.circular(12)),
                                          child: Row(
                                            children: [
                                              Icon(LucideIcons.star, size: 11, color: Colors.amber),
                                              const SizedBox(width: 4),
                                              Text(h.rating.toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                              const SizedBox(width: 4),
                                              Text('(${h.reviewCount})', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground)),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        bottom: 12, left: 12,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(color: AppColors.background.withOpacity(0.7), borderRadius: BorderRadius.circular(6)),
                                          child: Text(h.venueType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(h.name, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text('${h.area}, ${h.city}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Icon(LucideIcons.users, size: 11, color: AppColors.mutedForeground),
                                          const SizedBox(width: 4),
                                          Text('Up to ${h.capacity}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          const SizedBox(width: 12),
                                          Text('${h.halls} hall${h.halls > 1 ? 's' : ''}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                          const SizedBox(width: 12),
                                          Text(h.indoorOutdoor, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('STARTING', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground, letterSpacing: 1)),
                                              Text('₹${h.startingPrice.toInt()}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                            ],
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                            decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)),
                                            child: Text('View Venue', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primaryForeground)),
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
                      },
                    ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildChipRow(String label, String value, List<String> options, Function(String) onChange) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.mutedForeground)),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: options.map((opt) {
              final isSelected = value == opt;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: InkWell(
                  onTap: () => onChange(opt),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      gradient: isSelected ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                      color: isSelected ? null : AppColors.background,
                      border: isSelected ? null : Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.center,
                    child: Text(opt, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isSelected ? AppColors.primaryForeground : AppColors.foreground)),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
