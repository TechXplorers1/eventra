import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/models/app_models.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_badge.dart';
import '../../../../shared/widgets/ev_components.dart';

class OrganizerDashboardScreen extends ConsumerWidget {
  const OrganizerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final organizer = appState.organizer;
    final myEvents = appState.publishedEvents;
    final serviceRequests = appState.serviceRequests;

    final revenue = appState.organizerWalletBalance;
    final totalSold = appState.bookedTickets.fold<int>(0, (s, t) => s + t.quantity);
    final pendingQuotes = serviceRequests.where((r) => r.status == 'Quote Requested').length;
    final confirmedVendors = serviceRequests.where((r) => r.status == 'Confirmed').length;

    final isVerified = organizer.status == 'verified';
    final isPending  = organizer.status == 'pending';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          SafeArea(
            bottom: false,
            child: CustomScrollView(
              slivers: [

                // ── Header ─────────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePaddingH, AppSpacing.pagePaddingV,
                      AppSpacing.pagePaddingH, 0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Good ${_greeting()},',
                                  style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                              const SizedBox(height: 2),
                              Text(
                                organizer.orgName.isNotEmpty ? organizer.orgName : 'Organizer',
                                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground),
                                maxLines: 1, overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(isVerified, isPending),
                        const SizedBox(width: 8),
                        _NavBtn(icon: LucideIcons.bell, onTap: () => context.push('/notifications')),
                      ],
                    ),
                  ),
                ),

                // ── Verification Banner ────────────────────────────────────
                if (!isVerified)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.pagePaddingH, AppSpacing.md,
                        AppSpacing.pagePaddingH, 0,
                      ),
                      child: GestureDetector(
                        onTap: () => context.push('/organizer/verification'),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.cardPadding),
                          decoration: BoxDecoration(
                            color: AppColors.warning.withAlpha(12),
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                            border: Border.all(color: AppColors.warning.withAlpha(80)),
                          ),
                          child: Row(children: [
                            Icon(isPending ? LucideIcons.clock3 : LucideIcons.shieldAlert,
                                size: 20, color: AppColors.warning),
                            const SizedBox(width: 10),
                            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text(isPending ? 'Verification Pending' : 'Get Verified',
                                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.warning)),
                              Text(isPending
                                  ? 'Your account is under review — usually 24-48 hours.'
                                  : 'Verify your account to unlock all organizer features.',
                                  style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                            ])),
                            if (!isPending)
                              Icon(LucideIcons.arrowRight, size: 14, color: AppColors.warning),
                          ]),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                // ── KPI Cards 2×2 ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: AppSpacing.sm,
                      crossAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 2.0,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [
                        EvKpiCard(
                          label: 'Wallet Balance',
                          value: '₹${(revenue / 1000).toStringAsFixed(1)}K',
                          icon: LucideIcons.wallet,
                          accentColor: AppColors.primary,
                          change: '+12%',
                        ),
                        EvKpiCard(
                          label: 'Tickets Sold',
                          value: '$totalSold',
                          icon: LucideIcons.ticket,
                          accentColor: const Color(0xFF22C55E),
                        ),
                        EvKpiCard(
                          label: 'Pending Quotes',
                          value: '$pendingQuotes',
                          icon: LucideIcons.messageSquare,
                          accentColor: AppColors.warning,
                        ),
                        EvKpiCard(
                          label: 'Active Vendors',
                          value: '$confirmedVendors',
                          icon: LucideIcons.users,
                          accentColor: AppColors.accent,
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionSpacing)),

                // ── Quick Actions ──────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const EvSectionHeader(title: 'Quick Actions'),
                        const SizedBox(height: AppSpacing.sm),
                        Row(children: [
                          _QuickAction(icon: LucideIcons.calendarPlus, label: 'Create Event', color: AppColors.primary, onTap: () => context.push('/organizer/create')),
                          const SizedBox(width: AppSpacing.sm),
                          _QuickAction(icon: LucideIcons.scanLine,     label: 'Scan QR',     color: const Color(0xFF22C55E), onTap: () => context.push('/organizer/scan')),
                          const SizedBox(width: AppSpacing.sm),
                          _QuickAction(icon: LucideIcons.briefcase,    label: 'Services',    color: AppColors.accent, onTap: () => context.push('/organizer/services')),
                          const SizedBox(width: AppSpacing.sm),
                          _QuickAction(icon: LucideIcons.wallet,       label: 'Wallet',      color: const Color(0xFF8B5CF6), onTap: () => context.push('/organizer/wallet')),
                        ]),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionSpacing)),

                // ── My Events ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'My Events',
                      subtitle: '${myEvents.length} total',
                      actionLabel: 'View All',
                      onAction: () => context.push('/organizer/events'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                if (myEvents.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                      child: EvEmptyState(
                        icon: LucideIcons.calendarX,
                        title: 'No Events Yet',
                        subtitle: 'Create your first event and start selling tickets.',
                        actionLabel: 'Create Event',
                        onAction: () => context.push('/organizer/create'),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 90,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                        scrollDirection: Axis.horizontal,
                        itemCount: myEvents.take(3).length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                        itemBuilder: (_, i) => SizedBox(
                          width: 300,
                          child: _DashEventCard(event: myEvents[i]),
                        ),
                      ),
                    ),
                  ),

                // ── Recent Service Requests ───────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePaddingH, AppSpacing.sectionSpacing,
                      AppSpacing.pagePaddingH, AppSpacing.sm,
                    ),
                    child: EvSectionHeader(
                      title: 'Service Requests',
                      actionLabel: 'All',
                      onAction: () => context.push('/organizer/services'),
                    ),
                  ),
                ),

                if (serviceRequests.isEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: Text('No service requests yet.', style: TextStyle(color: AppColors.mutedForeground))),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 80,
                      child: ListView.separated(
                        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                        scrollDirection: Axis.horizontal,
                        itemCount: serviceRequests.take(3).length,
                        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.md),
                        itemBuilder: (_, i) => SizedBox(
                          width: 300,
                          child: _ServiceReqCard(req: serviceRequests[i]),
                        ),
                      ),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.listBottomPad)),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  static String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'morning';
    if (h < 17) return 'afternoon';
    return 'evening';
  }

  static Widget _statusBadge(bool verified, bool pending) {
    final label = verified ? 'Verified' : pending ? 'Pending' : 'Unverified';
    final color = verified ? AppColors.success : AppColors.warning;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
      ]),
    );
  }
}

// ── Quick Action tile ─────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Column(children: [
            Icon(icon, size: 22, color: color),
            const SizedBox(height: 5),
            Text(label, style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: color), textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}

// ── Dashboard event card ──────────────────────────────────────────────────────
class _DashEventCard extends StatelessWidget {
  final dynamic event;
  const _DashEventCard({required this.event});

  static const _catColors = {
    'Music': Color(0xFF8B5CF6), 'Sports': Color(0xFF22C55E),
    'Wedding': Color(0xFFEC4899), 'Corporate': Color(0xFF6366F1),
    'Conference': Color(0xFF3B82F6), 'Festival': Color(0xFFEF4444),
  };

  @override
  Widget build(BuildContext context) {
    final color = _catColors[event.category] ?? AppColors.primary;
    final isPrivate = event.visibility == 'private';

    return GestureDetector(
      onTap: () => context.push('/organizer/event/${event.id}'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 46, height: 46,
            decoration: BoxDecoration(color: color.withAlpha(25), borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
            child: Icon(LucideIcons.calendarDays, size: 20, color: color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            const SizedBox(height: 3),
            Text('${event.date}  •  ${event.venue}', maxLines: 1, overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ])),
          const SizedBox(width: 8),
          EvStatusBadge(isPrivate ? 'private' : 'public'),
        ]),
      ),
    );
  }
}

// ── Service request card ──────────────────────────────────────────────────────
class _ServiceReqCard extends StatelessWidget {
  final ServiceRequest req;
  const _ServiceReqCard({required this.req});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/organizer/services/requests'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(LucideIcons.briefcase, size: 18, color: AppColors.mutedForeground),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(req.categoryName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            Text('Budget: ₹${req.budget.toInt()}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
          ])),
          EvStatusBadge(req.status.toLowerCase()),
        ]),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _NavBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
    child: Container(
      width: 38, height: 38,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        border: Border.all(color: AppColors.border),
      ),
      child: Icon(icon, size: 16, color: AppColors.foreground),
    ),
  );
}
