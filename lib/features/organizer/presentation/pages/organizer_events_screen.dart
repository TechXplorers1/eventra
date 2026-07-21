import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';
import '../../../../shared/widgets/ev_components.dart';
import '../../../../shared/widgets/ev_button.dart';

class OrganizerEventsScreen extends ConsumerStatefulWidget {
  const OrganizerEventsScreen({super.key});

  @override
  ConsumerState<OrganizerEventsScreen> createState() => _OrganizerEventsScreenState();
}

class _OrganizerEventsScreenState extends ConsumerState<OrganizerEventsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  final _tabs = ['Published', 'Private', 'Draft', 'Completed'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<EventData> _filter(List<EventData> events, String tab) {
    return switch (tab) {
      'Published'  => events.where((e) => e.visibility == 'public').toList(),
      'Private'    => events.where((e) => e.visibility == 'private').toList(),
      'Draft'      => <EventData>[],
      'Completed'  => <EventData>[],
      _ => events,
    };
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    final allMyEvents = appState.publishedEvents;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingH, AppSpacing.pagePaddingV,
                    AppSpacing.pagePaddingH, 0,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('My Events',
                                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                            Text('${allMyEvents.length} events created',
                                style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                          ],
                        ),
                      ),
                      EvButton(
                        label: 'Create',
                        icon: LucideIcons.plus,
                        variant: EvButtonVariant.primary,
                        size: EvButtonSize.sm,
                        fullWidth: false,
                        onPressed: () => context.push('/organizer/create'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Tab Bar ─────────────────────────────────────────────
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: _tabs.map((t) {
                      final count = _filter(allMyEvents, t).length;
                      return Tab(
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(t, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          if (count > 0) ...[
                            const SizedBox(width: 4),
                            EvBadge(label: '$count', color: AppColors.primary, small: true),
                          ],
                        ]),
                      );
                    }).toList(),
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    indicatorPadding: const EdgeInsets.all(4),
                    labelColor: AppColors.primaryForeground,
                    unselectedLabelColor: AppColors.mutedForeground,
                    dividerColor: Colors.transparent,
                    splashFactory: NoSplash.splashFactory,
                    overlayColor: const WidgetStatePropertyAll(Colors.transparent),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),

                // ── Tab Views ────────────────────────────────────────────
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: _tabs.map((tab) {
                      final events = _filter(allMyEvents, tab);
                      if (events.isEmpty) {
                        return EvEmptyState(
                          icon: tab == 'Draft' ? LucideIcons.fileText : LucideIcons.calendarX,
                          title: 'No $tab Events',
                          subtitle: tab == 'Published'
                              ? 'Create and publish your first event to see it here.'
                              : tab == 'Private'
                                  ? 'Private events only visible to invited guests will appear here.'
                                  : 'No $tab events yet.',
                          actionLabel: tab == 'Published' || tab == 'Private' ? 'Create Event' : null,
                          onAction: () => context.push('/organizer/create'),
                        );
                      }
                      return ListView.builder(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePaddingH, AppSpacing.sm,
                          AppSpacing.pagePaddingH, AppSpacing.listBottomPad,
                        ),
                        itemCount: events.length,
                        itemBuilder: (context, i) => _EventCard(event: events[i]),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const BottomNav(),
          ],
        ),
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  final EventData event;
  const _EventCard({required this.event});

  static const _categoryColors = {
    'Music':        Color(0xFF8B5CF6),
    'Wedding':      Color(0xFFEC4899),
    'Conference':   Color(0xFF3B82F6),
    'Festival':     Color(0xFFF59E0B),
    'Sports':       Color(0xFF22C55E),
    'Corporate':    Color(0xFF6366F1),
    'Fashion':      Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final isPrivate = event.visibility == 'private';
    final catColor = _categoryColors[event.category] ?? AppColors.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.itemSpacing),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        child: InkWell(
          onTap: () => context.push('/organizer/event/${event.id}'),
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            child: Row(
              children: [
                // ── Color block ────────────────────────────────────────
                Container(
                  width: 52, height: 52,
                  decoration: BoxDecoration(
                    color: catColor.withAlpha(30),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    border: Border.all(color: catColor.withAlpha(80)),
                  ),
                  child: Icon(LucideIcons.calendarDays, size: 22, color: catColor),
                ),
                const SizedBox(width: 12),

                // ── Info ───────────────────────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.title,
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.foreground)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(LucideIcons.calendar, size: 11, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Text(event.date, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                        const SizedBox(width: 10),
                        Icon(LucideIcons.mapPin, size: 11, color: AppColors.mutedForeground),
                        const SizedBox(width: 4),
                        Expanded(child: Text(event.venue, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        EvStatusBadge(isPrivate ? 'private' : 'public'),
                        const SizedBox(width: 6),
                        EvBadge(label: event.category, color: catColor, small: true),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(LucideIcons.chevronRight, size: 16, color: AppColors.mutedForeground),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
