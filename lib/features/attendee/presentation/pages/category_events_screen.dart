import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/event_card.dart';

class CategoryEventsScreen extends ConsumerWidget {
  final String category;

  const CategoryEventsScreen({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allEvents = ref.watch(appProvider.select((s) => s.allEvents));
    final filtered = allEvents.where((e) {
      if (['Music', 'Sports', 'Performances', 'Comedy', 'Nightlife', 'Arts'].contains(category)) {
        return e.category == category;
      }
      return e.category.toLowerCase().contains(category.toLowerCase()) ||
             e.title.toLowerCase().contains(category.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: () => context.pop(),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                          child: Icon(LucideIcons.arrowLeft, size: 20, color: AppColors.foreground),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(category, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground, height: 1.2)),
                          Text('${filtered.length} events', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: filtered.isNotEmpty
                      ? GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.75, // Matching EventCard small ratio
                          ),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) => EventCard(event: filtered[index]),
                        )
                      : Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 64, height: 64,
                                decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                                child: const Center(child: Text('🎟️', style: TextStyle(fontSize: 24))),
                              ),
                              const SizedBox(height: 16),
                              Text('No events yet', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              const SizedBox(height: 4),
                              Text('Check back soon for upcoming $category events.', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                            ],
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
