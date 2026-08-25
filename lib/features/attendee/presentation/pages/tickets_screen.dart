import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../core/data/mock_data.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../shared/widgets/ev_components.dart';
import '../widgets/ticket_detail_modal.dart';
import '../widgets/service_booking_detail_modal.dart';

class TicketsScreen extends ConsumerStatefulWidget {
  final int initialTab;
  const TicketsScreen({super.key, this.initialTab = 0});

  @override
  ConsumerState<TicketsScreen> createState() => _TicketsScreenState();
}

class _TicketsScreenState extends ConsumerState<TicketsScreen> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTab;
  }

  @override
  void didUpdateWidget(TicketsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialTab != oldWidget.initialTab) {
      setState(() {
        _tabIndex = widget.initialTab;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(appProvider);
    final bookedTickets = state.bookedTickets;
    final serviceBookings = state.serviceBookings;
    final invitations = state.invitations;
    final pendingInvites = invitations.where((i) => i.status == 'pending').length;

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
                  padding: const EdgeInsets.fromLTRB(AppSpacing.pagePaddingH, AppSpacing.pagePaddingV, AppSpacing.pagePaddingH, 8),
                  child: Row(
                    children: [
                      const EvBackButton(),
                      const SizedBox(width: 12),
                      Text('My Bookings', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.foreground)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Container(
                    decoration: BoxDecoration(color: AppColors.secondary, borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: [
                        _buildTab(0, 'Tickets', bookedTickets.isNotEmpty ? '${bookedTickets.length}' : null),
                        _buildTab(1, 'Services', serviceBookings.isNotEmpty ? '${serviceBookings.length}' : null),
                        _buildTab(2, 'Invites', pendingInvites > 0 ? '$pendingInvites' : null, badgeColor: Colors.orange),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: _tabIndex == 0
                      ? _buildTicketsList(bookedTickets)
                      : _tabIndex == 1
                          ? _buildServicesList(serviceBookings)
                          : _buildInvitationsList(invitations),
                ),
              ],
            ),
          ),
          const BottomNav(),
        ],
      ),
    );
  }

  Widget _buildTab(int index, String label, String? badge, {Color? badgeColor}) {
    final isActive = _tabIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _tabIndex = index),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryForeground : AppColors.mutedForeground)),
              if (badge != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(color: (badgeColor ?? Colors.white).withOpacity(isActive ? 0.25 : 0.15), borderRadius: BorderRadius.circular(8)),
                  child: Text(badge, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryForeground : (badgeColor ?? AppColors.mutedForeground))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  bool _isPast(String dateStr) {
    try {
      final parts = dateStr.replaceAll(',', '').split(' ');
      if (parts.length != 3) return false;
      const months = {'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4, 'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12};
      final m = months[parts[0].substring(0, 3)] ?? 1;
      final d = int.parse(parts[1]);
      final y = int.parse(parts[2]);
      final eventDate = DateTime(y, m, d);
      final todayDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
      return eventDate.isBefore(todayDate);
    } catch (_) {
      return false;
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
    );
  }

  Widget _buildTicketsList(List bookedTickets) {
    if (bookedTickets.isEmpty) return _buildEmpty(LucideIcons.ticket, 'No tickets yet', 'Book an event to see your tickets here');
    
    final current = bookedTickets.where((t) => !_isPast(t.eventDate)).toList();
    final previous = bookedTickets.where((t) => _isPast(t.eventDate)).toList();

    Widget buildCard(t) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(12), child: Image.network(getEventImage(t.eventImageKey), width: 64, height: 80, fit: BoxFit.cover)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.eventTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                    const SizedBox(height: 4),
                    Row(children: [Icon(LucideIcons.calendar, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Text('${t.eventDate} • ${t.eventTime}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
                    const SizedBox(height: 2),
                    Row(children: [Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Expanded(child: Text(t.eventVenue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)))]),
                    const SizedBox(height: 8),
                    Row(children: [
                      Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(12)), child: Text(t.ticketType, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primary))),
                      const SizedBox(width: 8),
                      Expanded(child: Text(t.seats.join(', '), maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, color: AppColors.mutedForeground))),
                    ]),
                  ]),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => showTicketDetailModal(context, t),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('View Ticket', style: TextStyle(color: AppColors.primaryForeground, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Icon(LucideIcons.chevronRight, size: 14, color: AppColors.primaryForeground)]),
            )),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (current.isNotEmpty) ...[
          _buildSectionHeader('Current'),
          ...current.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(t))),
        ],
        if (previous.isNotEmpty) ...[
          if (current.isNotEmpty) const SizedBox(height: 8),
          _buildSectionHeader('Previous'),
          ...previous.map((t) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(t))),
        ],
      ],
    );
  }

  Widget _buildServicesList(List serviceBookings) {
    if (serviceBookings.isEmpty) return _buildEmpty(LucideIcons.briefcase, 'No service bookings', 'Book a vendor from Eventra Services');
    
    final current = serviceBookings.where((b) => !_isPast(b.eventDate)).toList();
    final previous = serviceBookings.where((b) => _isPast(b.eventDate)).toList();

    Widget buildCard(b) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.card, border: Border.all(color: AppColors.border), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Row(children: [
              Container(width: 56, height: 56, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.sparkles, size: 22, color: AppColors.primaryForeground)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Text(b.vendorName, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: Colors.blue.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Text(b.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.blue))),
                ]),
                const SizedBox(height: 2),
                Text('${b.serviceName} • ${b.packageName}'.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 4),
                Row(children: [Icon(LucideIcons.calendar, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Text('${b.eventDate} • ${b.startTime}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
                const SizedBox(height: 2),
                Row(children: [Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Expanded(child: Text('${b.venueName}, ${b.city}', maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)))]),
                const SizedBox(height: 6),
                Text('₹${b.total.toInt()}', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
              ])),
            ]),
            const SizedBox(height: 12),
            SizedBox(width: double.infinity, child: ElevatedButton(
              onPressed: () => showServiceBookingDetailModal(context, b),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.symmetric(vertical: 12)),
              child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Text('View Details', style: TextStyle(color: AppColors.foreground, fontSize: 12, fontWeight: FontWeight.bold)), const SizedBox(width: 8), Icon(LucideIcons.chevronRight, size: 14, color: AppColors.foreground)]),
            )),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (current.isNotEmpty) ...[
          _buildSectionHeader('Current'),
          ...current.map((b) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(b))),
        ],
        if (previous.isNotEmpty) ...[
          if (current.isNotEmpty) const SizedBox(height: 8),
          _buildSectionHeader('Previous'),
          ...previous.map((b) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(b))),
        ],
      ],
    );
  }

  Widget _buildInvitationsList(List invitations) {
    if (invitations.isEmpty) return _buildEmpty(LucideIcons.mail, 'No invitations', "You'll see private event invitations here");
    
    final current = invitations.where((i) => !_isPast(i.eventDate)).toList();
    final previous = invitations.where((i) => _isPast(i.eventDate)).toList();

    Widget buildCard(invite) {
      Color statusColor;
      String statusLabel;
      switch (invite.status) {
        case 'accepted': statusColor = Colors.green; statusLabel = 'Accepted'; break;
        case 'declined': statusColor = Colors.red; statusLabel = 'Declined'; break;
        default: statusColor = Colors.orange; statusLabel = 'Pending';
      }
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.card,
          border: Border.all(color: invite.status == 'pending' ? AppColors.primary.withOpacity(0.3) : AppColors.border),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.accent]), borderRadius: BorderRadius.circular(12)), child: Icon(LucideIcons.calendarDays, size: 22, color: AppColors.primaryForeground)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Expanded(child: Text(invite.eventTitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground))),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: statusColor.withOpacity(0.12), borderRadius: BorderRadius.circular(8)), child: Text(statusLabel, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
              ]),
              const SizedBox(height: 3),
              Row(children: [Icon(LucideIcons.user, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Text('From ${invite.organizerName}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
              Row(children: [Icon(LucideIcons.calendar, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Text(invite.eventDate, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground))]),
              Row(children: [Icon(LucideIcons.mapPin, size: 10, color: AppColors.mutedForeground), const SizedBox(width: 4), Expanded(child: Text(invite.eventVenue, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)))]),
            ])),
          ]),
          if (invite.status == 'pending') ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: ElevatedButton(
                onPressed: () {
                  ref.read(appProvider.notifier).respondToInvite(invite.id, 'declined');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('Invitation declined.'), backgroundColor: AppColors.secondary, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.x, size: 14), SizedBox(width: 6), Text('Decline', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
              )),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () {
                  ref.read(appProvider.notifier).respondToInvite(invite.id, 'accepted');
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("You're attending ${invite.eventTitle}!"), backgroundColor: Colors.green.shade700, behavior: SnackBarBehavior.floating, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green.withOpacity(0.12), foregroundColor: Colors.green, elevation: 0, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.check, size: 14), SizedBox(width: 6), Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold))]),
              )),
            ]),
          ],
        ]),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      children: [
        if (current.isNotEmpty) ...[
          _buildSectionHeader('Current'),
          ...current.map((i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(i))),
        ],
        if (previous.isNotEmpty) ...[
          if (current.isNotEmpty) const SizedBox(height: 8),
          _buildSectionHeader('Previous'),
          ...previous.map((i) => Padding(padding: const EdgeInsets.only(bottom: 12), child: buildCard(i))),
        ],
      ],
    );
  }

  Widget _buildEmpty(IconData icon, String title, String sub) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.secondary, shape: BoxShape.circle), child: Icon(icon, size: 32, color: AppColors.mutedForeground)),
          const SizedBox(height: 16),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
          const SizedBox(height: 4),
          Text(sub, textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.mutedForeground)),
          const SizedBox(height: 80),
        ]),
      ),
    );
  }
}
