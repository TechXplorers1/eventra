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

class ServiceProviderDashboardScreen extends ConsumerWidget {
  const ServiceProviderDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appState = ref.watch(appProvider);
    final provider = appState.serviceProvider;
    final vendorId = provider.vendorId.isNotEmpty ? provider.vendorId : 'v1';
    final requests = appState.serviceRequests.where((r) => r.vendorId == vendorId).toList();

    final revenue = appState.spWalletBalance;
    final pending = requests.where((r) => r.status == 'Quote Requested').length;
    final confirmed = requests.where((r) => r.status == 'Confirmed').length;
    final total = requests.length;

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
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Good ${_greeting()},', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
                            const SizedBox(height: 2),
                            Text(
                              provider.businessName.isNotEmpty ? provider.businessName : 'Service Provider',
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.foreground),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                          ]),
                        ),
                        const SizedBox(width: 8),
                        _RatingBadge(rating: double.tryParse(provider.rating) ?? 5.0),
                        const SizedBox(width: 8),
                        _NavBtn(icon: LucideIcons.bell, onTap: () => context.push('/notifications')),
                      ],
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.lg)),

                // ── Revenue Hero Card ─────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusXl),
                      ),
                      child: Row(children: [
                        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text('Total Earnings', style: const TextStyle(fontSize: 12, color: Colors.white70)),
                          const SizedBox(height: 4),
                          Text('₹${(revenue / 1000).toStringAsFixed(1)}K',
                              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: Colors.white)),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.white.withAlpha(30), borderRadius: BorderRadius.circular(8)),
                            child: const Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(LucideIcons.trendingUp, size: 11, color: Colors.white),
                              SizedBox(width: 4),
                              Text('+18% this month', style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
                            ]),
                          ),
                        ])),
                        Column(children: [
                          Container(
                            width: 64, height: 64,
                            decoration: BoxDecoration(color: Colors.white.withAlpha(25), shape: BoxShape.circle),
                            child: const Icon(LucideIcons.wallet, size: 28, color: Colors.white),
                          ),
                          const SizedBox(height: 8),
                          GestureDetector(
                            onTap: () => context.push('/service-provider/wallet'),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(30),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text('Wallet', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          ),
                        ]),
                      ]),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

                // ── KPI row ──────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: Row(children: [
                      _MiniKpi(label: 'Total Bookings', value: '$total', icon: LucideIcons.calendarCheck, color: AppColors.primary),
                      const SizedBox(width: AppSpacing.sm),
                      _MiniKpi(label: 'Confirmed', value: '$confirmed', icon: LucideIcons.checkCircle2, color: AppColors.success),
                      const SizedBox(width: AppSpacing.sm),
                      _MiniKpi(label: 'Pending', value: '$pending', icon: LucideIcons.clock3, color: AppColors.warning),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionSpacing)),

                // ── Quick Actions ─────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const EvSectionHeader(title: 'Quick Actions'),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        _QuickAction(icon: LucideIcons.inbox, label: 'Requests', color: AppColors.primary, onTap: () => context.push('/service-provider/requests')),
                        const SizedBox(width: AppSpacing.sm),
                        _QuickAction(icon: LucideIcons.calendar, label: 'Calendar', color: const Color(0xFF22C55E), onTap: () => context.push('/service-provider/calendar')),
                        const SizedBox(width: AppSpacing.sm),
                        _QuickAction(icon: LucideIcons.package, label: 'Packages', color: AppColors.accent, onTap: () => context.push('/service-provider/packages')),
                        const SizedBox(width: AppSpacing.sm),
                        _QuickAction(icon: LucideIcons.star, label: 'Reviews', color: const Color(0xFFF59E0B), onTap: () => context.push('/service-provider/reviews')),
                      ]),
                    ]),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sectionSpacing)),

                // ── Recent Requests ───────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePaddingH),
                    child: EvSectionHeader(
                      title: 'Recent Requests',
                      actionLabel: 'View All',
                      onAction: () => context.push('/service-provider/requests'),
                    ),
                  ),
                ),
                const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

                if (requests.isEmpty)
                  SliverToBoxAdapter(
                    child: EvEmptyState(
                      icon: LucideIcons.inbox,
                      title: 'No Bookings Yet',
                      subtitle: 'When organizers book your service, requests will appear here.',
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (_, i) => Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.pagePaddingH, 0,
                          AppSpacing.pagePaddingH, AppSpacing.itemSpacing,
                        ),
                        child: _RequestCard(req: requests[i]),
                      ),
                      childCount: requests.take(5).length,
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
}

// ── Rating Badge ──────────────────────────────────────────────────────────────
class _RatingBadge extends StatelessWidget {
  final double rating;
  const _RatingBadge({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.warning.withAlpha(60)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(LucideIcons.star, size: 11, color: AppColors.warning),
        const SizedBox(width: 3),
        Text(rating > 0 ? rating.toStringAsFixed(1) : '5.0',
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.warning)),
      ]),
    );
  }
}

// ── Mini KPI ─────────────────────────────────────────────────────────────────
class _MiniKpi extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  const _MiniKpi({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: color.withAlpha(14),
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(fontSize: 9, color: AppColors.mutedForeground), textAlign: TextAlign.center),
        ]),
      ),
    );
  }
}

// ── Quick Action ──────────────────────────────────────────────────────────────
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

// ── Request Card ──────────────────────────────────────────────────────────────
class _RequestCard extends StatelessWidget {
  final ServiceRequest req;
  const _RequestCard({required this.req});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push('/service-provider/requests'),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(children: [
          Container(
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(20),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Icon(LucideIcons.briefcase, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(req.categoryName, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.foreground)),
            const SizedBox(height: 2),
            Text('Budget: ₹${req.budget.toInt()}  •  ${req.eventDate.isNotEmpty ? req.eventDate : "TBD"}',
                style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
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
