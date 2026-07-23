import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/widgets/event_card.dart';

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  String _query = '';
  final _trending = ['Coldplay', 'IPL', 'Comedy', 'Sunburn', 'Bangalore'];

  @override
  Widget build(BuildContext context) {
    final q = _query.trim().toLowerCase();
    final allEvents = ref.watch(appProvider.select((s) => s.allEvents));
    final results = q.length > 1
        ? allEvents.where((e) =>
            e.title.toLowerCase().contains(q) ||
            e.venue.toLowerCase().contains(q) ||
            e.city.toLowerCase().contains(q) ||
            e.category.toLowerCase().contains(q)).toList()
        : <EventData>[];

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
                    onTap: () {
  if (context.canPop()) {
    context.pop();
  } else {
    Future.microtask(() => context.go('/'));
  }
},
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                      child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                      child: Row(
                        children: [
                          Icon(LucideIcons.search, size: 18, color: AppColors.mutedForeground),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              autofocus: true,
                              onChanged: (val) => setState(() => _query = val),
                              style: TextStyle(color: AppColors.foreground, fontSize: 14),
                              decoration: InputDecoration(
                                hintText: 'Search events, artists, venues...',
                                hintStyle: TextStyle(color: AppColors.mutedForeground),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            GestureDetector(
                              onTap: () => setState(() => _query = ''),
                              child: Icon(LucideIcons.x, size: 16, color: AppColors.mutedForeground),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: q.length < 2
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Trending Searches', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _trending.map((t) => InkWell(
                              onTap: () => setState(() => _query = t),
                              borderRadius: BorderRadius.circular(24),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(24)),
                                child: Text(t, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              ),
                            )).toList(),
                          ),
                        ],
                      ),
                    )
                  : results.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: results.length,
                          itemBuilder: (context, i) => EventCard(event: results[i], size: EventCardSize.small),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(LucideIcons.search, size: 48, color: AppColors.mutedForeground.withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text('No events found for "$_query"', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                          ],
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
