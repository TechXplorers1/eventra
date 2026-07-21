import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/event_card.dart';
import '../../../../shared/widgets/bottom_nav.dart';

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final savedIds = appState.savedEventIds;
    final savedEvents = appState.allEvents.where((e) => savedIds.contains(e.id)).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  child: Text('Saved Events', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                ),
                Expanded(
                  child: savedEvents.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle),
                                child: Icon(LucideIcons.bookmark, size: 32, color: AppColors.mutedForeground),
                              ),
                              const SizedBox(height: 16),
                              Text('No saved events', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                              const SizedBox(height: 4),
                              Text('Events you save will appear here', style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
                              const SizedBox(height: 80),
                            ],
                          ),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.75,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                          itemCount: savedEvents.length,
                          itemBuilder: (context, i) => EventCard(event: savedEvents[i], size: EventCardSize.small),
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
