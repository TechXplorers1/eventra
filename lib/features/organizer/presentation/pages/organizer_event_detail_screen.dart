import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_provider.dart';
import '../../../../shared/widgets/bottom_nav.dart';
import '../../../../core/data/mock_data.dart';

class OrganizerEventDetailScreen extends ConsumerStatefulWidget {
  final String eventId;

  const OrganizerEventDetailScreen({
    super.key,
    required this.eventId,
  });

  @override
  ConsumerState<OrganizerEventDetailScreen> createState() => _OrganizerEventDetailScreenState();
}

class _OrganizerEventDetailScreenState extends ConsumerState<OrganizerEventDetailScreen> {
  String _tab = 'overview';

  final _tabs = [
    {'id': 'overview', 'label': 'Overview', 'icon': LucideIcons.layoutGrid},
    {'id': 'tickets', 'label': 'Tickets', 'icon': LucideIcons.ticket},
    {'id': 'attendees', 'label': 'Attendees', 'icon': LucideIcons.users},
    {'id': 'services', 'label': 'Services', 'icon': LucideIcons.briefcase},
    {'id': 'settings', 'label': 'Settings', 'icon': LucideIcons.settings},
  ];

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Quote Requested': return Colors.amber;
      case 'Quotes Received': return Colors.blue;
      case 'Vendor Selected': return Colors.purpleAccent;
      case 'Confirmed': return Colors.greenAccent;
      case 'Cancelled': return Colors.redAccent;
      default: return AppColors.mutedForeground;
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = ref.watch(appProvider);
    // Use allEventsUnfiltered so private events are also visible to the organizer
    final event = appState.allEventsUnfiltered.firstWhere(
      (e) => e.id == widget.eventId,
      orElse: () => appState.allEventsUnfiltered.isNotEmpty ? appState.allEventsUnfiltered[0] : mockEvents[0],
    );
    final serviceRequests = appState.serviceRequests
        .where((r) => r.eventId == widget.eventId || r.eventId.isEmpty)
        .toList();

    final totalSpend = serviceRequests.fold<double>(0, (sum, r) => sum + (r.vendorPrice ?? 0));
    final activeVendors = serviceRequests.where((r) => r.status == 'Confirmed').length;
    final pending = serviceRequests.where((r) => r.status == 'Quote Requested' || r.status == 'Quotes Received').length;

    // Tickets for this event
    final eventTickets = appState.bookedTickets.where((t) => t.eventId == widget.eventId).toList();
    final ticketRevenue = eventTickets.fold<double>(0.0, (sum, t) => sum + t.totalPrice);
    final ticketsSold = eventTickets.fold<int>(0, (sum, t) => sum + t.quantity);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                        Text(event.title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.foreground), maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text('${event.date} • ${event.venue}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Tabs
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: _tabs.map((t) {
                  final isActive = _tab == t['id'];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: InkWell(
                      onTap: () => setState(() => _tab = t['id'] as String),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: isActive ? AppColors.primary : AppColors.secondary,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(t['icon'] as IconData, size: 12, color: isActive ? AppColors.primaryForeground : AppColors.foreground),
                            const SizedBox(width: 6),
                            Text(t['label'] as String, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: isActive ? AppColors.primaryForeground : AppColors.foreground)),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  if (_tab == 'overview') ...[
                    _buildStat('Tickets Sold', '$ticketsSold${ticketsSold == 0 ? " (seeded)" : ""}'),
                    const SizedBox(height: 12),
                    _buildStat('Revenue', '₹${ticketRevenue > 0 ? ticketRevenue.toInt() : 482400}'),
                    const SizedBox(height: 12),
                    _buildStat('Active Services', activeVendors.toString()),
                    const SizedBox(height: 12),
                    _buildStat('Pending Quotes', pending.toString()),
                    const SizedBox(height: 12),
                    _buildStat('Vendor Spend', '₹${totalSpend.toInt()}'),
                  ],
                  if (_tab == 'tickets') ...[
                    if (eventTickets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text(
                          'No tickets booked yet for this event.',
                          style: TextStyle(fontSize: 13, color: AppColors.mutedForeground),
                        )),
                      )
                    else
                      ...eventTickets.map((t) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(14), border: Border.all(color: AppColors.border)),
                        child: Row(
                          children: [
                            Container(width: 36, height: 36, decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(LucideIcons.ticket, size: 16, color: AppColors.primary)),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(t.ticketType, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                  Text('Qty: ${t.quantity} • ₹${t.totalPrice.toInt()}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                  Text('QR: ${t.qrCode}', style: TextStyle(fontSize: 10, color: AppColors.mutedForeground.withOpacity(0.6))),
                                ],
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(color: Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                              child: Text('Paid', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green)),
                            ),
                          ],
                        ),
                      )).toList(),
                  ],
                  if (_tab == 'attendees') ...[
                    if (eventTickets.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No attendees yet.', style: TextStyle(fontSize: 13, color: AppColors.mutedForeground))),
                      )
                    else
                      ...eventTickets.asMap().entries.map((entry) {
                        final i = entry.key;
                        final t = entry.value;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(12)),
                          child: Row(
                            children: [
                              CircleAvatar(radius: 18, backgroundColor: AppColors.primary.withOpacity(0.15), child: Text('A${i + 1}', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Attendee #${i + 1}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.foreground)),
                                    Text('${t.ticketType} • ${t.seats.isNotEmpty ? t.seats.join(", ") : "General Admission"}', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
                                  ],
                                ),
                              ),
                              Icon(LucideIcons.checkCircle, size: 16, color: Colors.green),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                  if (_tab == 'analytics') Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Revenue Overview', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                        const SizedBox(height: 16),
                        _buildAnalyticsRow('Ticket Revenue', '₹${ticketRevenue > 0 ? ticketRevenue.toInt() : 482400}', Colors.green),
                        _buildAnalyticsRow('Vendor Spend', '₹${totalSpend.toInt()}', Colors.red),
                        _buildAnalyticsRow('Net Revenue', '₹${(ticketRevenue > 0 ? ticketRevenue : 482400) - totalSpend > 0 ? ((ticketRevenue > 0 ? ticketRevenue : 482400) - totalSpend).toInt() : 0}', AppColors.primary),
                        const Divider(height: 24),
                        _buildAnalyticsRow('Tickets Sold', '$ticketsSold', AppColors.foreground),
                        _buildAnalyticsRow('Pending Vendors', '$pending', Colors.amber),
                        _buildAnalyticsRow('Confirmed Vendors', '$activeVendors', Colors.green),
                      ],
                    ),
                  ),
                  if (_tab == 'settings') _buildSettingsTab(event),
                  
                  if (_tab == 'services') ...[
                    Row(
                      children: [
                        Expanded(child: _buildMini('Services', serviceRequests.length.toString())),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMini('Spend', '₹${totalSpend.toStringAsFixed(0)}')),
                        const SizedBox(width: 8),
                        Expanded(child: _buildMini('Pending', pending.toString())),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context.push('/organizer/services'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.primaryForeground,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('+ Add Service', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 16),
                    if (serviceRequests.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32),
                        child: Center(child: Text('No services added yet.', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground))),
                      )
                    else
                      ...serviceRequests.map((r) {
                        final statusColor = _getStatusColor(r.status);
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Icon(LucideIcons.briefcase, size: 14, color: AppColors.primary),
                                      const SizedBox(width: 8),
                                      Text(r.categoryName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                                    child: Text(r.status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                                  ),
                                ],
                              ),
                              if (r.vendorName != null) ...[
                                const SizedBox(height: 12),
                                Text(r.vendorName!, style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                                Text('₹${r.vendorPrice?.toStringAsFixed(0)}', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
                              ],
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () {},
                                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.secondary, foregroundColor: AppColors.foreground, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(LucideIcons.edit2, size: 11), SizedBox(width: 4), Text('Edit', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: () => ref.read(appProvider.notifier).removeServiceRequest(r.id),
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), elevation: 0),
                                      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: const [Icon(LucideIcons.x, size: 11), SizedBox(width: 4), Text('Cancel', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold))]),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomNav(),
    );
  }

  Widget _buildStat(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
          Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    );
  }

  Widget _buildMini(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: TextStyle(fontSize: 9, color: AppColors.mutedForeground)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(String text) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
      child: Center(
        child: Text(text, textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
      ),
    );
  }

  Widget _buildSettingsTab(event) {
    final isPrivate = event.visibility == 'private';
    final appState = ref.watch(appProvider);
    final sentInvites = appState.invitations
        .where((i) => i.eventId == widget.eventId)
        .length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Visibility badge
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
          child: Row(
            children: [
              Container(width: 40, height: 40, decoration: BoxDecoration(color: (isPrivate ? Colors.orange : Colors.green).withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(isPrivate ? LucideIcons.lock : LucideIcons.globe2, size: 18, color: isPrivate ? Colors.orange : Colors.green)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(isPrivate ? 'Private Event' : 'Public Event', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                Text(isPrivate ? 'Only invited attendees can attend' : 'Visible to all users on the platform', style: TextStyle(fontSize: 11, color: AppColors.mutedForeground)),
              ])),
            ],
          ),
        ),
        const SizedBox(height: 16),
        // Invite section (private only)
        if (isPrivate) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.card, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Invitations', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.foreground)),
                if (sentInvites > 0)
                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)), child: Text('$sentInvites sent', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.primary))),
              ]),
              const SizedBox(height: 6),
              Text('Invite attendees by phone number or email.', style: TextStyle(fontSize: 12, color: AppColors.mutedForeground)),
              const SizedBox(height: 14),
              SizedBox(width: double.infinity, child: ElevatedButton(
                onPressed: () => context.push('/organizer/invite/${widget.eventId}?title=${Uri.encodeComponent(event.title)}'),
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: AppColors.primaryForeground, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(LucideIcons.send, size: 16, color: AppColors.primaryForeground), const SizedBox(width: 8), Text('Invite Attendees', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.primaryForeground))]),
              )),
            ]),
          ),
        ],
      ],
    );
  }

  Widget _buildAnalyticsRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: AppColors.mutedForeground)),
          Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
