import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/event_card.dart';

const _allFilters = ['All', 'Music', 'Sports', 'Performances', 'Comedy', 'Nightlife', 'Arts'];
const _timeFilters = ['All', 'Today', 'Tomorrow', 'This Weekend'];

class AllEventsScreen extends ConsumerStatefulWidget {
  const AllEventsScreen({super.key});

  @override
  ConsumerState<AllEventsScreen> createState() => _AllEventsScreenState();
}

class _AllEventsScreenState extends ConsumerState<AllEventsScreen> {
  String _catFilter = 'All';
  String _timeFilter = 'All';

  List<EventData> _applyFilters(List<EventData> source) {
    var list = _catFilter == 'All'
        ? source
        : source.where((e) => e.category == _catFilter).toList();
    if (_timeFilter != 'All') {
      final now = DateTime.now();
      list = list.where((e) {
        try {
          final parts = e.date.split(' ');
          final months = {'Jan':1,'Feb':2,'Mar':3,'Apr':4,'May':5,'Jun':6,'Jul':7,'Aug':8,'Sep':9,'Oct':10,'Nov':11,'Dec':12};
          final month = months[parts[0]] ?? 1;
          final day = int.parse(parts[1].replaceAll(',', ''));
          final year = int.parse(parts[2]);
          final eventDate = DateTime(year, month, day);
          if (_timeFilter == 'Today') {
            return eventDate.year == now.year && eventDate.month == now.month && eventDate.day == now.day;
          } else if (_timeFilter == 'Tomorrow') {
            final tom = now.add(const Duration(days: 1));
            return eventDate.year == tom.year && eventDate.month == tom.month && eventDate.day == tom.day;
          } else if (_timeFilter == 'This Weekend') {
            final weekday = now.weekday;
            final daysToSat = (6 - weekday) % 7;
            final sat = now.add(Duration(days: daysToSat));
            final sun = sat.add(const Duration(days: 1));
            return (eventDate.year == sat.year && eventDate.month == sat.month && eventDate.day == sat.day) ||
                   (eventDate.year == sun.year && eventDate.month == sun.month && eventDate.day == sun.day);
          }
        } catch (_) {}
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
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
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
                      Text('All Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    ],
                  ),
                ),

                // Category Filters
                SizedBox(
                  height: 40,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _allFilters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _allFilters[index];
                      final active = _catFilter == f;
                      return InkWell(
                        onTap: () => setState(() => _catFilter = f),
                        borderRadius: BorderRadius.circular(24),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            gradient: active ? LinearGradient(colors: [AppColors.primary, AppColors.accent]) : null,
                            color: active ? null : AppColors.secondary,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: active ? AppColors.primaryForeground : AppColors.foreground,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),

                // Time Filters
                SizedBox(
                  height: 32,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    scrollDirection: Axis.horizontal,
                    itemCount: _timeFilters.length,
                    separatorBuilder: (context, index) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final f = _timeFilters[index];
                      final active = _timeFilter == f;
                      return InkWell(
                        onTap: () => setState(() => _timeFilter = f),
                        borderRadius: BorderRadius.circular(16),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: active ? AppColors.muted : AppColors.secondary,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            f == 'All' ? 'Filters' : f,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: active ? AppColors.foreground : AppColors.mutedForeground,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) => EventCard(event: filtered[index]),
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
