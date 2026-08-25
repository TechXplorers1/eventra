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

  List<EventData> _applyFilters(List<EventData> source) {
    var list = _catFilter == 'All'
        ? source
        : source.where((e) => e.category == _catFilter).toList();
    if (_timeFilter != 'All' && _timeFilter != 'All Time') {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      list = list.where((e) {
        final eventDate = _parseEventDate(e.date);
        if (eventDate == null) return false;

        final eDay = DateTime(eventDate.year, eventDate.month, eventDate.day);
        if (_timeFilter == 'Today') {
          return eDay.year == today.year && eDay.month == today.month && eDay.day == today.day;
        } else if (_timeFilter == 'Tomorrow') {
          final tom = today.add(const Duration(days: 1));
          return eDay.year == tom.year && eDay.month == tom.month && eDay.day == tom.day;
        } else if (_timeFilter == 'This Weekend') {
          final daysToSat = (6 - today.weekday) % 7;
          final sat = today.add(Duration(days: daysToSat));
          final sun = sat.add(const Duration(days: 1));
          return (eDay.year == sat.year && eDay.month == sat.month && eDay.day == sat.day) ||
                 (eDay.year == sun.year && eDay.month == sun.month && eDay.day == sun.day);
        } else if (_timeFilter == 'This Month') {
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
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(16),
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
